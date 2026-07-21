import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/primary_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoading = false;

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    await context.read<AuthProvider>().signInAsDemo();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height - 96,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Brand(),
                const SizedBox(height: 54),
                Text(
                  AppStrings.welcomeTitle,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 18),
                const Text(
                  AppStrings.welcomeSubtitle,
                  style: TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 16,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 42),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: .22),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Icon(
                        Icons.sports_soccer_rounded,
                        size: 118,
                        color: Colors.white,
                      ),
                      const Positioned(
                        right: 8,
                        top: 20,
                        child: Icon(
                          Icons.star_rounded,
                          color: AppColors.secondary,
                          size: 42,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 38),
                const Row(
                  children: [
                    Expanded(
                      child: _WelcomeStat(value: '10', label: 'preguntas'),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _WelcomeStat(value: '5', label: 'categorías'),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _WelcomeStat(value: '∞', label: 'sin tiempo'),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: 'Entrar como demo',
                  isLoading: _isLoading,
                  onPressed: _signIn,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();
  @override
  Widget build(BuildContext context) => const Row(
    children: [
      CircleAvatar(
        backgroundColor: AppColors.primary,
        child: Icon(Icons.sports_soccer, color: Colors.white),
      ),
      SizedBox(width: 12),
      Text(
        AppStrings.appName,
        style: TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}

class _WelcomeStat extends StatelessWidget {
  const _WelcomeStat({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12),
        ),
      ],
    ),
  );
}
