# FastOrder - Sistema de Pedidos para Restaurantes

## Descripción

FastOrder es una aplicación móvil que permite a los clientes realizar pedidos en restaurantes escaneando un código QR de mesa, y a los trabajadores gestionar pedidos y generar códigos QR para las mesas.

## Requisitos Previos

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (versión 3.0.0 o superior)
- [Dart SDK](https://dart.dev/get-dart) (incluido con Flutter)
- [Android Studio](https://developer.android.com/studio) o [Xcode](https://developer.apple.com/xcode/) (para emuladores)
- Cuenta en [Supabase](https://supabase.com/) para el backend

## Instalación

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
   Crear un archivo `.env` en la raíz del proyecto con las credenciales de Supabase:
   ```
   SUPABASE_URL=tu_url_de_supabase
   SUPABASE_ANON_KEY=tu_clave_anonima_de_supabase
   ```

4. **Configurar Supabase**:
   - Crear las tablas necesarias (ver sección de configuración de base de datos)
   - Configurar autenticación

## Configuración de la Base de Datos

Ejecutar estos comandos SQL en Supabase:

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

## Ejecución de la Aplicación

### Para desarrollo:

```bash
flutter run
```

### Para construir APK (Android):

```bash
flutter build apk --release
```

### Para construir IPA (iOS):

```bash
flutter build ios --release
```

## Estructura del Proyecto

```
fast-order/
├── lib/
│   ├── main.dart          # Punto de entrada
│   ├── models/            # Modelos de datos
│   ├── screens/           # Pantallas de la aplicación
│   ├── services/          # Servicios y providers
│   └── widgets/           # Componentes reutilizables
├── android/               # Configuración específica de Android
├── ios/                   # Configuración específica de iOS
└── test/                  # Pruebas
```

## Dependencias Principales

- `supabase_flutter`: Conexión con backend Supabase
- `mobile_scanner`: Escaneo de códigos QR
- `qr_flutter`: Generación de códigos QR
- `provider`: Gestión de estado

## Configuración Adicional

### Para Android:

Asegúrate de tener en tu `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 33
    }
}
```

### Para iOS:

Actualiza el `Podfile` para usar iOS 11.0 o superior:
```ruby
platform :ios, '11.0'
```

## Solución de Problemas

Si encuentras problemas al ejecutar la aplicación:

1. Verifica que todas las dependencias estén instaladas:
   ```bash
   flutter doctor
   ```

2. Limpia el proyecto y reinstala dependencias:
   ```bash
   flutter clean
   flutter pub get
   ```

3. Para problemas con Supabase, verifica que:
   - Las tablas estén creadas correctamente
   - Las políticas RLS estén configuradas
   - Las variables de entorno sean correctas

## Contribución

Si deseas contribuir al proyecto:

1. Haz un fork del repositorio
2. Crea una rama con tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Haz commit de tus cambios (`git commit -m 'Añade nueva funcionalidad'`)
4. Haz push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## Licencia

Este proyecto está bajo la licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.
