import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProfileNotifier extends StateNotifier<UserModel?> {
  final UserService _userService = UserService();

  UserProfileNotifier() : super(null) {
    loadUser();
  }

  void loadUser() {
    final user = _userService.getUser();

    state = user;
  }

  Future<void> saveUser(UserModel user) async {
    await _userService.saveUser(user);

    state = user;
  }

  Future<void> updateUser(UserModel user) async {
    await _userService.updateUser(user);

    state = user;
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserModel?>(
      (ref) => UserProfileNotifier(),
    );
