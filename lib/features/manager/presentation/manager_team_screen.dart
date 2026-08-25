import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/profile_model.dart';
import '../../../data/repositories/team_repository.dart';
import '../providers/manager_provider.dart';
import '../../../core/widgets/role_navigation.dart';

class ManagerTeamScreen extends ConsumerWidget {
  const ManagerTeamScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(teamProvider);
    return Scaffold(
      bottomNavigationBar: const ManagerNavigation(index: 4),
      appBar: AppBar(title: const Text('Équipe'), actions: [
        IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(teamProvider))
      ]),
      floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.person_add),
          label: const Text('Ajouter un serveur'),
          onPressed: () async {
            await _createDialog(context, ref);
            ref.invalidate(teamProvider);
          }),
      body: team.when(
        data: (rows) {
          if (rows.isEmpty) return const Center(child: Text('Aucun serveur.'));
          return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rows.length,
              itemBuilder: (_, i) {
                final p = rows[i];
                return Card(
                    child: ListTile(
                  leading: CircleAvatar(
                      child: Text(p.fullName.characters.first.toUpperCase())),
                  title: Text(p.fullName),
                  subtitle: Text(
                      '${p.email ?? ''}\n${p.isActive ? 'Actif' : 'Inactif'}'),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'permissions') {
                        await _permissionsDialog(context, ref, p);
                      } else {
                        await ref
                            .read(teamRepositoryProvider)
                            .updateServer(p.id, p.fullName, !p.isActive);
                      }
                      ref.invalidate(teamProvider);
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                          value: 'permissions', child: Text('Permissions')),
                      PopupMenuItem(
                          value: 'toggle',
                          child: Text(p.isActive ? 'Désactiver' : 'Activer'))
                    ],
                  ),
                ));
              });
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
      ),
    );
  }
}

Future<void> _createDialog(BuildContext context, WidgetRef ref) async {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
              title: const Text('Ajouter un serveur'),
              content: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                    controller: name,
                    decoration:
                        const InputDecoration(labelText: 'Nom complet')),
                const SizedBox(height: 10),
                TextField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 10),
                TextField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Mot de passe initial'))
              ])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Annuler')),
                FilledButton(
                    onPressed: () async {
                      if (name.text.trim().isEmpty ||
                          email.text.trim().isEmpty ||
                          password.text.length < 8) {
                        return;
                      }
                      try {
                        await ref.read(teamRepositoryProvider).createServer(
                            name.text.trim(), email.text.trim(), password.text);
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                      } catch (e) {
                        if (dialogContext.mounted) {
                          ScaffoldMessenger.of(dialogContext)
                              .showSnackBar(SnackBar(content: Text('$e')));
                        }
                      }
                    },
                    child: const Text('Créer'))
              ]));
  name.dispose();
  email.dispose();
  password.dispose();
}

Future<void> _permissionsDialog(
    BuildContext context, WidgetRef ref, Profile profile) async {
  final repo = ref.read(teamRepositoryProvider);
  final permissions = await repo.getPermissions();
  final selected = await repo.getProfilePermissionIds(profile.id);
  if (!context.mounted) return;
  await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
          builder: (_, setLocal) => AlertDialog(
                  title: Text('Permissions · ${profile.fullName}'),
                  content: SizedBox(
                      width: 360,
                      child: ListView(
                          shrinkWrap: true,
                          children: permissions
                              .map((p) => CheckboxListTile(
                                  value: selected.contains(p['id']),
                                  title: Text(p['label']),
                                  subtitle: Text(p['description'] ?? ''),
                                  onChanged: (v) => setLocal(() {
                                        if (v == true) {
                                          selected.add(p['id']);
                                        } else {
                                          selected.remove(p['id']);
                                        }
                                      })))
                              .toList())),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Annuler')),
                    FilledButton(
                        onPressed: () async {
                          await repo.setPermissions(profile.id, selected);
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                        },
                        child: const Text('Enregistrer'))
                  ])));
}
