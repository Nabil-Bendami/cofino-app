import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) return const SizedBox();
          return Center(
            child: Card(
                child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(
                            radius: 38, child: Icon(Icons.person, size: 42)),
                        const SizedBox(height: 16),
                        Text(profile.fullName,
                            style: Theme.of(context).textTheme.headlineSmall),
                        Text(profile.isManager ? 'Manager' : 'Serveur'),
                        if (profile.cafeName != null)
                          Text(
                              '${profile.cafeName} · ${profile.cafeCity ?? ''}'),
                        if (profile.email != null) Text(profile.email!),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(authControllerProvider.notifier).signOut();
                          },
                          child: const Text('Se déconnecter'),
                        ),
                      ],
                    ))),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
    );
  }
}
