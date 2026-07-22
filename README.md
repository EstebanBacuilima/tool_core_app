# tool-core-app

App móvil **Flutter** para la gestión de talleres mecánicos. Es el cliente
móvil de la API [tool-core](../tool_core_backend) (repo hermano). La
administración de empresas, talleres y usuarios vive en un panel web aparte:
esta app asume que el usuario y su empresa ya existen.

## Requisitos

- Flutter 3.44+ (Dart 3.12+)
- El backend corriendo en local (`dotnet run` en `../tool_core_backend`,
  expone `http://localhost:5125`)

## Primeros pasos

```bash
flutter pub get          # también regenera las localizaciones (gen-l10n)

# iOS simulator / desktop
flutter run --dart-define=API_BASE_URL=http://localhost:5125/api/v1

# Android emulator (localhost del host = 10.0.2.2)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5125/api/v1
```

La URL base **siempre** se pasa por `--dart-define=API_BASE_URL`; no hay URLs
hardcodeadas en el código.

Firebase (proyecto `tool-core-dev`) es **requerido para compilar**: los
archivos de configuración están ignorados por git y cada dev los genera una
vez con:

```bash
dart pub global activate flutterfire_cli
firebase login
flutterfire configure --project=tool-core-dev --platforms=android,ios
```

## Comandos útiles

```bash
flutter analyze          # lints y errores estáticos
flutter gen-l10n         # regenerar localizaciones tras editar los .arb
flutter test             # tests (pendiente: aún no hay)
```

## Arquitectura (resumen)

Feature-first con tres capas por feature y estado con **Cubit**
(flutter_bloc):

```
Page/Widget → Cubit (presentation) → Repository (domain) → RepositoryImpl + Datasource (data) → Dio
```

```
lib/
├── app/          # MaterialApp.router, router con guard de auth, BlocObserver
├── core/         # red (Dio + interceptores), envelope ApiResponse, errores,
│                 # secure storage, theming por empresa, DI manual (get_it)
├── l10n/         # es (plantilla) + en — cero strings hardcodeados en widgets
└── features/     # auth (login), home (menú), y futuras: servicios,
                  # inventario, órdenes de trabajo
```

Puntos clave de la integración con el backend:

- Toda respuesta viene en el envelope `{status, message, data}`.
- Errores como códigos kebab-case (`invalid-credentials`) que se traducen en
  `core/errors` — nunca se muestran crudos.
- Multi-tenancy por header `X-Company-Code`; token y empresa activa viven en
  secure storage; ante un 401 el interceptor refresca el token una vez.

