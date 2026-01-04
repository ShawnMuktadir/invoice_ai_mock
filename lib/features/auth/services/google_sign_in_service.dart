import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class GoogleSignInService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Future<UserModel?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null;
      return _mapToUserModel(account);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> signInSilently() async {
    try {
      final account = await _googleSignIn.signInSilently();
      if (account == null) return null;
      return _mapToUserModel(account);
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  UserModel _mapToUserModel(GoogleSignInAccount account) {
    return UserModel(
      id: account.id,
      name: account.displayName ?? 'User',
      email: account.email,
      photoUrl: account.photoUrl,
      totalTokens: 10,
      usedTokens: 0,
    );
  }
}
