// Script para verificar se há dados no Firestore e listar todas as coleções
const dotenv = require('dotenv');
const admin = require('firebase-admin');

dotenv.config();

console.log('🔍 Verificando dados no Firestore...\n');

if (!process.env.FIREBASE_PROJECT_ID || !process.env.FIREBASE_PRIVATE_KEY || !process.env.FIREBASE_CLIENT_EMAIL) {
  console.error('❌ Variáveis de ambiente não configuradas!');
  process.exit(1);
}

try {
  const serviceAccount = {
    projectId: process.env.FIREBASE_PROJECT_ID,
    privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
  };

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });

  console.log('✅ Firebase Admin SDK inicializado\n');
  console.log('📋 Projeto:', process.env.FIREBASE_PROJECT_ID);
  console.log('');

  const db = admin.firestore();
  
  // Listar todas as coleções
  console.log('🔍 Verificando coleções existentes...\n');
  
  // Tentar acessar as coleções que o app usa
  const collections = ['users', 'establishments', 'reviews'];
  
  async function checkCollections() {
    for (const collectionName of collections) {
      try {
        const snapshot = await db.collection(collectionName).limit(5).get();
      console.log(`📦 ${collectionName}:`);
      console.log(`   Total de documentos: ${snapshot.size} (mostrando até 5)`);
      
      if (snapshot.size > 0) {
        snapshot.docs.forEach((doc, index) => {
          const data = doc.data();
          console.log(`   [${index + 1}] ID: ${doc.id}`);
          if (collectionName === 'users') {
            console.log(`       Email: ${data.email || 'N/A'}`);
            console.log(`       Nome: ${data.name || 'N/A'}`);
            console.log(`       Tipo: ${data.type || 'N/A'}`);
          } else if (collectionName === 'establishments') {
            console.log(`       Nome: ${data.name || 'N/A'}`);
            console.log(`       Categoria: ${data.category || 'N/A'}`);
            console.log(`       Dono: ${data.ownerId || 'N/A'}`);
          } else if (collectionName === 'reviews') {
            console.log(`       Estabelecimento: ${data.establishmentId || 'N/A'}`);
            console.log(`       Usuário: ${data.userId || 'N/A'}`);
            console.log(`       Avaliação: ${data.rating || 'N/A'}`);
          }
        });
      } else {
        console.log(`   ⚠️ Coleção vazia ou não existe`);
      }
      console.log('');
    } catch (error) {
      if (error.code === 5) {
        console.log(`❌ ${collectionName}: NOT_FOUND - Coleção não existe ou banco de dados não foi criado`);
      } else if (error.code === 7) {
        console.log(`❌ ${collectionName}: PERMISSION_DENIED - Sem permissão para acessar`);
        console.log(`   💡 Habilite o Firestore API: https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=${process.env.FIREBASE_PROJECT_ID}`);
      } else {
        console.log(`❌ ${collectionName}: ${error.message} (código: ${error.code})`);
      }
      console.log('');
    }
    
    // Tentar listar todas as coleções (pode não funcionar se o banco não existe)
    console.log('🔍 Tentando listar todas as coleções do projeto...\n');
    try {
      // Nota: Firestore Admin SDK não tem método direto para listar coleções
      // Mas podemos tentar acessar algumas coleções comuns
      const commonCollections = ['users', 'establishments', 'reviews', 'licenses', 'appSettings'];
      const existingCollections = [];
      
      for (const colName of commonCollections) {
        try {
          const testSnapshot = await db.collection(colName).limit(1).get();
          existingCollections.push(colName);
        } catch (e) {
          // Ignorar erros
        }
      }
    
    if (existingCollections.length > 0) {
      console.log('✅ Coleções encontradas:', existingCollections.join(', '));
    } else {
      console.log('⚠️ Nenhuma coleção encontrada');
      console.log('💡 Isso pode significar que:');
      console.log('   1. O Firestore Database não foi criado ainda');
      console.log('   2. As coleções estão vazias');
      console.log('   3. Há um problema de permissões');
    }
    } catch (error) {
      console.log('❌ Erro ao listar coleções:', error.message);
    }
    
    console.log('\n✅ Verificação concluída!');
    console.log('\n💡 Próximos passos:');
    console.log('   1. Se todas as coleções retornaram NOT_FOUND:');
    console.log('      → Crie o Firestore Database no Firebase Console');
    console.log('      → https://console.firebase.google.com/project/' + process.env.FIREBASE_PROJECT_ID + '/firestore');
    console.log('   2. Se retornou PERMISSION_DENIED:');
    console.log('      → Habilite o Firestore API');
    console.log('      → https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=' + process.env.FIREBASE_PROJECT_ID);
    console.log('   3. Se as coleções estão vazias:');
    console.log('      → Isso é normal se o app ainda não salvou dados');
    console.log('      → Crie um estabelecimento pelo app e teste novamente');
    
    process.exit(0);
  }
  
  checkCollections();
} catch (error) {
  console.error('❌ Erro ao inicializar:', error.message);
  process.exit(1);
}

