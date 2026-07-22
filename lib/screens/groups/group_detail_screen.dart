import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/layout/responsive_layout.dart';
import '../../models/friend_group.dart';
import '../../models/group_member.dart';
import '../../providers/group_provider.dart';

class GroupDetailScreen extends StatefulWidget {
  const GroupDetailScreen({super.key, required this.group});
  final FriendGroup group;

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<GroupProvider>().loadMembers(widget.group.id);
    });
  }

  Future<void> _edit() async {
    final nameController = TextEditingController(text: widget.group.name);
    final descriptionController = TextEditingController(
      text: widget.group.description,
    );
    final values = await showDialog<List<String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar grupo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              maxLength: 40,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: descriptionController,
              maxLength: 180,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, [
              nameController.text,
              descriptionController.text,
            ]),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    nameController.dispose();
    descriptionController.dispose();
    if (values == null || values.first.trim().length < 3 || !mounted) return;
    final success = await context.read<GroupProvider>().updateGroup(
      group: widget.group,
      name: values.first,
      description: values.last,
    );
    if (success && mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar grupo'),
        content: const Text(
          'El grupo y todas sus membresías se eliminarán. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final success = await context.read<GroupProvider>().deleteGroup(
      widget.group.id,
    );
    if (success && mounted) Navigator.pop(context);
  }

  Future<void> _removeMember(GroupMember member) async {
    if (!widget.group.isOwner || member.role == 'owner') return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Expulsar integrante'),
        content: Text(
          '¿Quieres sacar a ${member.user.name} del grupo? '
          'Podrá volver a unirse si recibe nuevamente el código.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Expulsar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final success = await context.read<GroupProvider>().removeMember(
      group: widget.group,
      userId: member.user.id,
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${member.user.name} fue expulsado del grupo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroupProvider>();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          title: Text(widget.group.name),
          actions: [
            if (widget.group.isOwner)
              PopupMenuButton<String>(
                onSelected: (value) => value == 'edit' ? _edit() : _delete(),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Editar grupo')),
                  PopupMenuItem(value: 'delete', child: Text('Eliminar grupo')),
                ],
              ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Integrantes'),
              Tab(text: 'Ranking'),
            ],
          ),
        ),
        body: Column(
          children: [
            ResponsiveContent(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7ECFF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.key_rounded, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Código de invitación',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              widget.group.inviteCode,
                              style: const TextStyle(
                                fontSize: 20,
                                letterSpacing: 3,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Copiar código',
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: widget.group.inviteCode),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Código copiado')),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (provider.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  provider.error!,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            Expanded(
              child: provider.isLoading && provider.members.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      children: [
                        _MembersList(
                          members: provider.members,
                          canRemoveMembers: widget.group.isOwner,
                          isLoading: provider.isLoading,
                          onRemove: _removeMember,
                        ),
                        _GroupRanking(members: provider.members),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MembersList extends StatelessWidget {
  const _MembersList({
    required this.members,
    required this.canRemoveMembers,
    required this.isLoading,
    required this.onRemove,
  });
  final List<GroupMember> members;
  final bool canRemoveMembers;
  final bool isLoading;
  final ValueChanged<GroupMember> onRemove;

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: EdgeInsets.fromLTRB(
      ResponsiveLayout.pagePadding(context),
      14,
      ResponsiveLayout.pagePadding(context),
      28,
    ),
    itemCount: members.length,
    separatorBuilder: (_, _) => const Divider(),
    itemBuilder: (context, index) {
      final member = members[index];
      return ListTile(
        leading: CircleAvatar(child: Text(member.user.initial)),
        title: Text(member.user.name),
        subtitle: Text(member.role == 'owner' ? 'Dueño' : 'Integrante'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${member.user.score} pts'),
            if (canRemoveMembers && member.role != 'owner') ...[
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Expulsar integrante',
                color: AppColors.error,
                onPressed: isLoading ? null : () => onRemove(member),
                icon: const Icon(Icons.person_remove_rounded),
              ),
            ],
          ],
        ),
      );
    },
  );
}

class _GroupRanking extends StatelessWidget {
  const _GroupRanking({required this.members});
  final List<GroupMember> members;

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: EdgeInsets.fromLTRB(
      ResponsiveLayout.pagePadding(context),
      14,
      ResponsiveLayout.pagePadding(context),
      28,
    ),
    itemCount: members.length,
    separatorBuilder: (_, _) => const SizedBox(height: 10),
    itemBuilder: (context, index) {
      final user = members[index].user;
      return Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: user.isCurrentUser ? const Color(0xFFE7ECFF) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: user.isCurrentUser ? AppColors.primary : AppColors.outline,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            CircleAvatar(radius: 18, child: Text(user.initial)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                user.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              '${user.score} pts',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    },
  );
}
