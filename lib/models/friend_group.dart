class FriendGroup {
  const FriendGroup({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.inviteCode,
    required this.createdAt,
    this.description,
    this.currentUserRole = 'member',
  });

  factory FriendGroup.fromSupabase(Map<String, dynamic> json, {String? role}) =>
      FriendGroup(
        id: json['id'] as String,
        ownerId: json['owner_id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        inviteCode: json['invite_code'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        currentUserRole:
            role ?? json['current_user_role'] as String? ?? 'member',
      );

  final String id;
  final String ownerId;
  final String name;
  final String? description;
  final String inviteCode;
  final DateTime createdAt;
  final String currentUserRole;

  bool get isOwner => currentUserRole == 'owner';
}
