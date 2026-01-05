import 'package:uuid/uuid.dart';
import '../models/user_model.dart';

class GuestAuthService {
  UserModel createGuestUser() {
    return UserModel(
      id: 'guest_${const Uuid().v4()}',
      name: 'Guest User',
      email: 'guest@local',
      photoUrl: null,
      totalTokens: 10,
      usedTokens: 0,
      isGuest: true,
    );
  }
}
