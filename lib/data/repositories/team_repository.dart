import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile_model.dart';
import '../supabase/supabase_service.dart';

final teamRepositoryProvider = Provider((ref) => TeamRepository());

class TeamRepository {
  Future<List<Profile>> getServers() async => (await SupabaseService.client
          .from('profiles')
          .select()
          .eq('role', 'serveur')
          .order('full_name'))
      .map<Profile>((e) => Profile.fromJson(e))
      .toList();
  Future<List<Map<String, dynamic>>> getPermissions() async =>
      List<Map<String, dynamic>>.from(await SupabaseService.client
          .from('permissions')
          .select()
          .order('label'));
  Future<Set<String>> getProfilePermissionIds(String profileId) async =>
      (await SupabaseService.client
              .from('profile_permissions')
              .select('permission_id')
              .eq('profile_id', profileId))
          .map<String>((e) => e['permission_id'] as String)
          .toSet();
  Future<void> setPermissions(String profileId, Set<String> ids) async {
    await SupabaseService.client
        .from('profile_permissions')
        .delete()
        .eq('profile_id', profileId);
    if (ids.isNotEmpty) {
      await SupabaseService.client.from('profile_permissions').insert(ids
          .map((id) => {'profile_id': profileId, 'permission_id': id})
          .toList());
    }
  }

  Future<void> createServer(String name, String email, String password) async {
    final response = await SupabaseService.client.functions
        .invoke('manage-server', body: {
      'action': 'create',
      'full_name': name,
      'email': email,
      'password': password
    });
    if (response.status >= 400) {
      throw Exception(response.data?['error'] ?? 'Création impossible');
    }
  }

  Future<void> updateServer(String id, String name, bool active) async {
    final response = await SupabaseService.client.functions
        .invoke('manage-server', body: {
      'action': 'update',
      'profile_id': id,
      'full_name': name,
      'is_active': active
    });
    if (response.status >= 400) {
      throw Exception(response.data?['error'] ?? 'Modification impossible');
    }
  }
}
