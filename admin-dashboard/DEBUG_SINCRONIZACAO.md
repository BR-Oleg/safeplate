# 🔍 Debug - Sincronização do Dashboard

## Problemas Comuns e Soluções

### 1. Dashboard não mostra usuários/estabelecimentos

**Possíveis causas:**

#### A) Backend não está rodando
- **Solução:** Certifique-se de que o backend está rodando na porta 3001
- **Verificar:** Abra `http://localhost:3001/api/maintenance/status` no navegador (deve retornar JSON)

#### B) Firebase Admin SDK não configurado corretamente
- **Solução:** Verifique o arquivo `.env` no backend
- **Verificar:** As credenciais devem estar corretas:
  ```
  FIREBASE_PROJECT_ID=seu-project-id
  FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
  FIREBASE_CLIENT_EMAIL=firebase-adminsdk@seu-projeto.iam.gserviceaccount.com
  ```

#### C) Permissões do Firestore
- **Solução:** Verifique as regras de segurança do Firestore
- **Verificar:** No Firebase Console → Firestore Database → Regras
- **Temporariamente para teste:** Use regras permissivas:
  ```
  rules_version = '2';
  service cloud.firestore {
    match /databases/{database}/documents {
      match /{document=**} {
        allow read, write: if request.auth != null;
      }
    }
  }
  ```
  ⚠️ **ATENÇÃO:** Isso é apenas para desenvolvimento! Em produção, use regras mais restritivas.

#### D) Coleções não existem no Firestore
- **Solução:** Verifique se as coleções `users`, `establishments`, `reviews` existem
- **Verificar:** No Firebase Console → Firestore Database → Dados
- **Criar:** Se não existirem, elas serão criadas automaticamente quando o app Flutter salvar dados

### 2. Erro "Token inválido"

**Possíveis causas:**

#### A) Token expirado
- **Solução:** Faça logout e login novamente no dashboard

#### B) Backend em modo desenvolvimento
- **Solução:** O backend agora permite acesso em modo desenvolvimento mesmo com token inválido
- **Verificar:** Veja os logs do backend para confirmar

### 3. Texto branco não aparece

**Solução aplicada:**
- ✅ CSS atualizado para forçar texto preto
- ✅ Removido dark mode automático
- ✅ Cor de fundo clara

**Se ainda não funcionar:**
- Limpe o cache do navegador (Ctrl+Shift+Delete)
- Recarregue a página (Ctrl+F5)

## Como Verificar se Está Funcionando

### 1. Verificar Backend
```bash
# No terminal do backend, você deve ver:
🚀 Servidor admin rodando na porta 3001
```

### 2. Verificar Logs
Quando você acessar o dashboard, o backend deve mostrar logs como:
```
👥 Buscando usuários...
📦 Encontrados X documentos na coleção 'users'
✅ Retornando X usuários
```

### 3. Verificar no Navegador
1. Abra o Console do Desenvolvedor (F12)
2. Vá na aba "Network" (Rede)
3. Recarregue a página
4. Procure por requisições para `/api/stats`, `/api/users`, `/api/establishments`
5. Clique em cada uma e veja a resposta

### 4. Testar API Diretamente
Abra no navegador (após fazer login e copiar o token):
```
http://localhost:3001/api/stats
```
Com o header:
```
Authorization: Bearer SEU_TOKEN_AQUI
```

## Próximos Passos

1. ✅ Verificar se backend está rodando
2. ✅ Verificar logs do backend
3. ✅ Verificar console do navegador
4. ✅ Verificar Firebase Console (coleções existem?)
5. ✅ Verificar permissões do Firestore

Se ainda não funcionar, me envie:
- Logs do backend
- Erros do console do navegador
- Screenshot do Firebase Console mostrando as coleções


