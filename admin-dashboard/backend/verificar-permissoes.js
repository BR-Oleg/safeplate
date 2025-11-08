// Script para verificar permissões da conta de serviço
require('dotenv').config();
const admin = require('firebase-admin');

console.log('🔍 Verificando permissões da conta de serviço...\n');

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
  console.log('📋 Informações da conta de serviço:');
  console.log('  Project ID:', process.env.FIREBASE_PROJECT_ID);
  console.log('  Client Email:', process.env.FIREBASE_CLIENT_EMAIL);
  console.log('');

  const db = admin.firestore();
  
  // Tentar ler uma coleção que já existe (se o app está usando)
  console.log('🔍 Tentando acessar coleções existentes...\n');
  
  Promise.all([
    db.collection('users').limit(1).get().then(snap => ({ name: 'users', count: snap.size, exists: true })).catch(err => ({ name: 'users', error: err.message })),
    db.collection('establishments').limit(1).get().then(snap => ({ name: 'establishments', count: snap.size, exists: true })).catch(err => ({ name: 'establishments', error: err.message })),
    db.collection('reviews').limit(1).get().then(snap => ({ name: 'reviews', count: snap.size, exists: true })).catch(err => ({ name: 'reviews', error: err.message })),
  ])
  .then(results => {
    console.log('📦 Resultados:');
    results.forEach(result => {
      if (result.error) {
        console.log(`  ${result.name}: ❌ ${result.error}`);
      } else {
        console.log(`  ${result.name}: ✅ Acessível (${result.count} documento(s))`);
      }
    });
    console.log('\n✅ Verificação concluída!');
    process.exit(0);
  })
  .catch(error => {
    console.error('❌ Erro geral:', error.message);
    console.error('\n💡 Possíveis causas:');
    console.error('  1. A conta de serviço não tem permissões no projeto');
    console.error('  2. As credenciais estão incorretas');
    console.error('  3. O Firestore API precisa ser habilitado (mesmo que o app use)');
    console.error('\n🔧 Soluções:');
    console.error('  1. Verifique se a conta de serviço tem papel de "Editor" ou "Proprietário" no projeto');
    console.error('  2. Gere uma nova chave privada no Firebase Console');
    console.error('  3. Habilite o Firestore API mesmo que o app já use (pode ser necessário para Admin SDK)');
    process.exit(1);
  });
} catch (error) {
  console.error('❌ Erro ao inicializar:', error.message);
  process.exit(1);
}


