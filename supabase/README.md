# Configuración manual de Supabase

1. Crea un proyecto en Supabase.
2. Abre **SQL Editor** y ejecuta `schema.sql` completo.
3. Ejecuta `policies.sql` completo.
4. En **Authentication > Providers > Email**, habilita correo y contraseña.
5. Decide si exigirás confirmación de correo. GolQuiz contempla ambos flujos.
6. Copia `.env.example` como `.env` y completa:

   ```env
   SUPABASE_URL=https://tu-proyecto.supabase.co
   SUPABASE_ANON_KEY=tu_publishable_key
   ```

7. Nunca uses una `service_role` key dentro de Flutter.
8. Ejecuta `flutter pub get` y vuelve a iniciar la aplicación.

Sin `.env` configurado la aplicación inicia normalmente y conserva el modo demo
local. Rankings reales y grupos se habilitan al ingresar con una cuenta Supabase.
