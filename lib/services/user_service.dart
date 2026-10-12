import 'package:hive/hive.dart';
import '../models/user_model.dart';

class UserService {
  static const String _userKey = 'current_user';

  final Box<UserModel> _box = Hive.box<UserModel>('user');

  UserModel? getUser() {
    return _box.get(_userKey);
  }

  Future<void> saveUser(UserModel user) async {
    await _box.put(_userKey, user);
  }

  Future<void> updateUser(UserModel user) async {
    await _box.put(_userKey, user);
  }

  Future<void> clearUser() async {
    await _box.delete(_userKey);
  }
}
