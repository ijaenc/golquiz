import 'package:flutter/foundation.dart';

import '../models/friend_group.dart';
import '../models/group_member.dart';
import '../services/group_service.dart';
import 'auth_provider.dart';

class GroupProvider extends ChangeNotifier {
  GroupProvider(this._authProvider, this._groupService) {
    _authProvider.addListener(_onAuthChanged);
  }

  final AuthProvider _authProvider;
  final GroupService _groupService;

  bool _isLoading = false;
  String? _error;
  List<FriendGroup> _groups = [];
  List<GroupMember> _members = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAvailable => !_authProvider.isDemo && _groupService.isConfigured;
  List<FriendGroup> get groups => List.unmodifiable(_groups);
  List<GroupMember> get members => List.unmodifiable(_members);

  Future<void> refreshGroups() async {
    if (!isAvailable) {
      _groups = [];
      notifyListeners();
      return;
    }
    await _load(() async {
      _groups = await _groupService.fetchGroups(_authProvider.user.id);
    });
  }

  Future<FriendGroup?> createGroup({
    required String name,
    String? description,
  }) async {
    FriendGroup? created;
    await _load(() async {
      created = await _groupService.createGroup(
        ownerId: _authProvider.user.id,
        name: name,
        description: description,
      );
      _groups = [created!, ..._groups];
    });
    return created;
  }

  Future<FriendGroup?> joinGroup(String code) async {
    FriendGroup? joined;
    await _load(() async {
      joined = await _groupService.joinByCode(code);
      if (!_groups.any((group) => group.id == joined!.id)) {
        _groups = [joined!, ..._groups];
      }
    });
    return joined;
  }

  Future<void> loadMembers(String groupId) async {
    if (!isAvailable) return;
    await _load(() async {
      _members = await _groupService.fetchMembers(
        groupId,
        _authProvider.user.id,
      );
    });
  }

  Future<bool> updateGroup({
    required FriendGroup group,
    required String name,
    String? description,
  }) async {
    var success = false;
    await _load(() async {
      await _groupService.updateGroup(
        groupId: group.id,
        name: name,
        description: description,
      );
      success = true;
      _groups = await _groupService.fetchGroups(_authProvider.user.id);
    });
    return success;
  }

  Future<bool> deleteGroup(String groupId) async {
    var success = false;
    await _load(() async {
      await _groupService.deleteGroup(groupId);
      _groups.removeWhere((group) => group.id == groupId);
      _members = [];
      success = true;
    });
    return success;
  }

  void clear() {
    _groups = [];
    _members = [];
    _error = null;
    notifyListeners();
  }

  void _onAuthChanged() {
    if (!_authProvider.isAuthenticated) clear();
  }

  Future<void> _load(Future<void> Function() operation) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await operation();
    } catch (error) {
      _error = error.toString().replaceFirst('Bad state: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthChanged);
    super.dispose();
  }
}
