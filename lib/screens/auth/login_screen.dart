import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/layout/responsive_layout.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/primary_button.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthProvider>().signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: ResponsiveContent(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              vertical: ResponsiveLayout.compactGap(context),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const _AuthBrand(),
                  SizedBox(height: ResponsiveLayout.compactGap(context) + 8),
                  const Text(
                    'Bienvenido de vuelta',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ingresa para guardar tus puntos, rankings y grupos.',
                    style: TextStyle(color: Color(0xFFCBD5E1), height: 1.4),
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (!email.contains('@') || !email.contains('.')) {
                        return 'Ingresa un correo válido.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    onFieldSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (value) => (value?.isEmpty ?? true)
                        ? 'Ingresa tu contraseña.'
                        : null,
                  ),
                  if (auth.error != null) ...[
                    const SizedBox(height: 14),
                    _FeedbackCard(message: auth.error!, isError: true),
                  ],
                  if (auth.message != null) ...[
                    const SizedBox(height: 14),
                    _FeedbackCard(message: auth.message!),
                  ],
                  const SizedBox(height: 22),
                  PrimaryButton(
                    label: 'Iniciar sesión',
                    icon: Icons.login_rounded,
                    isLoading: auth.isLoading,
                    onPressed: auth.isSupabaseConfigured ? _submit : null,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: auth.isLoading
                        ? null
                        : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF64748B)),
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: const Text('Crear una cuenta'),
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    children: [
                      Expanded(child: Divider(color: Color(0xFF475569))),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'o continúa localmente',
                          style: TextStyle(color: Color(0xFF94A3B8)),
                        ),
                      ),
                      Expanded(child: Divider(color: Color(0xFF475569))),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextButton.icon(
                    onPressed: auth.isLoading ? null : auth.signInAsDemo,
                    icon: const Icon(Icons.sports_soccer_rounded),
                    label: const Text('Entrar como usuario demo'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthBrand extends StatelessWidget {
  const _AuthBrand();

  @override
  Widget build(BuildContext context) => const Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.primary,
        child: Icon(Icons.sports_soccer, color: Colors.white, size: 30),
      ),
      SizedBox(width: 12),
      Text(
        'GolQuiz',
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.message, this.isError = false});
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: (isError ? AppColors.error : AppColors.primary).withValues(
        alpha: .15,
      ),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: isError ? AppColors.error : AppColors.primary),
    ),
    child: Text(message, style: const TextStyle(color: Colors.white)),
  );
}
