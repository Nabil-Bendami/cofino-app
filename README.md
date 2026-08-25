# Café Maroc

Application mobile SaaS Flutter/Supabase pour la prise de commandes dans les cafés marocains. Deux rôles seulement sont pris en charge : **Manager** et **Serveur**.

## Fonctionnalités

- Serveur : menu actif, catégories, recherche, détail produit, panier, quantités, remarque, total, confirmation atomique/idempotente et historique personnel.
- Manager : nouvelles commandes en Realtime, détail et passage à « Consultée », historique filtrable, CRUD catégories/produits avec images, équipe et permissions, statistiques jour/semaine/mois.
- Sécurité : Supabase Auth, RLS sur toutes les tables métier, isolation par café, calcul du total dans PostgreSQL et snapshots historiques des produits.

Le paiement, la cuisine, la livraison, les réservations, le stock, la fidélité et les rôles supplémentaires sont hors périmètre.

## Prérequis

- Flutter stable ;
- Supabase CLI et Docker pour un environnement local, ou un projet Supabase distant ;
- un projet Android/iOS configuré par Flutter.

## Installation Supabase

Pour un projet local :

```bash
supabase start
supabase db reset
```

Pour un projet distant lié :

```bash
supabase link --project-ref VOTRE_REFERENCE
supabase db push
supabase functions deploy manage-server
```

Les migrations créent le schéma, les politiques RLS, la RPC `create_order`, les statistiques, le bucket `product-images` et Realtime sur `orders`. Le fichier `supabase/seed.sql` ajoute un café, des catégories, des produits et la permission `create_order`.

## Création des premiers utilisateurs

1. Créer le premier utilisateur Manager dans **Authentication > Users**.
2. Relever son UUID et exécuter, avec l’identifiant du café du seed :

```sql
insert into public.profiles(id, cafe_id, full_name, email, role)
values ('UUID_AUTH_MANAGER', 'c0000000-0000-0000-0000-000000000001',
        'Manager Café Central', 'manager@example.com', 'manager');
```

3. Déployer `manage-server`. Le Manager peut ensuite créer les comptes Serveur depuis l’écran Équipe ; la clé `service_role` reste exclusivement dans l’environnement sécurisé de l’Edge Function.
4. Attribuer au Serveur la permission « Créer une commande » depuis l’écran Permissions.

## Configuration Flutter

Copier `.env.example` vers `.env` pour documenter les valeurs locales. L’application ne lit pas ce fichier et exige des `dart-define` :

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://VOTRE_PROJET.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=VOTRE_CLE_PUBLIQUE
```

Ne jamais placer une clé `service_role` dans Flutter.

## Qualité et construction

```bash
dart format lib test
flutter analyze
flutter test
flutter build apk --debug \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...
```

Le code est organisé par fonctionnalités sous `lib/features`, avec modèles et repositories Supabase sous `lib/data`, et thème/navigation partagés sous `lib/core`.
# cofino-app
