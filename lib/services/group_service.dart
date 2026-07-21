import 'dart:math';

import '../models/friend_group.dart';
import '../models/group_member.dart';
import '../models/leaderboard_user.dart';
import 'supabase_service.dart';

class GroupService {
  GroupService(this._supabase, {Random? random})
    : _random = random ?? Random.secure();

  final SupabaseService _supabase;
  final Random _random;
  bool get isConfigured => _supabase.isConfigured;

  Future<List<FriendGroup>> fetchGroups(String userId) async {
    final rows = await _supabase.client!
        .from('group_members')
        .select('role, friend_groups(*)')
        .eq('user_id', userId)
        .order('joined_at', ascending: false);
    return rows.map((row) {
      final group = Map<String, dynamic>.from(row['friend_groups'] as Map);
      return FriendGroup.fromSupabase(group, role: row['role'] as String?);
    }).toList();
  }

  Future<FriendGroup> createGroup({
    required String ownerId,
    required String name,
    String? description,
  }) async {
    final row = await _supabase.client!
        .from('friend_groups')
        .insert({
          'owner_id': ownerId,
          'name': name.trim(),
          'description': _nullableText(description),
          'invite_code': _inviteCode(),
        })
        .select()
        .single();
    return FriendGroup.fromSupabase(row, role: 'owner');
  }

  Future<FriendGroup> joinByCode(String code) async {
    final response =
        await _supabase.client!.rpc(
              'join_group_by_code',
              params: {'p_invite_code': code.trim().toUpperCase()},
            )
            as List<dynamic>;
    if (response.isEmpty) throw StateError('Código de invitación no válido.');
    return FriendGroup.fromSupabase(
      Map<String, dynamic>.from(response.first as Map),
      role: 'member',
    );
  }

  Future<void> updateGroup({
    required String groupId,
    required String name,
    String? description,
  }) async {
    await _supabase.client!
        .from('friend_groups')
        .update({
          'name': name.trim(),
          'description': _nullableText(description),
        })
        .eq('id', groupId);
  }

  Future<void> deleteGroup(String groupId) async {
    await _supabase.client!.from('friend_groups').delete().eq('id', groupId);
  }

  Future<List<GroupMember>> fetchMembers(
    String groupId,
    String currentUserId,
  ) async {
    final rows = await _supabase.client!
        .from('group_members')
        .select(
          'role, joined_at, profiles(id, username, display_name, avatar_url, total_points)',
        )
        .eq('group_id', groupId);
    final members = rows.map((row) {
      final profile = Map<String, dynamic>.from(row['profiles'] as Map);
      return GroupMember(
        user: LeaderboardUser.fromSupabase(profile, currentUserId),
        role: row['role'] as String,
        joinedAt: DateTime.parse(row['joined_at'] as String),
      );
    }).toList();
    members.sort((a, b) => b.user.score.compareTo(a.user.score));
    return members;
  }

  String? _nullableText(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  String _inviteCode() {
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(
      8,
      (_) => alphabet[_random.nextInt(alphabet.length)],
    ).join();
  }
}
