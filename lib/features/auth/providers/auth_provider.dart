import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../../data/models/profile_model.dart';
import '../../../data/supabase/supabase_service.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(SupabaseService.client);
});

final authStateProvider = StreamProvider<supa.AuthState>((ref) {
  return SupabaseService.client.auth.onAuthStateChange;
});

final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  ref.watch(authStateProvider);
  final repository = ref.watch(authRepositoryProvider);
  final session = repository.currentSession;
  if (session == null) return null;
  return repository.loadCurrentProfile();
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._repository, this._ref) : super(const AsyncData(null));

  final AuthRepository _repository;
  final Ref _ref;

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    try {
      await _repository.signIn(email: email, password: password);
      final profile = await _repository.loadCurrentProfile();
      if (!profile.isActive) {
        throw const AuthFlowException('Votre compte est inactif.');
      }
      if (profile.cafeId.isEmpty || profile.cafeName == null) {
        throw const AuthFlowException(
          'Ce compte n’est associé à aucun café actif.',
        );
      }
      if (!profile.isManager && !profile.isServeur) {
        throw const AuthFlowException('Le rôle de ce compte est invalide.');
      }

      _ref.invalidate(currentProfileProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      if (_repository.currentSession != null) await _repository.signOut();
      state = AsyncError(_mapErrorMessage(e), st);
    }
  }

  Future<bool> resetPassword(String email) async {
    state = const AsyncLoading();
    try {
      await _repository.resetPassword(email);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(_mapErrorMessage(e), st);
      return false;
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await _repository.signOut();
      _ref.invalidate(currentProfileProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  String _mapErrorMessage(dynamic error) {
    if (error is AuthFlowException) return error.message;
    if (error is supa.AuthException) {
      if (error.message.contains('Invalid login credentials')) {
        return 'Identifiants incorrects.';
      }
      if (error.message.toLowerCase().contains('email')) {
        return 'Cette adresse e-mail ne peut pas être utilisée.';
      }
      return 'Impossible de vous authentifier pour le moment.';
    }
    return 'Une erreur est survenue lors de la connexion.';
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref.watch(authRepositoryProvider), ref);
});
