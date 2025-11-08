const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const admin = require('firebase-admin');

dotenv.config();

// Inicializar Firebase Admin
let serviceAccount;
try {
  if (!process.env.FIREBASE_PROJECT_ID || !process.env.FIREBASE_PRIVATE_KEY || !process.env.FIREBASE_CLIENT_EMAIL) {
    console.error('❌ Variáveis de ambiente do Firebase não configuradas!');
    console.error('Verifique o arquivo .env');
    throw new Error('Firebase Admin SDK não configurado. Verifique o arquivo .env');
  }

  serviceAccount = {
    projectId: process.env.FIREBASE_PROJECT_ID,
    privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
  };

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
  console.log('✅ Firebase Admin SDK inicializado com sucesso');
} catch (error) {
  console.error('❌ Erro ao inicializar Firebase Admin SDK:', error.message);
  console.error('Certifique-se de que o arquivo .env está configurado corretamente');
  // Não encerrar o processo, mas avisar
}

const db = admin.firestore();
const auth = admin.auth();

const app = express();
app.use(cors());
app.use(express.json());

// Middleware de tratamento de erros global
app.use((err, req, res, next) => {
  console.error('❌ Erro não tratado:', err);
  res.status(500).json({ 
    error: err.message || 'Erro interno do servidor',
    details: err.stack 
  });
});

// Rota de teste para verificar se o servidor está funcionando
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    message: 'Servidor funcionando',
    firebase: db ? 'conectado' : 'não conectado'
  });
});

// ============ AUTENTICAÇÃO ============
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Verificar credenciais (em produção, usar hash de senha)
    if (email === process.env.ADMIN_EMAIL && password === process.env.ADMIN_PASSWORD) {
      // Buscar ou criar usuário admin no Firebase Auth
      let adminUser;
      try {
        adminUser = await auth.getUserByEmail(email);
      } catch (error) {
        // Criar usuário admin se não existir
        adminUser = await auth.createUser({
          email,
          password,
          emailVerified: true,
        });
      }

      // Definir custom claim de admin
      await auth.setCustomUserClaims(adminUser.uid, { admin: true });

      // Gerar token customizado
      const customToken = await auth.createCustomToken(adminUser.uid);
      
      res.json({ 
        success: true, 
        token: customToken,
        user: {
          uid: adminUser.uid,
          email: adminUser.email,
        }
      });
    } else {
      res.status(401).json({ error: 'Credenciais inválidas' });
    }
  } catch (error) {
    console.error('Erro no login:', error);
    res.status(500).json({ error: 'Erro ao fazer login: ' + error.message });
  }
});

// Middleware de autenticação
const authenticateAdmin = async (req, res, next) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) {
      console.log('⚠️ Requisição sem token');
      return res.status(401).json({ error: 'Token não fornecido' });
    }

    // Verificar se é um custom token (do login) ou ID token
    let decoded;
    try {
      decoded = await admin.auth().verifyIdToken(token);
    } catch (error) {
      // Se falhar, pode ser um custom token - tentar trocar por ID token
      console.log('⚠️ Token não é ID token, pode ser custom token');
      // Por enquanto, permitir acesso se o token existe (em produção, implementar troca de token)
      // Para desenvolvimento, vamos permitir acesso
      req.user = { uid: 'admin-dev', customClaims: { admin: true } };
      return next();
    }
    
    const user = await admin.auth().getUser(decoded.uid);
    
    // Verificar se é admin (custom claim)
    if (!user.customClaims?.admin) {
      console.log('⚠️ Usuário sem permissão admin');
      return res.status(403).json({ error: 'Acesso negado. Apenas administradores.' });
    }

    req.user = user;
    next();
  } catch (error) {
    console.error('❌ Erro na autenticação:', error);
    // Em desenvolvimento, permitir acesso mesmo com erro de token
    if (process.env.NODE_ENV !== 'production') {
      console.log('⚠️ Modo desenvolvimento: permitindo acesso sem validação completa');
      req.user = { uid: 'admin-dev', customClaims: { admin: true } };
      return next();
    }
    res.status(401).json({ error: 'Token inválido: ' + error.message });
  }
};

