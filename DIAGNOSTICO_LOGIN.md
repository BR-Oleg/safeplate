# 🔍 Diagnóstico de Problemas de Login/Cadastro

Este documento ajuda a identificar e resolver problemas com login e cadastro usando email e senha.

## ✅ Correções Implementadas

1. **Validação melhorada** de email e senha antes de tentar login/cadastro
2. **Logs detalhados** para identificar onde está falhando
3. **Tratamento de erros** mais robusto com mensagens específicas
4. **Timeout** configurado para evitar travamentos
5. **Continuidade do login** mesmo se Firestore falhar

## 🔍 Como Diagnosticar

### 1. Verificar Logs do App

Execute o app e tente fazer login/cadastro. Procure por estas mensagens nos logs:

**Login:**
- `🔐 Tentando fazer login com email: ...`
- `✅ Login Firebase bem-sucedido: ...`
- `📥 Carregando dados do usuário do Firestore...`
- `✅ Dados do usuário carregados com sucesso`
- `✅ Login completo com sucesso`

**Cadastro:**
- `📝 Tentando criar conta com email: ...`
- `✅ Cadastro Firebase bem-sucedido: ...`
- `💾 Salvando novo usuário no Firestore...`
- `✅ Novo usuário salvo no Firestore com sucesso`
- `✅ Cadastro completo com sucesso`

**Erros:**
- `❌ Erro Firebase Auth: ...` - Problema com Firebase Authentication
- `⚠️ Erro ao carregar dados do Firestore` - Problema com Firestore
- `❌ Timeout no login` - Problema de conexão

### 2. Verificar Firebase Console

1. Acesse: https://console.firebase.google.com
2. Selecione seu projeto
3. Vá para **Authentication** → **Users**
4. Verifique se o usuário foi criado

### 3. Verificar Firestore

1. No Firebase Console, vá para **Firestore Database**
2. Verifique a coleção `users`
3. Veja se o documento do usuário existe

### 4. Verificar Configuração Firebase

1. Verifique se `google-services.json` está em `android/app/`
2. Verifique se `GoogleService-Info.plist` está em `ios/Runner/` (se testando iOS)
3. Verifique se `firebase_options.dart` está atualizado

## 🐛 Problemas Comuns e Soluções

### Problema 1: "Email inválido"

**Causa**: Email não contém "@" ou está vazio

**Solução**: 
- Verifique se o email está correto
- A validação agora mostra mensagem específica

### Problema 2: "Senha muito fraca"

**Causa**: Senha tem menos de 6 caracteres

**Solução**:
- Use senha com pelo menos 6 caracteres
- A validação agora mostra mensagem específica

### Problema 3: "Erro de conexão"

**Causa**: Problema de internet ou Firebase não configurado

**Solução**:
- Verifique sua conexão com internet
- Verifique se Firebase está configurado corretamente
- Verifique se `google-services.json` está no lugar certo

### Problema 4: "Este email já está sendo usado"

**Causa**: Tentando cadastrar email que já existe

**Solução**:
- Use outro email
- Ou faça login com esse email

### Problema 5: "Nenhum usuário encontrado"

**Causa**: Tentando fazer login com email que não existe

**Solução**:
- Verifique se o email está correto
- Ou crie uma conta primeiro

### Problema 6: "Operação não permitida"

**Causa**: Firebase Authentication não está habilitado para Email/Password

**Solução**:
1. Acesse Firebase Console
2. Authentication → Sign-in method
3. Habilite "Email/Password"
4. Salve

### Problema 7: Login trava (loading infinito)

**Causa**: Firestore não responde ou timeout

**Solução**:
- O código agora continua mesmo se Firestore falhar
- Verifique os logs para ver onde está travando
- Verifique se Firestore está habilitado

## 🔧 Verificar Configuração Firebase

### 1. Habilitar Email/Password Authentication

1. Acesse: https://console.firebase.google.com
2. Selecione seu projeto
3. Vá para **Authentication** → **Sign-in method**
4. Clique em **Email/Password**
5. Habilite **Enable**
6. Clique em **Save**

### 2. Verificar Firestore

1. No Firebase Console, vá para **Firestore Database**
2. Verifique se o banco está criado
3. Verifique as regras de segurança:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 3. Verificar google-services.json

1. Verifique se o arquivo existe em `android/app/google-services.json`
2. Verifique se o `package_name` está correto
3. Verifique se o `SHA-1` está configurado no Firebase

## 📱 Testar Agora

1. **Execute o app**
2. **Tente fazer login** com um email que já existe
3. **Ou crie uma nova conta**
4. **Veja os logs** no console para identificar problemas

## 📊 Logs Esperados (Sucesso)

```
🔐 Tentando fazer login com email: teste@exemplo.com
✅ Login Firebase bem-sucedido: abc123...
📥 Carregando dados do usuário do Firestore...
✅ Dados do usuário carregados com sucesso
✅ Login completo com sucesso
```

## 📊 Logs de Erro

Se aparecer:
```
❌ Erro Firebase Auth: invalid-email - The email address is badly formatted.
```

Significa que o email está inválido. A validação agora previne isso.

## 🆘 Se Ainda Não Funcionar

1. **Verifique os logs** completos do app
2. **Verifique Firebase Console** → Authentication → Users
3. **Verifique Firestore** → users collection
4. **Teste com outro email**
5. **Verifique internet**

---

**Importante**: Os logs agora são muito mais detalhados. Execute o app e veja os logs para identificar exatamente onde está o problema!


