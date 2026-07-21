import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/layout/responsive_layout.dart';
import '../../providers/group_provider.dart';
import 'create_group_screen.dart';
import 'group_detail_screen.dart';
import 'join_group_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<GroupProvider>().refreshGroups();
    });
  }

  Future<void> _open(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    if (mounted) await context.read<GroupProvider>().refreshGroups();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroupProvider>();
    return SafeArea(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.background,
            child: ResponsiveContent(
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grupos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Compite con tus amigos',
                      style: TextStyle(color: Color(0xFFCBD5E1)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ResponsiveContent(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveLayout.pagePadding(context),
              ),
              child: provider.isAvailable
                  ? _GroupsList(provider: provider, onOpen: _open)
                  : const _GroupsUnavailable(),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupsList extends StatelessWidget {
  const _GroupsList({required this.provider, required this.onOpen});
  final GroupProvider provider;
  final Future<void> Function(Widget screen) onOpen;

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading && provider.groups.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: provider.refreshGroups,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => onOpen(const CreateGroupScreen()),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Crear'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onOpen(const JoinGroupScreen()),
                  icon: const Icon(Icons.group_add_outlined),
                  label: const Text('Unirme'),
                ),
              ),
            ],
          ),
          if (provider.error != null) ...[
            const SizedBox(height: 14),
            Text(
              provider.error!,
              style: const TextStyle(color: AppColors.error),
            ),
          ],
          const SizedBox(height: 22),
          if (provider.groups.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(22),
                child: Column(
                  children: [
                    Icon(
                      Icons.groups_2_outlined,
                      size: 48,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Aún no perteneces a ningún grupo',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Crea uno o usa un código de invitación.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ...provider.groups.map(
              (group) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: .12),
                      child: const Icon(
                        Icons.groups_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(
                      group.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      group.isOwner
                          ? 'Eres dueño · ${group.inviteCode}'
                          : 'Integrante',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => onOpen(GroupDetailScreen(group: group)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GroupsUnavailable extends StatelessWidget {
  const _GroupsUnavailable();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.symmetric(vertical: 28),
    children: const [
      Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 52,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 14),
              Text(
                'Grupos disponibles con cuenta online',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Cierra la sesión demo e ingresa con Supabase para crear grupos o unirte por código.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
