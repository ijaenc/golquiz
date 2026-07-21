import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/layout/responsive_layout.dart';
import '../../providers/group_provider.dart';
import '../../widgets/primary_button.dart';

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final group = await context.read<GroupProvider>().joinGroup(
      _codeController.text,
    );
    if (group != null && mounted) Navigator.pop(context, group);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroupProvider>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Unirse a un grupo'),
        backgroundColor: AppColors.surface,
      ),
      body: SafeArea(
        top: false,
        child: ResponsiveContent(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              children: [
                const Icon(
                  Icons.group_add_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ingresa el código de 8 caracteres que compartió el dueño del grupo.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  textAlign: TextAlign.center,
                  maxLength: 8,
                  style: const TextStyle(
                    fontSize: 24,
                    letterSpacing: 5,
                    fontWeight: FontWeight.w800,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[A-Za-z2-9]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Código de invitación',
                  ),
                  validator: (value) => (value?.trim().length ?? 0) == 8
                      ? null
                      : 'El código debe tener 8 caracteres.',
                ),
                if (provider.error != null)
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.error),
                  ),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: 'Unirme al grupo',
                  icon: Icons.login_rounded,
                  isLoading: provider.isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
