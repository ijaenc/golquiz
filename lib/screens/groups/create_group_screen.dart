import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/layout/responsive_layout.dart';
import '../../providers/group_provider.dart';
import '../../widgets/primary_button.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final group = await context.read<GroupProvider>().createGroup(
      name: _nameController.text,
      description: _descriptionController.text,
    );
    if (group != null && mounted) Navigator.pop(context, group);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroupProvider>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Crear grupo'),
        backgroundColor: AppColors.surface,
      ),
      body: SafeArea(
        top: false,
        child: ResponsiveContent(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      maxLength: 40,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del grupo',
                        prefixIcon: Icon(Icons.groups_rounded),
                      ),
                      validator: (value) => (value?.trim().length ?? 0) < 3
                          ? 'Usa al menos 3 caracteres.'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _descriptionController,
                      maxLength: 180,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Descripción (opcional)',
                        alignLabelWithHint: true,
                      ),
                    ),
                    if (provider.error != null)
                      Text(
                        provider.error!,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    const SizedBox(height: 18),
                    PrimaryButton(
                      label: 'Crear grupo',
                      icon: Icons.add_rounded,
                      isLoading: provider.isLoading,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
