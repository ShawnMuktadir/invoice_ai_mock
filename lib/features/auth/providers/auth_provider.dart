import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/google_sign_in_service.dart';
import '../services/auth_storage_service.dart';

class AuthNotifier extends StateNotifier<UserModel?> {
  final GoogleSignInService _googleSignInService;
  final AuthStorageService _storageService;

  AuthNotifier({
    required GoogleSignInService googleSignInService,
    required AuthStorageService storageService,
  })  : _googleSignInService = googleSignInService,
        _storageService = storageService,
        super(null) {
    _initialize();
  }

  Future<void> _initialize() async {
    // Try loading from storage first
    final savedUser = await _storageService.loadUser();
    if (savedUser != null) {
      state = savedUser;
      _verifySilentSignIn();
      return;
    }
    await _verifySilentSignIn();
  }

  Future<void> _verifySilentSignIn() async {
    try {
      final user = await _googleSignInService.signInSilently();
      if (user != null) {
        state = user;
        await _storageService.saveUser(user);
      }
    } catch (e) {
      // Silent sign-in failed
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final user = await _googleSignInService.signIn();
      if (user != null) {
        // Check for existing user to preserve tokens
        final existingUser = await _storageService.loadUser();
        final UserModel finalUser = (existingUser?.id == user.id && existingUser != null)
            ? existingUser
            : user;

        state = finalUser;
        await _storageService.saveUser(finalUser);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignInService.signOut();
    await _storageService.clearUser();
    state = null;
  }

  void consumeToken() {
    if (state != null && state!.remainingTokens > 0) {
      final updated = state!.copyWith(usedTokens: state!.usedTokens + 1);
      state = updated;
      _storageService.saveUser(updated);
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  return AuthNotifier(
    googleSignInService: GoogleSignInService(),
    storageService: AuthStorageService(),
  );
});

// Helper provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(authProvider);
  return user != null;
});
