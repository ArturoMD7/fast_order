Aquí tienes tu README mejorado, con formato más limpio, correcciones de estilo y una estructura más clara para que sea fácil de leer y atractivo en GitHub:

---

# 🍽️ FastOrder - Sistema de Pedidos para Restaurantes

[![Flutter](https://img.shields.io/badge/-Flutter-02569B?logo=flutter\&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/-Dart-0175C2?logo=dart\&logoColor=white)](https://dart.dev/)
[![Supabase](https://img.shields.io/badge/-Supabase-3ECF8E?logo=supabase\&logoColor=white)](https://supabase.com/)
[![Firebase](https://img.shields.io/badge/-Firebase-FFCA28?logo=firebase\&logoColor=black)](https://firebase.google.com/)

## 📖 Descripción

**FastOrder** es una aplicación móvil para restaurantes que permite a los clientes realizar pedidos escaneando un **código QR** en la mesa, y a los trabajadores gestionar dichos pedidos y generar nuevos códigos QR para las mesas.

---

## 📋 Requisitos Previos

* [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.0.0 o superior)
* [Dart SDK](https://dart.dev/get-dart) (incluido con Flutter)
* [Android Studio](https://developer.android.com/studio) o [Xcode](https://developer.apple.com/xcode/)
* Cuenta en [Supabase](https://supabase.com/) para el backend

---

## ⚙️ Instalación

1. **Clonar el repositorio**:

   ```bash
   git clone https://github.com/tu-usuario/fast-order.git
   cd fast-order
   ```

2. **Instalar dependencias**:

   ```bash
   flutter pub get
   ```

3. **Configurar variables de entorno**:
   Crear un archivo `.env` en la raíz:

   ```env
   SUPABASE_URL=tu_url_de_supabase
   SUPABASE_ANON_KEY=tu_clave_anonima_de_supabase
   ```

4. **Configurar Supabase**:

   * Crear las tablas necesarias (ver sección de **Base de Datos**)
   * Configurar autenticación y políticas RLS

---

## 🗄️ Configuración de la Base de Datos

Ejecuta este script SQL en Supabase:

```sql
-- Tabla de Restaurantes
CREATE TABLE Restaurantes (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR NOT NULL,
  descripcion TEXT,
  token_qr_actual VARCHAR,
  fecha_qr_generado TIMESTAMP,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla de Usuarios
CREATE TABLE Usuarios (
  id UUID PRIMARY KEY DEFAULT auth.uid(),
  nombre VARCHAR NOT NULL,
  apellidos VARCHAR,
  email VARCHAR NOT NULL UNIQUE,
  rol VARCHAR NOT NULL, -- 'cliente', 'trabajador', 'administrador'
  id_restaurante INTEGER REFERENCES Restaurantes(id),
  token_qr_actual VARCHAR,
  fecha_qr_generado TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla de Tokens QR
CREATE TABLE tokens_qr (
  id SERIAL PRIMARY KEY,
  token TEXT NOT NULL UNIQUE,
  mesa TEXT NOT NULL,
  id_restaurante INTEGER NOT NULL REFERENCES Restaurantes(id),
  expira_en TIMESTAMPTZ NOT NULL,
  activo BOOLEAN DEFAULT true,
  creado_por UUID REFERENCES Usuarios(id),
  creado_en TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 🚀 Ejecución

**Desarrollo**:

```bash
flutter run
```

**Construir APK (Android)**:

```bash
flutter build apk --release
```

**Construir IPA (iOS)**:

```bash
flutter build ios --release
```

---

## 📂 Estructura del Proyecto

```
fast-order/
├── lib/
│   ├── main.dart          # Punto de entrada
│   ├── models/            # Modelos de datos
│   ├── screens/           # Pantallas de la app
│   ├── services/          # Servicios y lógica
│   └── widgets/           # Componentes UI
├── android/               # Configuración Android
├── ios/                   # Configuración iOS
└── test/                  # Pruebas
```

---

## 📦 Dependencias Principales

* [`supabase_flutter`](https://pub.dev/packages/supabase_flutter) — Backend Supabase
* [`mobile_scanner`](https://pub.dev/packages/mobile_scanner) — Escaneo de QR
* [`qr_flutter`](https://pub.dev/packages/qr_flutter) — Generación de QR
* [`provider`](https://pub.dev/packages/provider) — Gestión de estado

---

## ⚠️ Configuración Adicional

**Android**:

```gradle
android {
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 33
    }
}
```

**iOS**:

```ruby
platform :ios, '11.0'
```

---

## 🛠️ Solución de Problemas

1. Verifica dependencias:

   ```bash
   flutter doctor
   ```

2. Limpia y reinstala:

   ```bash
   flutter clean
   flutter pub get
   ```

3. Comprueba en Supabase:

   * Tablas creadas
   * Políticas RLS activas
   * Variables `.env` correctas

---

## 🤝 Contribución

1. Haz **fork**
2. Crea rama:

   ```bash
   git checkout -b feature/nueva-funcionalidad
   ```
3. Commit:

   ```bash
   git commit -m "Añade nueva funcionalidad"
   ```
4. Push y **Pull Request**

---

## 📄 Licencia

Este proyecto está bajo la licencia **MIT** — ver [LICENSE](LICENSE).

---
