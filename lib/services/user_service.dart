import '../models/user_model.dart';
import 'hive_service.dart';

class UserService {
  static const String userKey = 'current_user';

  Future<void> saveUser(UserModel user) async {
    await HiveService.userBox.put(userKey, user);
  }

  UserModel? getUser() {
    return HiveService.userBox.get(userKey);
  }

  Future<void> updateUser(UserModel user) async {
    await HiveService.userBox.put(userKey, user);
  }
}
