// Script para testar a conexão com o Firebase
require('dotenv').config();
const admin = require('firebase-admin');

console.log('🔍 Testando conexão com Firebase...\n');

// Verificar variáveis de ambiente
console.log('📋 Verificando variáveis de ambiente:');
console.log('  FIREBASE_PROJECT_ID:', process.env.FIREBASE_PROJECT_ID ? '✅ Configurado' : '❌ Não configurado');
console.log('  FIREBASE_CLIENT_EMAIL:', process.env.FIREBASE_CLIENT_EMAIL ? '✅ Configurado' : '❌ Não configurado');
console.log('  FIREBASE_PRIVATE_KEY:', process.env.FIREBASE_PRIVATE_KEY ? '✅ Configurado (oculto)' : '❌ Não configurado');
console.log('');

if (!process.env.FIREBASE_PROJECT_ID || !process.env.FIREBASE_PRIVATE_KEY || !process.env.FIREBASE_CLIENT_EMAIL) {
  console.error('❌ ERRO: Variáveis de ambiente não configuradas!');
  console.error('Crie um arquivo .env na pasta backend com:');
  console.error('');
  console.error('FIREBASE_PROJECT_ID=seu-project-id');
  console.error('FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\\n...\\n-----END PRIVATE KEY-----\\n"');
  console.error('FIREBASE_CLIENT_EMAIL=firebase-adminsdk@seu-projeto.iam.gserviceaccount.com');
  process.exit(1);
}

// Tentar inicializar Firebase
try {
  const serviceAccount = {
    projectId: process.env.FIREBASE_PROJECT_ID,
    privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
  };

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });

  console.log('✅ Firebase Admin SDK inicializado com sucesso!\n');

  // Testar conexão com Firestore
  const db = admin.firestore();
  
  console.log('🔍 Testando conexão com Firestore...');
  db.collection('test').limit(1).get()
    .then(() => {
      console.log('✅ Conexão com Firestore funcionando!\n');
      
      // Verificar coleções existentes
      console.log('📦 Verificando coleções existentes...');
      Promise.all([
        db.collection('users').limit(1).get(),
        db.collection('establishments').limit(1).get(),
        db.collection('reviews').limit(1).get(),
      ])
      .then(([users, establishments, reviews]) => {
        console.log('  users:', users.size > 0 ? `✅ ${users.size} documento(s)` : '⚠️ Vazia ou não existe');
        console.log('  establishments:', establishments.size > 0 ? `✅ ${establishments.size} documento(s)` : '⚠️ Vazia ou não existe');
        console.log('  reviews:', reviews.size > 0 ? `✅ ${reviews.size} documento(s)` : '⚠️ Vazia ou não existe');
        console.log('\n✅ Teste concluído com sucesso!');
        process.exit(0);
      })
      .catch((error) => {
        console.error('❌ Erro ao verificar coleções:', error.message);
        console.error('Isso pode ser normal se as coleções ainda não existem.');
        process.exit(0);
      });
    })
    .catch((error) => {
      console.error('❌ Erro ao conectar com Firestore:', error.message);
      console.error('\nPossíveis causas:');
      console.error('  1. Credenciais do Firebase incorretas');
      console.error('  2. Projeto Firebase não existe');
      console.error('  3. Firestore não está habilitado no projeto');
      console.error('  4. Regras de segurança do Firestore bloqueando acesso');
      process.exit(1);
    });
} catch (error) {
  console.error('❌ Erro ao inicializar Firebase Admin SDK:', error.message);
  console.error('\nVerifique:');
  console.error('  1. Se o FIREBASE_PRIVATE_KEY está correto (com quebras de linha \\n)');
  console.error('  2. Se o FIREBASE_CLIENT_EMAIL está correto');
  console.error('  3. Se o FIREBASE_PROJECT_ID está correto');
  process.exit(1);
}


