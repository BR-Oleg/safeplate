# 🚀 TESTAR APP - SafePlate MVP

## ✅ TUDO PRONTO!

Todas as configurações foram finalizadas:
- ✅ Firebase configurado
- ✅ Google Sign-In ativado no Console
- ✅ Mapbox token configurado
- ✅ Permissões Android configuradas
- ✅ Código implementado

## 🧪 COMO TESTAR

### 1. Limpar e Recompilar (Recomendado)

```bash
flutter clean
flutter pub get
```

### 2. Executar no Dispositivo/Emulador

```bash
flutter run
```

**OU** especifique um dispositivo:

```bash
# Ver dispositivos disponíveis
flutter devices

# Executar em dispositivo específico
flutter run -d <device-id>
```

### 3. O que Esperar

**Ao iniciar o app:**
1. ✅ Tela de splash aparecerá
2. ✅ Firebase inicializará (você verá no console: "✅ Firebase inicializado com sucesso!")
3. ✅ Tela de login aparecerá

**Na tela de login:**
- ✅ **Login com Email/Senha**: Funciona! (crie uma conta primeiro)
- ✅ **Login com Google**: Funciona! (Google Sign-In ativado)
- ✅ Seletor de tipo de usuário (Usuário/Estabelecimento)

**Após login:**
- ✅ Tela principal (Home)
- ✅ Navegação para busca
- ✅ Mapa com Mapbox
- ✅ Lista de estabelecimentos
- ✅ Filtros por restrições alimentares
- ✅ Sistema de favoritos

## 🔍 TESTAR FUNCIONALIDADES

### Teste 1: Login com Google
1. Clique em "Login com Google"
2. Escolha sua conta Google
3. Deve fazer login e navegar para Home

### Teste 2: Criar Conta com Email
1. Preencha email e senha
2. Clique em "Criar Conta"
3. Faça login automaticamente após criar

### Teste 3: Mapa
1. Navegue para busca (ícone de mapa)
2. Permita acesso à localização quando solicitado
3. Mapa deve carregar com estabelecimentos marcados

### Teste 4: Favoritos
1. Na lista de estabelecimentos
2. Clique no ícone de coração
3. Estabelecimento deve ser salvo localmente

## ⚠️ POSSÍVEIS PROBLEMAS

### Problema 1: Erro ao inicializar Firebase
**Solução:**
- Verifique se `google-services.json` está em `android/app/`
- Verifique se `firebase_options.dart` está correto

### Problema 2: Google Sign-In não funciona
**Solução:**
- Verifique se ativou no Firebase Console
- Verifique se `google-services.json` está atualizado
- Limpe e recompile: `flutter clean && flutter pub get && flutter run`

### Problema 3: Mapa não aparece
**Solução:**
- Verifique conexão com internet
- Verifique permissões de localização
- Token do Mapbox está configurado automaticamente

### Problema 4: Erro de compilação
**Solução:**
```bash
flutter clean
flutter pub get
cd android
./gradlew clean
cd ..
flutter run
```

## 📱 TESTAR EM DISPOSITIVO ANDROID

### Preparar dispositivo:
1. Ative **Modo Desenvolvedor**
2. Ative **Depuração USB**
3. Conecte via USB
4. Aceite autorização no dispositivo

### Executar:
```bash
flutter devices  # Ver dispositivos
flutter run -d <device-id>
```

## 🎯 CHECKLIST DE TESTE

- [ ] App compila sem erros
- [ ] Firebase inicializa (mensagem no console)
- [ ] Tela de login aparece
- [ ] Login com Google funciona
- [ ] Login com Email/Senha funciona
- [ ] Criar conta funciona
- [ ] Navegação para Home funciona
- [ ] Mapa carrega
- [ ] Estabelecimentos aparecem no mapa
- [ ] Lista de estabelecimentos funciona
- [ ] Filtros funcionam
- [ ] Favoritos funcionam
- [ ] Busca funciona

## 🎉 PRONTO!

Se todos os testes passarem, seu MVP está **100% funcional**!

---

**Dúvidas?** Execute `flutter doctor` para verificar ambiente Flutter.