// ============ SISTEMA DE MANUTENÇÃO ============
app.get('/api/maintenance/status', async (req, res) => {
  try {
    console.log('🔧 Buscando status de manutenção...');
    const doc = await db.collection('appSettings').doc('maintenance').get();
    const status = doc.exists ? doc.data() : { enabled: false, message: '' };
    console.log('✅ Status de manutenção:', status);
    res.json(status);
  } catch (error) {
    console.error('❌ Erro ao buscar status de manutenção:', error);
    res.status(500).json({ 
      error: error.message,
      details: error.stack,
      hint: 'Verifique se o Firebase Admin SDK está configurado corretamente'
    });
  }
});

app.post('/api/maintenance/toggle', authenticateAdmin, async (req, res) => {
  try {
    const { enabled, message } = req.body;
    await db.collection('appSettings').doc('maintenance').set({
      enabled: enabled || false,
      message: message || 'O aplicativo está em manutenção. Tente novamente mais tarde.',
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: req.user.uid,
    });
    res.json({ success: true, enabled, message });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============ GERENCIAMENTO DE USUÁRIOS ============
app.get('/api/users', authenticateAdmin, async (req, res) => {
  try {
    console.log('👥 Buscando usuários...');
    const { type, banned, page = 1, limit = 50 } = req.query;
    let query = db.collection('users');
    
    if (type) {
      query = query.where('type', '==', type);
    }
    if (banned !== undefined) {
      query = query.where('banned', '==', banned === 'true');
    }

    // Firestore não suporta offset, então vamos buscar todos e paginar depois
    const snapshot = await query.get();

    console.log(`📦 Encontrados ${snapshot.size} documentos na coleção 'users'`);

    // Paginação manual (Firestore não suporta offset)
    const startIndex = (parseInt(page) - 1) * parseInt(limit);
    const endIndex = startIndex + parseInt(limit);
    const paginatedDocs = snapshot.docs.slice(startIndex, endIndex);

    const users = [];
    for (const doc of paginatedDocs) {
      const userData = doc.data();
      try {
        const authUser = await auth.getUser(doc.id);
        users.push({
          id: doc.id,
          ...userData,
          email: authUser.email,
          emailVerified: authUser.emailVerified,
          disabled: authUser.disabled,
          createdAt: authUser.metadata.creationTime,
        });
      } catch (error) {
        // Se não encontrar no Auth, ainda adiciona com dados do Firestore
        users.push({
          id: doc.id,
          ...userData,
          email: userData.email || 'N/A',
          error: 'Usuário não encontrado no Firebase Auth',
        });
      }
    }

    console.log(`✅ Retornando ${users.length} usuários (página ${page} de ${Math.ceil(snapshot.size / parseInt(limit))})`);
    res.json({ users, total: snapshot.size });
  } catch (error) {
    console.error('❌ Erro ao buscar usuários:', error);
    res.status(500).json({ error: error.message, details: error.stack });
  }
});

app.post('/api/users/:userId/ban', authenticateAdmin, async (req, res) => {
  try {
    const { userId } = req.params;
    const { reason } = req.body;

    // Atualizar no Firestore
    await db.collection('users').doc(userId).update({
      banned: true,
      banReason: reason || 'Sem motivo especificado',
      bannedAt: admin.firestore.FieldValue.serverTimestamp(),
      bannedBy: req.user.uid,
    });

    // Desabilitar no Firebase Auth
    await auth.updateUser(userId, { disabled: true });

    res.json({ success: true, message: 'Usuário banido com sucesso' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/users/:userId/unban', authenticateAdmin, async (req, res) => {
  try {
    const { userId } = req.params;

    // Atualizar no Firestore
    await db.collection('users').doc(userId).update({
      banned: false,
      banReason: null,
      unbannedAt: admin.firestore.FieldValue.serverTimestamp(),
      unbannedBy: req.user.uid,
    });

    // Habilitar no Firebase Auth
    await auth.updateUser(userId, { disabled: false });

    res.json({ success: true, message: 'Usuário desbanido com sucesso' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============ GERENCIAMENTO DE ESTABELECIMENTOS ============
app.get('/api/establishments', authenticateAdmin, async (req, res) => {
  try {
    console.log('🏢 Buscando estabelecimentos...');
    const { page = 1, limit = 50, difficultyLevel } = req.query;
    let query = db.collection('establishments');

    if (difficultyLevel) {
      query = query.where('difficultyLevel', '==', difficultyLevel);
    }

    const snapshot = await query.get();

    console.log(`📦 Encontrados ${snapshot.size} estabelecimentos`);

    // Paginação manual (Firestore não suporta offset)
    const startIndex = (parseInt(page) - 1) * parseInt(limit);
    const endIndex = startIndex + parseInt(limit);
    const paginatedDocs = snapshot.docs.slice(startIndex, endIndex);

    const establishments = paginatedDocs.map(doc => {
      const data = doc.data();
      // Garantir que o ID do documento do Firestore sempre tenha prioridade
      const establishment = {
        ...data,
        id: doc.id, // ID do documento do Firestore (sempre sobrescreve qualquer campo 'id' nos dados)
      };
      console.log(`📋 Estabelecimento: nome=${data.name}, id_documento=${doc.id}, id_dados=${data.id || 'não existe'}`);
      return establishment;
    });

    console.log(`✅ Retornando ${establishments.length} estabelecimentos (página ${page})`);
    const establishmentIds = establishments.map(e => e.id);
    console.log(`📦 IDs retornados: ${establishmentIds.join(', ')}`);
    res.json({ establishments, total: snapshot.size });
  } catch (error) {
    console.error('❌ Erro ao buscar estabelecimentos:', error);
    res.status(500).json({ error: error.message, details: error.stack });
  }
});

app.put('/api/establishments/:establishmentId/difficulty', authenticateAdmin, async (req, res) => {
  try {
    const { establishmentId } = req.params;
    const { difficultyLevel } = req.body;

    console.log(`🔧 Atualizando dificuldade do estabelecimento ${establishmentId} para ${difficultyLevel}`);

    if (!difficultyLevel) {
      return res.status(400).json({ error: 'Nível de dificuldade não fornecido' });
    }

    if (!['popular', 'intermediate', 'technical'].includes(difficultyLevel)) {
      return res.status(400).json({ error: 'Nível de dificuldade inválido. Use: popular, intermediate ou technical' });
    }

    // Verificar se o estabelecimento existe
    const establishmentRef = db.collection('establishments').doc(establishmentId);
    const establishmentDoc = await establishmentRef.get();

    console.log(`📋 Verificando estabelecimento ${establishmentId}: existe=${establishmentDoc.exists}`);

    if (!establishmentDoc.exists) {
      // Listar todos os IDs de estabelecimentos para debug
      const allEstablishments = await db.collection('establishments').get();
      const allIds = allEstablishments.docs.map(doc => doc.id);
      console.log(`📦 IDs de estabelecimentos disponíveis: ${allIds.join(', ')}`);
      
      return res.status(404).json({ 
        error: `Estabelecimento não encontrado: ${establishmentId}`,
        availableIds: allIds,
        receivedId: establishmentId
      });
    }

    // Usar set com merge para garantir que o campo seja atualizado mesmo se não existir
    await establishmentRef.set({
      difficultyLevel,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: req.user.uid,
    }, { merge: true });

    console.log(`✅ Nível de dificuldade atualizado para ${difficultyLevel} no estabelecimento ${establishmentId}`);

    res.json({ success: true, message: 'Nível de dificuldade atualizado' });
  } catch (error) {
    console.error('❌ Erro ao atualizar nível de dificuldade:', error);
    res.status(500).json({ 
      error: error.message || 'Erro ao atualizar nível de dificuldade',
      details: error.stack 
    });
  }
});

// ============ FATURAMENTO E LICENÇAS ============
app.get('/api/licenses', authenticateAdmin, async (req, res) => {
  try {
    const snapshot = await db.collection('licenses').get();
    const licenses = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));

    const totalRevenue = licenses.reduce((sum, license) => sum + (license.amount || 0), 0);
    const activeLicenses = licenses.filter(l => l.status === 'active').length;

    res.json({
      licenses,
      stats: {
        total: licenses.length,
        active: activeLicenses,
        totalRevenue,
      },
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/licenses', authenticateAdmin, async (req, res) => {
  try {
    const { businessId, amount, plan, duration } = req.body;

    const license = {
      businessId,
      amount: parseFloat(amount),
      plan: plan || 'monthly',
      duration: duration || 30, // dias
      status: 'active',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      expiresAt: admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + (duration || 30) * 24 * 60 * 60 * 1000)
      ),
      createdBy: req.user.uid,
    };

    const docRef = await db.collection('licenses').add(license);
    res.json({ success: true, licenseId: docRef.id, ...license });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============ CONTROLE DE PONTOS ============
app.put('/api/users/:userId/points', authenticateAdmin, async (req, res) => {
  try {
    const { userId } = req.params;
    const { points, reason } = req.body;

    if (typeof points !== 'number') {
      return res.status(400).json({ error: 'Pontos devem ser um número' });
    }

    // Buscar pontos atuais
    const userDoc = await db.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      return res.status(404).json({ error: 'Usuário não encontrado' });
    }

    const currentPoints = userDoc.data().points || 0;
    const newPoints = Math.max(0, currentPoints + points); // Não permitir pontos negativos

    // Atualizar pontos
    await db.collection('users').doc(userId).update({
      points: newPoints,
      pointsHistory: admin.firestore.FieldValue.arrayUnion({
        points: points,
        reason: reason || 'Ajuste administrativo',
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        adminId: req.user.uid,
      }),
    });

    res.json({ 
      success: true, 
      message: `Pontos ${points >= 0 ? 'adicionados' : 'removidos'} com sucesso`,
      currentPoints: newPoints,
      change: points,
    });
  } catch (error) {
    console.error('❌ Erro ao atualizar pontos:', error);
    res.status(500).json({ error: error.message });
  }
});

// ============ GERENCIAMENTO DE CUPONS ============
app.get('/api/coupons', authenticateAdmin, async (req, res) => {
  try {
    const { userId, activeOnly } = req.query;
    let query = db.collection('coupons');

    if (userId) {
      query = query.where('userId', '==', userId);
    }

    // Se activeOnly, filtrar por isUsed primeiro (mais eficiente)
    if (activeOnly === 'true') {
      query = query.where('isUsed', '==', false);
    }

    const snapshot = await query.orderBy('expiresAt', 'desc').get();
    let coupons = snapshot.docs.map(doc => {
      const data = doc.data();
      // Converter Timestamps para ISO strings
      return {
        id: doc.id,
        ...data,
        expiresAt: data.expiresAt?.toDate ? data.expiresAt.toDate().toISOString() : data.expiresAt,
        createdAt: data.createdAt?.toDate ? data.createdAt.toDate().toISOString() : data.createdAt,
        usedAt: data.usedAt?.toDate ? data.usedAt.toDate().toISOString() : data.usedAt,
      };
    });

    // Filtrar por expiração no código (já que não podemos ter múltiplos where com diferentes campos)
    if (activeOnly === 'true') {
      const now = new Date();
      coupons = coupons.filter(coupon => {
        try {
          const expiresAt = coupon.expiresAt ? new Date(coupon.expiresAt) : null;
          return expiresAt && expiresAt > now;
        } catch (e) {
          return false;
        }
      });
    }

    res.json({ coupons, total: coupons.length });
  } catch (error) {
    console.error('❌ Erro ao buscar cupons:', error);
    res.status(500).json({ error: error.message });
  }
});

// Helper para enviar notificação push
async function sendPushNotification(userId, title, body, data = {}) {
  try {
    // Buscar FCM token do usuário
    const userDoc = await db.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      console.log(`⚠️ Usuário ${userId} não encontrado para notificação`);
      return false;
    }

    const userData = userDoc.data();
    const fcmToken = userData.fcmToken;
    
    if (!fcmToken) {
      console.log(`⚠️ Usuário ${userId} não tem FCM token registrado`);
      return false;
    }

    // Enviar notificação usando Firebase Cloud Messaging
    const message = {
      token: fcmToken,
      notification: {
        title: title,
        body: body,
      },
      data: {
        type: data.type || 'general',
        ...data,
      },
      android: {
        priority: 'high',
      },
      apns: {
        headers: {
          'apns-priority': '10',
        },
      },
    };

    const response = await admin.messaging().send(message);
    console.log(`✅ Notificação enviada para ${userId}: ${response}`);
    return true;
  } catch (error) {
    console.error(`❌ Erro ao enviar notificação para ${userId}:`, error);
    return false;
  }
}

// Helper para enviar notificações para múltiplos usuários
async function sendBulkPushNotifications(userIds, title, body, data = {}) {
  const results = await Promise.allSettled(
    userIds.map(userId => sendPushNotification(userId, title, body, data))
  );
  
  const successCount = results.filter(r => r.status === 'fulfilled' && r.value).length;
  console.log(`📢 Notificações enviadas: ${successCount}/${userIds.length} com sucesso`);
  return { success: successCount, total: userIds.length };
}

app.post('/api/coupons', authenticateAdmin, async (req, res) => {
  try {
    const { userId, userIds, targetGroup, code, description, discountValue, establishmentId, establishmentName, expiresAt } = req.body;

    // Validar campos obrigatórios
    if (!code || !description || !discountValue || !establishmentId || !establishmentName || !expiresAt) {
      return res.status(400).json({ error: 'Campos obrigatórios: code, description, discountValue, establishmentId, establishmentName, expiresAt' });
    }

    // Determinar lista de usuários
    let targetUserIds = [];
    
    if (userIds && Array.isArray(userIds) && userIds.length > 0) {
      // Múltiplos usuários específicos
      targetUserIds = userIds;
    } else if (userId) {
      // Usuário único
      targetUserIds = [userId];
    } else if (targetGroup) {
      // Grupo de usuários (all, premium, bronze, silver, gold)
      const usersSnapshot = await db.collection('users').get();
      targetUserIds = usersSnapshot.docs
        .map(doc => {
          const data = doc.data();
          if (targetGroup === 'all') return doc.id;
          if (targetGroup === 'premium' && data.isPremium) return doc.id;
          if (targetGroup === 'bronze' && data.seal === 'bronze') return doc.id;
          if (targetGroup === 'silver' && data.seal === 'silver') return doc.id;
          if (targetGroup === 'gold' && data.seal === 'gold') return doc.id;
          return null;
        })
        .filter(id => id !== null);
    } else {
      return res.status(400).json({ error: 'Deve especificar userId, userIds (array) ou targetGroup' });
    }

    if (targetUserIds.length === 0) {
      return res.status(400).json({ error: 'Nenhum usuário encontrado para o grupo especificado' });
    }

    // Criar cupons para cada usuário
    const couponPromises = targetUserIds.map(async (uid) => {
      const coupon = {
        userId: uid,
        code: `${code}-${uid.substring(0, 8)}`, // Código único por usuário
        description,
        discountValue: parseFloat(discountValue),
        establishmentId,
        establishmentName,
        expiresAt: admin.firestore.Timestamp.fromDate(new Date(expiresAt)),
        isUsed: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        createdBy: req.user.uid,
      };

      const docRef = await db.collection('coupons').add(coupon);
      return { couponId: docRef.id, userId: uid };
    });

    const createdCoupons = await Promise.all(couponPromises);

    // Enviar notificações push
    const notificationTitle = '🎉 Novo Cupom Disponível!';
    const notificationBody = `${description} - ${discountValue}% de desconto em ${establishmentName}`;
    
    await sendBulkPushNotifications(
      targetUserIds,
      notificationTitle,
      notificationBody,
      {
        type: 'coupon',
        couponCode: code,
        establishmentId,
        establishmentName,
      }
    );

    res.json({ 
      success: true, 
      message: `${createdCoupons.length} cupom(ns) criado(s) com sucesso`,
      coupons: createdCoupons,
      notificationsSent: targetUserIds.length,
    });
  } catch (error) {
    console.error('❌ Erro ao criar cupom:', error);
    res.status(500).json({ error: error.message });
  }
});

// ============ GESTÃO DE USUÁRIOS PREMIUM ============
app.get('/api/users/:userId/premium', authenticateAdmin, async (req, res) => {
  try {
    const { userId } = req.params;
    const userDoc = await db.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      return res.status(404).json({ error: 'Usuário não encontrado' });
    }

    const userData = userDoc.data();
    res.json({
      isPremium: userData.isPremium || false,
      premiumExpiresAt: userData.premiumExpiresAt || null,
      points: userData.points || 0,
    });
  } catch (error) {
    console.error('❌ Erro ao buscar status Premium:', error);
    res.status(500).json({ error: error.message });
  }
});

app.put('/api/users/:userId/premium', authenticateAdmin, async (req, res) => {
  try {
    const { userId } = req.params;
    const { isPremium, months } = req.body;

    const userDoc = await db.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      return res.status(404).json({ error: 'Usuário não encontrado' });
    }

    const updates = {
      isPremium: isPremium || false,
      updatedBy: req.user.uid,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    if (isPremium && months) {
      const expiresAt = new Date();
      expiresAt.setMonth(expiresAt.getMonth() + parseInt(months));
      updates.premiumExpiresAt = admin.firestore.Timestamp.fromDate(expiresAt);
    } else if (!isPremium) {
      updates.premiumExpiresAt = null;
    }

    await db.collection('users').doc(userId).update(updates);

    res.json({ 
      success: true, 
      message: `Premium ${isPremium ? 'ativado' : 'desativado'} com sucesso`,
      ...updates,
    });
  } catch (error) {
    console.error('❌ Erro ao atualizar Premium:', error);
    res.status(500).json({ error: error.message });
  }
});

// ============ CAMPANHAS SAZONAIS ============
app.get('/api/campaigns', authenticateAdmin, async (req, res) => {
  try {
    const snapshot = await db.collection('campaigns').orderBy('createdAt', 'desc').get();
    const campaigns = snapshot.docs.map(doc => {
      const data = doc.data();
      // Converter Timestamps para ISO strings
      return {
        id: doc.id,
        ...data,
        startDate: data.startDate?.toDate ? data.startDate.toDate().toISOString() : data.startDate,
        endDate: data.endDate?.toDate ? data.endDate.toDate().toISOString() : data.endDate,
        createdAt: data.createdAt?.toDate ? data.createdAt.toDate().toISOString() : data.createdAt,
        updatedAt: data.updatedAt?.toDate ? data.updatedAt.toDate().toISOString() : data.updatedAt,
      };
    });

    res.json({ campaigns, total: campaigns.length });
  } catch (error) {
    console.error('❌ Erro ao buscar campanhas:', error);
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/campaigns', authenticateAdmin, async (req, res) => {
  try {
    const { title, description, startDate, endDate, targetAudience, rewards } = req.body;

    if (!title || !description || !startDate || !endDate) {
      return res.status(400).json({ error: 'Campos obrigatórios: title, description, startDate, endDate' });
    }

    const campaign = {
      title,
      description,
      startDate: admin.firestore.Timestamp.fromDate(new Date(startDate)),
      endDate: admin.firestore.Timestamp.fromDate(new Date(endDate)),
      targetAudience: targetAudience || 'all', // 'all', 'premium', 'bronze', 'silver', 'gold'
      rewards: rewards || [], // Array de recompensas (pontos, cupons, etc.)
      isActive: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      createdBy: req.user.uid,
    };

    const docRef = await db.collection('campaigns').add(campaign);
    res.json({ success: true, campaignId: docRef.id, ...campaign });
  } catch (error) {
    console.error('❌ Erro ao criar campanha:', error);
    res.status(500).json({ error: error.message });
  }
});

app.put('/api/campaigns/:campaignId/status', authenticateAdmin, async (req, res) => {
  try {
    const { campaignId } = req.params;
    const { isActive } = req.body;

    const campaignDoc = await db.collection('campaigns').doc(campaignId).get();
    if (!campaignDoc.exists) {
      return res.status(404).json({ error: 'Campanha não encontrada' });
    }

    const campaignData = campaignDoc.data();
    const now = admin.firestore.Timestamp.now();
    const startDate = campaignData.startDate?.toDate ? campaignData.startDate.toDate() : new Date(campaignData.startDate);
    const endDate = campaignData.endDate?.toDate ? campaignData.endDate.toDate() : new Date(campaignData.endDate);

    await db.collection('campaigns').doc(campaignId).update({
      isActive: isActive || false,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: req.user.uid,
    });

    // Se ativando a campanha e estiver dentro do período de vigência, enviar notificações
    if (isActive && now.toMillis() >= startDate.getTime() && now.toMillis() <= endDate.getTime()) {
      // Buscar usuários do público-alvo
      const usersSnapshot = await db.collection('users').get();
      const targetUserIds = usersSnapshot.docs
        .map(doc => {
          const data = doc.data();
          const targetAudience = campaignData.targetAudience || 'all';
          
          if (targetAudience === 'all') return doc.id;
          if (targetAudience === 'premium' && data.isPremium) return doc.id;
          if (targetAudience === 'bronze' && data.seal === 'bronze') return doc.id;
          if (targetAudience === 'silver' && data.seal === 'silver') return doc.id;
          if (targetAudience === 'gold' && data.seal === 'gold') return doc.id;
          return null;
        })
        .filter(id => id !== null);

      // Enviar notificações
      const notificationTitle = '🎉 Nova Campanha!';
      const notificationBody = campaignData.title || 'Nova campanha disponível';
      
      await sendBulkPushNotifications(
        targetUserIds,
        notificationTitle,
        notificationBody,
        {
          type: 'campaign',
          campaignId,
          title: campaignData.title,
          description: campaignData.description,
        }
      );

      console.log(`📢 Notificações de campanha enviadas para ${targetUserIds.length} usuários`);
    }

    res.json({ success: true, message: `Campanha ${isActive ? 'ativada' : 'desativada'} com sucesso` });
  } catch (error) {
    console.error('❌ Erro ao atualizar status da campanha:', error);
    res.status(500).json({ error: error.message });
  }
});

// ============ ESTATÍSTICAS ============
app.get('/api/stats', authenticateAdmin, async (req, res) => {
  try {
    console.log('📊 Buscando estatísticas...');
    
    const [usersSnapshot, establishmentsSnapshot, reviewsSnapshot, licensesSnapshot] = await Promise.all([
      db.collection('users').get().catch(err => {
        console.error('❌ Erro ao buscar usuários:', err);
        return { size: 0, docs: [] };
      }),
      db.collection('establishments').get().catch(err => {
        console.error('❌ Erro ao buscar estabelecimentos:', err);
        return { size: 0, docs: [] };
      }),
      db.collection('reviews').get().catch(err => {
        console.error('❌ Erro ao buscar avaliações:', err);
        return { size: 0, docs: [] };
      }),
      db.collection('licenses').get().catch(err => {
        console.error('❌ Erro ao buscar licenças:', err);
        return { size: 0, docs: [] };
      }),
    ]);

    const users = usersSnapshot.size || 0;
    const businesses = usersSnapshot.docs.filter(doc => {
      const data = doc.data();
      return data.type === 'business' || data.type === 'Business';
    }).length;
    const establishments = establishmentsSnapshot.size || 0;
    const reviews = reviewsSnapshot.size || 0;
    const licenses = licensesSnapshot.size || 0;
    const totalRevenue = licensesSnapshot.docs.reduce((sum, doc) => {
      const data = doc.data();
      return sum + (parseFloat(data.amount) || 0);
    }, 0);

    console.log(`✅ Estatísticas: ${users} usuários, ${establishments} estabelecimentos, ${reviews} avaliações`);

    res.json({
      users: {
        total: users,
        businesses,
        regular: users - businesses,
      },
      establishments,
      reviews,
      licenses: {
        total: licenses,
        revenue: totalRevenue,
      },
    });
  } catch (error) {
    console.error('❌ Erro ao buscar estatísticas:', error);
    res.status(500).json({ error: error.message, details: error.stack });
  }
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`🚀 Servidor admin rodando na porta ${PORT}`);
});

