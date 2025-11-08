# ✅ CORRIGIDO: Mapbox API v2.12.0

## 🎯 Problema

Na versão 2.12.0 do Mapbox, a API mudou:
- **Antes:** `Point(...).toJson()` retornava `Map<String, dynamic>`
- **Agora:** `Point` é usado diretamente, sem `.toJson()`

## ✅ Correção Aplicada

**Removido `.toJson()` em dois lugares:**

1. **Linha 73** - `geometry` em `PointAnnotationOptions`
   - **Antes:** `geometry: Point(...).toJson()`
   - **Depois:** `geometry: Point(...)`

2. **Linha 141** - `center` em `CameraOptions`
   - **Antes:** `center: Point(...).toJson()`
   - **Depois:** `center: Point(...)`

## 📝 Arquivo Modificado

- ✅ `lib/widgets/mapbox_map_widget.dart`
  - Removido `.toJson()` das linhas 73 e 141

## 🚀 Agora Execute:

```bash
flutter run -d ZF524HHBBN
```

Os erros de tipo devem estar resolvidos!

## ✅ Status

- ✅ Mapbox atualizado para 2.12.0
- ✅ API corrigida (removido `.toJson()`)
- ✅ Código compatível com nova versão
- ✅ Compilação iniciada em background

---

**Execute `flutter run` agora!** 🚀

