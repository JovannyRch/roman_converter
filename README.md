# Roman ↔ Arabic Converter

Una aplicación móvil desarrollada en **Flutter** que permite convertir números **romanos a arábigos** y **arábigos a romanos**.  
La app incluye un diseño moderno con colores oscuros y ofrece dos modos de uso:

- **Conversión directa** → muestra el resultado inmediato.
- **Conversión paso a paso** → explica el proceso de la conversión de forma detallada.

---

## ✨ Características

- 🎨 Interfaz moderna y elegante con colores oscuros.
- 🔁 Conversión en ambos sentidos (romano ↔ arábigo).
- 📖 Modo paso a paso para entender cómo se realiza la conversión.
- ⚡ Respuesta rápida y precisa.
- 📱 Compatible con Android (iOS próximamente).
- 📢 **Publicidad integrada** con banners en ambas pantallas e intersticiales cada 4 conversiones.

---

## 🛠️ Tecnologías utilizadas

- [Flutter](https://flutter.dev/)
- [Dart](https://dart.dev/)
- Material Design & Dark Theme
- [Google Mobile Ads](https://pub.dev/packages/google_mobile_ads) para monetización

---

## 📢 Configuración de Anuncios

La aplicación incluye:

- **Banner Ads**: Presentes en la parte inferior de ambas pantallas (conversión directa y paso a paso)
- **Interstitial Ads**: Se muestran automáticamente cada 4 conversiones realizadas
- **IDs de prueba**: Configurado con IDs de prueba de AdMob para desarrollo

### Para producción:

1. Reemplaza los IDs de prueba en `lib/services/ad_service.dart` con tus IDs reales de AdMob
2. Actualiza el `APPLICATION_ID` en `android/app/src/main/AndroidManifest.xml` con tu ID real de AdMob
