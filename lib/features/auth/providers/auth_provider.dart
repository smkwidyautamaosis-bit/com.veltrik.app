import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/notification_service.dart';
import '../models/session_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;

  AuthState({required this.status, this.user, this.error});

  AuthState copyWith({AuthStatus? status, UserModel? user, String? error}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState(status: AuthStatus.initial));

  Future<void> validateSession() async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await AuthService.instance.validateSession();
    if (result['valid'] == true) {
      state = state.copyWith(status: AuthStatus.authenticated, user: AuthService.instance.currentUser);
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated, error: result['message']);
    }
  }

  Future<bool> login(String code, {Function(bool)? onFirstLogin}) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await AuthService.instance.loginWithInviteCode(code);
    
    if (result['success'] == true) {
      state = state.copyWith(status: AuthStatus.authenticated, user: AuthService.instance.currentUser);
      if (onFirstLogin != null) {
        onFirstLogin(result['is_first_login'] == true);
      }
      
      // Sync FCM token now that user is logged in
      final currentUser = AuthService.instance.currentUser;
      if (currentUser != null) {
        await NotificationService.instance.fetchAndSaveToken(userId: currentUser.id);
      }
      
      return true;
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated, error: result['message']);
      return false;
    }
  }

  Future<void> logout() async {
    await AuthService.instance.logout();
    state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
  }

  void updateAvatarUrl(String url) {
    if (state.user != null) {
      state = state.copyWith(user: state.user!.copyWith(avatarUrl: url));
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
