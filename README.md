# ⚽ Cancha Turnos

Sistema de gestión y reserva de turnos para canchas de fútbol 5.
Permite a los usuarios ver la disponibilidad horaria de cada cancha y reservar un turno en línea, mientras que los administradores gestionan todo desde un back-office protegido.

---

## Tabla de Contenidos

- [Descripción general](#descripción-general)
- [Stack tecnológico](#stack-tecnológico)
- [Modelos y base de datos](#modelos-y-base-de-datos)
- [Arquitectura de la aplicación](#arquitectura-de-la-aplicación)
- [Instalación y configuración](#instalación-y-configuración)
- [Uso del sistema](#uso-del-sistema)
  - [Frontend público](#frontend-público)
  - [Back-office de administración](#back-office-de-administración)
  - [API REST JSON](#api-rest-json)
- [Action Mailer](#action-mailer)
- [Active Storage](#active-storage)
- [Tests de modelos](#tests-de-modelos)

---

## Descripción general

**Cancha Turnos** es una aplicación web full-stack desarrollada en Ruby on Rails 8 como Trabajo Práctico de la materia Programación IV. Cubre las siguientes funcionalidades:

- **Home público**: Listado de canchas disponibles con foto y precio.
- **Vista de turnos**: Selección de fecha (hoy + 5 días) con grilla de horarios de 10:00 a 01:00 hs; los turnos ya reservados se muestran bloqueados en rojo.
- **Reserva en línea**: El usuario ingresa su email y reserva el turno; recibe automáticamente una notificación por correo.
- **Back-office (CRUD)**: Gestión completa de canchas, franjas horarias, reservas y usuarios, protegido con HTTP Basic Auth.
- **API REST JSON**: Endpoints para login (JWT), listado de canchas y gestión de reservas, consumibles desde cualquier cliente externo.

---

## Stack tecnológico

| Capa | Tecnología |
|---|---|
| Lenguaje | Ruby 4.0.7 |
| Framework | Rails 8.1.4 |
| Base de datos | SQLite3 (desarrollo / test) |
| Asset pipeline | Propshaft |
| JavaScript | Import Maps + Stimulus + Turbo (Hotwire) |
| Autenticación web | `has_secure_password` + HTTP Basic Auth |
| Autenticación API | JWT (`jwt` gem) |
| Archivos adjuntos | Active Storage + `image_processing` |
| Emails | Action Mailer + Solid Queue (`deliver_later`) |
| Cache / Queue / Cable | Solid Cache / Solid Queue / Solid Cable |
| Servidor | Puma |
| Deploy | Kamal + Docker |
| Tests | Minitest (Rails default) |

---

## Modelos y base de datos

### Diagrama de relaciones

```
User ──────────────── Reservation ──── Court
                           │
                       TimeSlot
                           │
                        Deposit
```

### Modelos

#### `User`
Representa a un usuario del sistema (cliente o administrador).

| Atributo | Tipo | Descripción |
|---|---|---|
| `email` | string | Único, requerido, formato válido |
| `password_digest` | string | Contraseña hasheada con BCrypt |
| `role` | integer (enum) | `customer: 0` · `admin: 1` |

- **Validaciones**: presencia y unicidad de email, formato de email, presencia de contraseña.
- **Asociaciones**: `has_many :reservations, dependent: :destroy`
- **Autenticación**: `has_secure_password`

#### `Court`
Representa una cancha de fútbol 5.

| Atributo | Tipo | Descripción |
|---|---|---|
| `name` | string | Único, requerido |
| `price` | decimal | Requerido, > 0 |
| `covered` | boolean | Si la cancha es techada |

- **Validaciones**: presencia y unicidad de nombre, presencia y numericidad del precio.
- **Asociaciones**: `has_many :reservations, dependent: :destroy` · `has_one_attached :photo`

#### `TimeSlot`
Franja horaria de una hora asociada a un día de la semana.

| Atributo | Tipo | Descripción |
|---|---|---|
| `day_of_week` | integer | 0 = Domingo … 6 = Sábado · 7 = Domingo (alias) |
| `start_time` | time | Hora de inicio (ej. 10:00) |
| `end_time` | time | Hora de fin (ej. 11:00) |

- **Validaciones**: presencia de todos los campos, `end_time` posterior a `start_time` (con excepción para el rollover de medianoche: 23:00 → 00:00).
- **Métodos de instancia**: `#day_name` (nombre en español), `#formatted_time_range` (ej. `"10:00 a 11:00 hs"`).

> Las franjas horarias se generan automáticamente con `db/seeds.rb` para todos los días, de 10:00 a 01:00 hs en intervalos de una hora.

#### `Reservation`
Reserva de una cancha por parte de un usuario en un turno y fecha específicos.

| Atributo | Tipo | Descripción |
|---|---|---|
| `user_id` | integer | FK a `users` |
| `court_id` | integer | FK a `courts` |
| `time_slot_id` | integer | FK a `time_slots` |
| `date` | date | Fecha de la reserva |
| `status` | integer (enum) | `pending: 0` · `confirmed: 1` · `cancelled: 2` |

- **Validaciones**: presencia de fecha, usuario, cancha y franja horaria.
- **Asociaciones**: `belongs_to :user` · `belongs_to :court` · `belongs_to :time_slot` · `has_many :deposits, dependent: :destroy`

#### `Deposit`
Seña o depósito parcial vinculado a una reserva.

| Atributo | Tipo | Descripción |
|---|---|---|
| `reservation_id` | integer | FK a `reservations` |
| `amount` | decimal | Monto, > 0 y ≤ precio de la cancha |

- **Validaciones**: presencia y numericidad del monto, validación personalizada que impide que supere el precio de la cancha.
- **Asociaciones**: `belongs_to :reservation`

---

## Arquitectura de la aplicación

```
app/
├── controllers/
│   ├── application_controller.rb   # JWT + HTTP Basic Auth helpers
│   ├── home_controller.rb          # Frontend público (index, court, create_reservation)
│   ├── admin/                      # Back-office (CRUD completo)
│   │   ├── courts_controller.rb
│   │   ├── time_slots_controller.rb
│   │   ├── reservations_controller.rb
│   │   └── users_controller.rb
│   └── api/v1/                     # API REST JSON
│       ├── sessions_controller.rb  # Login → JWT
│       ├── courts_controller.rb
│       └── reservations_controller.rb
├── models/
│   ├── court.rb
│   ├── deposit.rb
│   ├── reservation.rb
│   ├── time_slot.rb
│   └── user.rb
├── mailers/
│   └── reservation_mailer.rb       # Emails de confirmación
└── views/
    ├── home/                       # Vistas públicas (paleta azul oscuro)
    ├── admin/                      # Vistas de back-office
    └── reservation_mailer/         # Templates HTML de emails
```

### Rutas principales

```ruby
# Frontend público
root "home#index"
get  "canchas/:id",          to: "home#court",              as: :court_turnos
post "canchas/:id/reservas", to: "home#create_reservation", as: :court_reservations

# Back-office (HTTP Basic Auth)
namespace :admin do
  root 'courts#index'
  resources :courts
  resources :time_slots
  resources :reservations
  resources :users
end

# API REST JSON
namespace :api do
  namespace :v1 do
    post 'login', to: 'sessions#create'
    resources :courts,       only: [:index, :show]
    resources :reservations, only: [:index, :create, :destroy]
  end
end
```

---

## Instalación y configuración

### Prerrequisitos

- Ruby 4.0.7
- Bundler
- SQLite3

### Pasos

```bash
# 1. Clonar el repositorio
git clone <url-del-repo>
cd cancha-turnos

# 2. Instalar dependencias
bundle install

# 3. Crear y migrar la base de datos
bin/rails db:create db:migrate

# 4. Cargar datos iniciales (canchas, franjas horarias, usuarios admin)
bin/rails db:seed

# 5. Iniciar el servidor
bin/rails server
```

La aplicación estará disponible en **http://localhost:3000**.

### Usuarios creados por el seed

| Email | Contraseña | Rol |
|---|---|---|
| `prueba@canchas.com` | `123` | Admin |
| `profe@canchas.com` | `123` | Admin |

---

## Uso del sistema

### Frontend público

Acceder a **http://localhost:3000**

#### Home
- Muestra el listado de canchas disponibles con nombre, precio, si es techada o no, y su foto (si fue subida desde el back-office).
- Cada tarjeta tiene un botón **"Ver Turnos"** para ir a la vista de disponibilidad.

#### Vista de turnos de una cancha
URL: `http://localhost:3000/canchas/:id`

- Muestra las franjas horarias del día (10:00 a 01:00 hs, en intervalos de 1 hora).
- Permite navegar entre los próximos **6 días** (hoy + 5 días) para reservar con anticipación.
- Los turnos **disponibles** se muestran en verde con un botón de reserva.
- Los turnos **ocupados** (pendiente o confirmado) se muestran en rojo y están bloqueados.
- Al hacer clic en un turno disponible, se despliega un formulario inline donde el usuario ingresa su email y confirma la reserva.

#### Flujo de reserva
1. El usuario selecciona una cancha → elige fecha → elige turno disponible.
2. Ingresa su email (si no existe, se crea como usuario `customer` automáticamente).
3. Se crea la reserva en estado `pending`.
4. Se envía un email de confirmación al correo ingresado (`deliver_later`).
5. El sistema redirige con un mensaje de éxito mostrando la fecha y horario reservado.

---

### Back-office de administración

URL: **http://localhost:3000/admin**  
Autenticación: **HTTP Basic Auth** con credenciales de usuario `admin`.

| Sección | URL | Funcionalidad |
|---|---|---|
| Canchas | `/admin/courts` | Crear, editar, eliminar canchas. Subir foto (Active Storage). |
| Franjas horarias | `/admin/time_slots` | Ver y gestionar los turnos por día y hora. |
| Reservas | `/admin/reservations` | Listar todas las reservas. Confirmar (→ envía email) o cancelar. |
| Usuarios | `/admin/users` | Listar usuarios registrados con su rol. |

---

### API REST JSON

Base URL: `http://localhost:3000/api/v1`

#### Autenticación

La mayoría de los endpoints de reservas requieren un token JWT en el header:

```
Authorization: Bearer <token>
```

#### Endpoints

##### `POST /api/v1/login` — Obtener token JWT
```json
// Body
{ "email": "profe@canchas.com", "password": "123" }

// Respuesta 200 OK
{ "token": "eyJ...", "role": "admin" }
```

##### `GET /api/v1/courts` — Listar canchas (público)
```json
// Respuesta 200 OK
[
  { "id": 1, "name": "Cancha 1 - Sintético Techada", "price": "28000.0", "covered": true },
  { "id": 2, "name": "Cancha 2 - Aire Libre Iluminada", "price": "24000.0", "covered": false }
]
```

##### `GET /api/v1/courts/:id` — Ver detalle de cancha (público)

##### `GET /api/v1/reservations` — Listar reservas (🔒 requiere JWT)

##### `POST /api/v1/reservations` — Crear reserva (🔒 requiere JWT)
```json
// Body
{
  "reservation": {
    "court_id": 1,
    "time_slot_id": 1,
    "user_id": 1,
    "date": "2026-10-20",
    "status": "pending"
  }
}

// Respuesta 201 Created → devuelve la reserva creada
```

##### `DELETE /api/v1/reservations/:id` — Eliminar reserva (🔒 requiere JWT)
```json
// Respuesta 200 OK
{ "message": "Reservation successfully deleted" }
```

> Para más ejemplos listos para importar en Postman, ver [`postman_api_endpoints.md`](./postman_api_endpoints.md).

---

## Action Mailer

Se implementaron dos emails transaccionales con **`ReservationMailer`**:

| Método | Asunto | Cuándo se dispara |
|---|---|---|
| `reservation_created` | ⚽ Solicitud de Reserva Registrada | Al reservar desde el frontend público o la API |
| `reservation_confirmed` | ✅ ¡Turno Confirmado! | Al confirmar una reserva desde el back-office (`/admin/reservations`) |

Los emails se encolan con `deliver_later` y son procesados por **Solid Queue** en background.

### Previsualización en desarrollo

```
http://localhost:3000/rails/mailers/reservation_mailer/reservation_created
http://localhost:3000/rails/mailers/reservation_mailer/reservation_confirmed
```

---

## Active Storage

El modelo `Court` utiliza `has_one_attached :photo` para gestionar la foto de cada cancha.

- **Subir foto**: Desde el back-office (`/admin/courts/new` o `/admin/courts/:id/edit`), campo _"Foto de la Cancha"_.
- **Visualización**: La foto aparece en la tarjeta del home público y en el encabezado de la vista de turnos.
- **Almacenamiento**: Disco local en desarrollo (`config/storage.yml` → `service: Local`).

---

## Tests de modelos

Los tests se encuentran en `test/models/` y utilizan **Minitest** con fixtures.

### Ejecutar los tests

```bash
bundle exec rails test test/models -v
```

### Resultado esperado

```
66 runs, 127 assertions, 0 failures, 0 errors, 0 skips
```

### Cobertura por modelo

| Modelo | Tests | Escenarios cubiertos |
|---|---|---|
| `Court` | 13 | Presencia/unicidad de nombre, numericidad del precio, `has_many` con destroy en cascada, Active Storage |
| `User` | 13 | Presencia/formato/unicidad de email, `has_secure_password`, autenticación, enum de roles, destroy en cascada |
| `TimeSlot` | 14 | Presencia de campos, validación `end_time > start_time`, rollover de medianoche, `#day_name`, `#formatted_time_range` |
| `Reservation` | 15 | Presencia de fecha/asociaciones, los 3 estados del enum, asociaciones polimórficas |
| `Deposit` | 11 | Presencia/numericidad del monto, validación personalizada `amount ≤ court.price` |

> **Nota**: Los tests usan `parallelize(workers: 1)` porque SQLite3 no soporta fixtures transaccionales concurrentes con múltiples threads.

---

## Paleta de colores

La interfaz pública sigue una paleta azul oscuro/marino:

| Variable | Color | Uso |
|---|---|---|
| `--sky-blue-light` | `#78c0e0` | Acentos, bordes activos |
| `--blue-bell` | `#449dd1` | Botones secundarios, links |
| `--persian-blue` | `#192bc2` | Botones primarios |
| `--navy` | `#150578` | Navbar, fondos de sección |
| `--deep-twilight` | `#0e0e52` | Fondo principal de la app |
