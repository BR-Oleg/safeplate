# 📱 Testar iOS no Windows (Sem iPhone Físico)

Infelizmente, **não existe emulador oficial de iOS para Windows**. A Apple só permite o iOS Simulator no macOS.

Mas temos uma solução! 🎯

---

## ✅ Solução: GitHub Actions + iOS Simulator

Vamos usar o **GitHub Actions** para rodar o app no **iOS Simulator** (que roda no Mac da nuvem) e gerar **screenshots/vídeos** para você visualizar.

---

## 🚀 Como Usar

### **Passo 1: Executar Teste no Simulador**

1. Acesse seu repositório no GitHub
2. Vá em **Actions**
3. Selecione **"Test iOS App in Simulator"**
4. Clique em **"Run workflow"** → **"Run workflow"**
5. Aguarde ~5-10 minutos

### **Passo 2: Ver Screenshots**

1. Após o workflow completar, clique nele
2. Role até **"Artifacts"**
3. Baixe **"ios-simulator-screenshots-X"**
4. Extraia o ZIP
5. Veja as screenshots do app rodando no simulador!

---

## 📸 O Que Você Vai Receber

- ✅ **Screenshots** do app rodando no iPhone 15 Pro Simulator
- ✅ **Logs** do simulador (para debug)
- ✅ **Confirmação** de que o app compila e roda

---

## ⚠️ Limitações

- ❌ Não é um emulador interativo (você não pode clicar)
- ✅ Mas você vê como o app fica visualmente
- ✅ Confirma que compila sem erros
- ✅ Pode ver diferentes telas via screenshots

---

## 🎥 Alternativa: Gravar Vídeo

Se quiser ver o app em ação, podemos habilitar a gravação de vídeo:

1. Edite `.github/workflows/ios-simulator-test.yml`
2. Mude `if: false` para `if: true` na seção "Record video"
3. Execute o workflow novamente
4. Você receberá um vídeo `.mp4` do app rodando!

---

## 🔄 Workflow Automático

O workflow está configurado para rodar automaticamente quando você faz push para `main` ou `master`.

Se quiser rodar manualmente:
- **Actions** → **Test iOS App in Simulator** → **Run workflow**

---

## 📊 Comparação de Opções

| Método | Custo | Interatividade | Visualização | Recomendado |
|--------|-------|----------------|--------------|-------------|
| **GitHub Actions + Screenshots** | Grátis | ❌ | ✅ Screenshots | ✅ Sim |
| **GitHub Actions + Vídeo** | Grátis | ❌ | ✅ Vídeo | ✅ Sim |
| **Mac na Nuvem** | $20-50/mês | ✅ | ✅ Total | ⚠️ Caro |
| **Emulador Windows** | Grátis | ❌ | ❌ Não funciona | ❌ Não existe |

---

## 🎯 Recomendação

1. **Use GitHub Actions** para ver screenshots/vídeos (grátis)
2. **Teste funcionalidades críticas** no iPhone físico do cliente
3. **Use Sideloadly** para instalar no iPhone do cliente

---

## 🆘 Problemas?

- **Workflow falha?** → Verifique os logs no GitHub Actions
- **Screenshots não aparecem?** → Verifique se o app compilou corretamente
- **Quer mais screenshots?** → Edite o workflow para tirar mais screenshots

---

## ✅ Próximos Passos

1. Execute o workflow **"Test iOS App in Simulator"**
2. Baixe os screenshots
3. Revise visualmente
4. Se estiver OK, compile o IPA e envie para o cliente

---

**🎉 Agora você pode "testar" iOS no Windows via screenshots/vídeos!**

