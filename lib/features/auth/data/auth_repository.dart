import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/profile_model.dart';

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  Session? get currentSession => _client.auth.currentSession;

  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<Profile> loadCurrentProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) throw const AuthFlowException('Session introuvable.');

    final data = await _client
        .from('profiles')
        .select('*, cafes(name, city)')
        .eq('id', user.id)
        .maybeSingle();
    if (data == null) {
      throw const AuthFlowException(
        'Aucun profil café n’est associé à ce compte.',
      );
    }
    return Profile.fromJson(data);
  }

  Future<void> resetPassword(String email) {
    return _client.auth.resetPasswordForEmail(email);
  }

  Future<void> signOut() => _client.auth.signOut();
}

class AuthFlowException implements Exception {
  const AuthFlowException(this.message);

  final String message;

  @override
  String toString() => message;
}
