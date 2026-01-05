import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/google_sign_in_service.dart';
import '../services/guest_auth_service.dart';
import '../services/auth_storage_service.dart';

class AuthNotifier extends StateNotifier<UserModel?> {
  final GoogleSignInService _googleSignInService;
  final GuestAuthService _guestAuthService;
  final AuthStorageService _storageService;

  AuthNotifier({
    required GoogleSignInService googleSignInService,
    required GuestAuthService guestAuthService,
    required AuthStorageService storageService,
  })  : _googleSignInService = googleSignInService,
        _guestAuthService = guestAuthService,
        _storageService = storageService,
        super(null) {
    _initialize();
  }

  Future<void> _initialize() async {
    // Try loading from storage first
    final savedUser = await _storageService.loadUser();
    if (savedUser != null) {
      state = savedUser;
      // Only verify Google sign-in for non-guest users
      if (!savedUser.isGuest) {
        _verifySilentSignIn();
      }
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

  Future<void> signInAsGuest() async {
    final guestUser = _guestAuthService.createGuestUser();
    state = guestUser;
    await _storageService.saveUser(guestUser);
  }

  Future<void> signInWithGoogle() async {
    try {
      final user = await _googleSignInService.signIn();
      if (user != null) {
        // Check for existing user to preserve tokens
        final existingUser = await _storageService.loadUser();

        UserModel finalUser;
        if (existingUser?.id == user.id && existingUser != null) {
          // Returning Google user - preserve existing data
          finalUser = existingUser;
        } else if (existingUser?.isGuest == true) {
          // Migrating from guest - transfer token usage
          finalUser = user.copyWith(usedTokens: existingUser!.usedTokens);
        } else {
          // New Google user
          finalUser = user;
        }

        state = finalUser;
        await _storageService.saveUser(finalUser);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    // Only sign out from Google if not a guest user
    if (state?.isGuest != true) {
      await _googleSignInService.signOut();
    }
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
    guestAuthService: GuestAuthService(),
    storageService: AuthStorageService(),
  );
});

// Helper provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(authProvider);
  return user != null;
});
