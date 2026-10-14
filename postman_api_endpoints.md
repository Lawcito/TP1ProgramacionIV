# Guía de Endpoints para la Demostración (TP1)

Esta es tu "hoja de trucos" o _cheatsheet_ para mañana. Contiene todo lo que necesitas saber para operar el sistema que acabamos de construir.

---

## 1. El Back-Office (Navegador Web)

Muéstrale al profesor que puedes crear datos de forma visual y que está protegido por autenticación.

- **URL:** `http://localhost:3000/admin/courts`
- **¿Cómo usarlo?** Simplemente ingresa esa URL en Chrome o Firefox. Te saltará una alerta de seguridad (HTTP Basic Auth).
- **Credenciales:** Usa el email y contraseña del usuario que creaste en la consola (ej. `profe@canchas.com` / `123`).

---

## 2. La API JSON (Postman)

Abre Postman y crea estas peticiones (_Requests_) para dejarlas guardadas. Al seleccionar el tipo de cuerpo (Body), asegúrate de elegir **`raw`** y en el menú desplegable cambiar de `Text` a **`JSON`**.

### A. Obtener Token JWT (Login)

_Este endpoint no requiere autenticación previa. Sirve para que la API te reconozca._

- **Método:** `POST`
- **URL:** `http://localhost:3000/api/v1/login`
- **Body (JSON):**
  ```json
  {
    "email": "profe@canchas.com",
    "password": "123"
  }
  ```
- **Prueba en la demo:** Haz clic en _Send_ y copia el `token` largo que te devuelve en la respuesta. Lo necesitarás para las rutas protegidas.

### B. Listar Todas las Canchas (Público)

_Cualquier usuario o front-end puede ver las canchas sin iniciar sesión._

- **Método:** `GET`
- **URL:** `http://localhost:3000/api/v1/courts`
- **Body:** Ninguno.
- **Prueba en la demo:** Haz clic en _Send_. Te devolverá una lista (Array) en JSON con las canchas que hayas creado desde la consola o desde el Back-Office.

### C. Ver Detalle de Una Cancha (Público)

- **Método:** `GET`
- **URL:** `http://localhost:3000/api/v1/courts/1` _(El `1` es el ID de la cancha)_
- **Body:** Ninguno.

### D. Listar Reservas (Protegido)

_Requiere enviar el token JWT que obtuviste en el paso A._

- **Método:** `GET`
- **URL:** `http://localhost:3000/api/v1/reservations`
- **Headers:**
  - Tienes que ir a la pestaña **Headers** en Postman y agregar una nueva fila.
  - Key: `Authorization`
  - Value: `Bearer AQUÍ_PEGA_TU_TOKEN_LARGO`
- **Prueba en la demo:** Dale a _Send_ sin el header para mostrarle al profe que arroja un error de _"Unauthorized"_. Luego, pon el Header con el Token y dale a _Send_ para mostrar que ahora sí te deja pasar.

### E. Crear una Reserva (Protegido)

_Demuestra cómo llega un JSON desde el front-end y se inserta en la base de datos._

- **Método:** `POST`
- **URL:** `http://localhost:3000/api/v1/reservations`
- **Headers:** Igual que en el punto D (necesitas `Authorization: Bearer <tu_token>`).
- **Body (JSON):**
  _(Asegúrate de que los IDs existan en tu base de datos)_
  ```json
  {
    "reservation": {
      "court_id": 1,
      "time_slot_id": 1,
      "user_id": 1,
      "date": "2026-10-15",
      "status": "pending"
    }
  }
  ```
- **Prueba en la demo:** Si todo va bien, Rails devolverá un código de estado HTTP `201 Created` y el JSON de tu nueva reserva.

### F. Eliminar una Reserva (Protegido)

- **Método:** `DELETE`
- **URL:** `http://localhost:3000/api/v1/reservations/1` _(El `1` es el ID de la reserva)_
- **Headers:** `Authorization: Bearer <tu_token>`
- **Prueba en la demo:** Esto elimina el registro de la base de datos y te devuelve el mensaje `"Reservation successfully deleted"`.

---

## 3. Demostración de Active Storage (Fotos de Canchas)

Active Storage está integrado en el modelo `Court` mediante `has_one_attached :photo`:

- **¿Dónde probarlo visualmente?**
  1. Entrá a `http://localhost:3000/admin/courts/new` o editá una cancha existente en `http://localhost:3000/admin/courts/3/edit`.
  2. En el campo **"Foto de la Cancha (Active Storage)"**, seleccioná una imagen JPG/PNG desde tu computadora y dale a **"Actualizar Cancha"**.
  3. Vas a ver la miniatura cargada en la tabla del Back Office y la foto en el encabezado de la tarjeta en el Home (`http://localhost:3000/#canchas`).

---

## 4. Demostración de Action Mailer (Notificaciones de Turnos)

Action Mailer está implementado en `ReservationMailer` con dos correos transaccionales:
- `reservation_created`: Notificación de solicitud recibida.
- `reservation_confirmed`: Confirmación oficial de turno con detalles de cancha, horario y precio.

- **Previsualización en el Navegador (Rails Mailer Previews):**
  - Entrá a `http://localhost:3000/rails/mailers/reservation_mailer/reservation_confirmed` para ver el diseño del email HTML con la paleta oficial en vivo.
  - Entrá a `http://localhost:3000/rails/mailers/reservation_mailer/reservation_created` para ver el correo de solicitud recibida.

- **Disparo Automático en Vivo:**
  - Cuando un administrador hace clic en **"✓ Confirmar"** en `http://localhost:3000/admin/reservations`, Rails automáticamente ejecuta `ReservationMailer.reservation_confirmed(@reservation).deliver_later` y envía el correo al email del usuario.

