import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/user_model.dart';

class AuthStorageService {
  static const _storage = FlutterSecureStorage();
  static const _userKey = 'user_data';

  Future<void> saveUser(UserModel user) async {
    final json = jsonEncode(user.toJson());
    await _storage.write(key: _userKey, value: json);
  }

  Future<UserModel?> loadUser() async {
    try {
      final json = await _storage.read(key: _userKey);
      if (json == null) return null;
      final data = jsonDecode(json) as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearUser() async {
    await _storage.deleteAll();
  }
}
