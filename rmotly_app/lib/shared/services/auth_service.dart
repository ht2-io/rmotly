import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';

import '../../core/providers/api_client_provider.dart';

/// Authentication state for the app
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final UserInfo? userInfo;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.userInfo,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    UserInfo? userInfo,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      userInfo: userInfo ?? this.userInfo,
      error: error,
    );
  }

  /// Initial state
  static const initial = AuthState();

  /// Loading state
  static const loading = AuthState(isLoading: true);
}

/// Authentication service using Serverpod auth module
class AuthService extends StateNotifier<AuthState> {
  final SessionManager _sessionManager;

  AuthService(this._sessionManager) : super(AuthState.initial) {
    _init();
  }

  /// Initialize the auth service
  Future<void> _init() async {
    state = AuthState.loading;

    try {
      // Check for existing session
      await _sessionManager.initialize();
      final userInfo = _sessionManager.signedInUser;

      if (userInfo != null) {
        state = AuthState(
          isAuthenticated: true,
          userInfo: userInfo,
        );
      } else {
        state = AuthState.initial;
      }
    } catch (e) {
      state = AuthState(error: 'Failed to initialize: $e');
    }
  }

  /// Sign in with email and password
  Future<bool> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final serverResponse = await _sessionManager.caller.modules.auth.email
          .authenticate(email, password);

      if (serverResponse.success) {
        await _sessionManager.registerSignedInUser(
          serverResponse.userInfo!,
          serverResponse.keyId!,
          serverResponse.key!,
        );

        state = AuthState(
          isAuthenticated: true,
          userInfo: serverResponse.userInfo,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: serverResponse.failReason?.name ?? 'Authentication failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Sign in failed: $e',
      );
      return false;
    }
  }

  /// Create a new account with email and password
  Future<bool> createAccount(String email, String password,
      {String? userName}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final serverResponse = await _sessionManager.caller.modules.auth.email
          .createAccountRequest(userName ?? email, email, password);

      if (serverResponse.success) {
        // Account created but needs email verification
        state = state.copyWith(
          isLoading: false,
          error: null,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: serverResponse.failReason?.name ?? 'Account creation failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Account creation failed: $e',
      );
      return false;
    }
  }

  /// Verify email with validation code
  Future<bool> verifyEmail(String email, String verificationCode) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final serverResponse = await _sessionManager.caller.modules.auth.email
          .createAccount(email, verificationCode);

      if (serverResponse.success) {
        // Automatically sign in after verification
        await _sessionManager.registerSignedInUser(
          serverResponse.userInfo!,
          serverResponse.keyId!,
          serverResponse.key!,
        );

        state = AuthState(
          isAuthenticated: true,
          userInfo: serverResponse.userInfo,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: serverResponse.failReason?.name ?? 'Verification failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Verification failed: $e',
      );
      return false;
    }
  }

  /// Request password reset
  Future<bool> requestPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await _sessionManager.caller.modules.auth.email
          .initiatePasswordReset(email);

      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Password reset request failed: $e',
      );
      return false;
    }
  }

  /// Reset password with verification code
  Future<bool> resetPassword(
      String email, String verificationCode, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await _sessionManager.caller.modules.auth.email
          .resetPassword(email, verificationCode, newPassword);

      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Password reset failed: $e',
      );
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      await _sessionManager.signOutDevice();
      state = AuthState.initial;
    } catch (e) {
      // Even if server sign out fails, clear local session
      state = AuthState(error: 'Sign out failed: $e');
    }
  }

  /// Sign out from all devices
  Future<void> signOutAllDevices() async {
    state = state.copyWith(isLoading: true);

    try {
      await _sessionManager.signOutAllDevices();
      state = AuthState.initial;
    } catch (e) {
      state = AuthState(error: 'Sign out failed: $e');
    }
  }

  /// Get current user ID
  int? get userId => state.userInfo?.id;

  /// Check if user is authenticated
  bool get isAuthenticated => state.isAuthenticated;
}

/// Provider for the auth service
final authServiceProvider =
    StateNotifierProvider<AuthService, AuthState>((ref) {
  final sessionManager = ref.watch(sessionManagerProvider);
  return AuthService(sessionManager);
});

/// Provider for checking if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authServiceProvider).isAuthenticated;
});

/// Provider for current user info
final currentUserProvider = Provider<UserInfo?>((ref) {
  return ref.watch(authServiceProvider).userInfo;
});

/// Provider for current user ID
final currentUserIdProvider = Provider<int?>((ref) {
  return ref.watch(currentUserProvider)?.id;
});
