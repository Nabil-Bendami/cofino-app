import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/menu_repository.dart';
import '../../../data/supabase/supabase_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../menu/providers/menu_provider.dart';
import '../../../core/widgets/role_navigation.dart';

class ManagerMenuScreen extends ConsumerWidget {
  const ManagerMenuScreen({super.key});
  void _refresh(WidgetRef ref) {
    ref.invalidate(categoriesProvider);
    ref.invalidate(allProductsProvider);
    ref.invalidate(activeProductsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final products = ref.watch(allProductsProvider);
    final cafeId = ref.watch(currentProfileProvider).valueOrNull?.cafeId;
    return Scaffold(
      bottomNavigationBar: const ManagerNavigation(index: 2),
      appBar: AppBar(title: const Text('Menu'), actions: [
        IconButton(
            icon: const Icon(Icons.refresh), onPressed: () => _refresh(ref))
      ]),
      floatingActionButton: cafeId == null
          ? null
          : FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un produit'),
              onPressed: () async {
                final cats = categories.valueOrNull ?? [];
                if (cats.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Ajoutez d’abord une catégorie.')));
                  return;
                }
                final saved = await _productDialog(context, cafeId, cats);
                if (saved) _refreshAfterDialog(ref);
              }),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(ref),
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Row(children: [
            Text('Catégories', style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Ajouter'),
                onPressed: cafeId == null
                    ? null
                    : () async {
                        await _categoryDialog(context, ref, cafeId);
                        _refresh(ref);
                      })
          ]),
          categories.when(
              data: (rows) => Wrap(
                  spacing: 8,
                  children: rows
                      .map((c) => InputChip(
                          label: Text(c.name),
                          onPressed: () async {
                            await _categoryDialog(context, ref, cafeId!,
                                category: c);
                            _refresh(ref);
                          },
                          onDeleted: () => _confirmDelete(
                                  context, 'Supprimer cette catégorie ?',
                                  () async {
                                await ref
                                    .read(menuRepositoryProvider)
                                    .deleteCategory(c.id);
                                _refresh(ref);
                              })))
                      .toList()),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Erreur : $e')),
          const SizedBox(height: 24),
          Text('Produits', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          products.when(
              data: (rows) {
                if (rows.isEmpty) {
                  return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('Aucun produit.')));
                }
                final cats = categories.valueOrNull ?? [];
                return Column(
                    children: rows
                        .map((p) => _ProductTile(
                            product: p,
                            category: cats
                                .where((c) => c.id == p.categoryId)
                                .firstOrNull,
                            onEdit: () async {
                              final saved = await _productDialog(
                                  context, cafeId!, cats,
                                  product: p);
                              if (saved) _refreshAfterDialog(ref);
                            },
                            onToggle: (v) async {
                              await ref
                                  .read(menuRepositoryProvider)
                                  .setProductActive(p.id, v);
                              _refresh(ref);
                            },
                            onDelete: () => _confirmDelete(
                                    context, 'Supprimer ${p.name} ?', () async {
                                  await ref
                                      .read(menuRepositoryProvider)
                                      .deleteProduct(p.id);
                                  _refresh(ref);
                                })))
                        .toList());
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erreur : $e')),
          const SizedBox(height: 90),
        ]),
      ),
    );
  }
}

void _refreshAfterDialog(WidgetRef ref) {
  // Wait for the dialog route to finish its teardown before invalidating the
  // providers that rebuild the menu underneath it.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.invalidate(categoriesProvider);
    ref.invalidate(allProductsProvider);
    ref.invalidate(activeProductsProvider);
  });
}

class _ProductTile extends StatelessWidget {
  const _ProductTile(
      {required this.product,
      this.category,
      required this.onEdit,
      required this.onToggle,
      required this.onDelete});
  final Product product;
  final Category? category;
  final VoidCallback onEdit;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) {
    final image = SupabaseService.productImageUrl(product.imagePath);
    return Card(
        child: ListTile(
            contentPadding: const EdgeInsets.all(10),
            leading: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                    width: 64,
                    height: 64,
                    child: image == null
                        ? const ColoredBox(
                            color: Color(0xFFF1DDD4), child: Icon(Icons.coffee))
                        : Image.network(image, fit: BoxFit.cover))),
            title: Text(product.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
                '${category?.name ?? ''} · ${NumberFormat.currency(locale: 'fr_MA', symbol: 'MAD').format(product.price)}'),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              Switch(value: product.isActive, onChanged: onToggle),
              PopupMenuButton<String>(
                  onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
                  itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Modifier')),
                        PopupMenuItem(value: 'delete', child: Text('Supprimer'))
                      ])
            ])));
  }
}

Future<void> _categoryDialog(BuildContext context, WidgetRef ref, String cafeId,
    {Category? category}) async {
  final controller = TextEditingController(text: category?.name);
  await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
              title: Text(category == null
                  ? 'Ajouter une catégorie'
                  : 'Modifier la catégorie'),
              content: TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Nom')),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Annuler')),
                FilledButton(
                    onPressed: () async {
                      if (controller.text.trim().isEmpty) return;
                      await ref.read(menuRepositoryProvider).saveCategory(
                          id: category?.id,
                          cafeId: cafeId,
                          name: controller.text,
                          sortOrder: category?.sortOrder ?? 0);
                      if (dialogContext.mounted) Navigator.pop(dialogContext);
                    },
                    child: const Text('Enregistrer'))
              ]));
  controller.dispose();
}

Future<bool> _productDialog(
    BuildContext context, String cafeId, List<Category> categories,
    {Product? product}) async {
  return await showDialog<bool>(
        context: context,
        builder: (_) => _ProductDialog(
          cafeId: cafeId,
          categories: categories,
          product: product,
        ),
      ) ??
      false;
}

class _ProductDialog extends ConsumerStatefulWidget {
  const _ProductDialog({
    required this.cafeId,
    required this.categories,
    this.product,
  });

  final String cafeId;
  final List<Category> categories;
  final Product? product;

  @override
  ConsumerState<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends ConsumerState<_ProductDialog> {
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _description;
  late String _categoryId;
  late bool _active;
  XFile? _image;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.product?.name);
    _price = TextEditingController(text: widget.product?.price.toString());
    _description = TextEditingController(text: widget.product?.description);
    _categoryId = widget.product?.categoryId ?? widget.categories.first.id;
    _active = widget.product?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _chooseImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (!mounted) return;
    setState(() => _image = image);
  }

  Future<void> _save() async {
    final parsed = double.tryParse(_price.text.replaceAll(',', '.'));
    if (_name.text.trim().isEmpty || parsed == null || parsed <= 0) {
      setState(() => _error = 'Saisissez un nom et un prix valide.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      var path = widget.product?.imagePath;
      if (_image != null) {
        path = await ref
            .read(menuRepositoryProvider)
            .uploadProductImage(widget.cafeId, _image!);
      }
      await ref.read(menuRepositoryProvider).saveProduct(
            id: widget.product?.id,
            cafeId: widget.cafeId,
            categoryId: _categoryId,
            name: _name.text,
            price: parsed,
            description: _description.text,
            imagePath: path,
            isActive: _active,
          );
      if (!mounted) return;
      // Reset local state before removing the dialog route. Calling setState
      // after Navigator.pop can target a deactivated dialog element on web.
      setState(() => _saving = false);
      Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Enregistrement impossible : $error';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null
          ? 'Ajouter un produit'
          : 'Modifier le produit'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: _name,
            enabled: !_saving,
            decoration: const InputDecoration(labelText: 'Nom'),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _categoryId,
            decoration: const InputDecoration(labelText: 'Catégorie'),
            items: widget.categories
                .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                .toList(),
            onChanged: _saving
                ? null
                : (value) => setState(() => _categoryId = value!),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _price,
            enabled: !_saving,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Prix en MAD'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _description,
            enabled: !_saving,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          SwitchListTile(
            value: _active,
            onChanged:
                _saving ? null : (value) => setState(() => _active = value),
            title: Text(_active ? 'Actif' : 'Inactif'),
          ),
          OutlinedButton.icon(
            onPressed: _saving ? null : _chooseImage,
            icon: const Icon(Icons.image),
            label: Text(_image?.name ?? 'Choisir une image'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ]),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Enregistrement…' : 'Enregistrer'),
        ),
      ],
    );
  }
}

Future<void> _confirmDelete(BuildContext context, String message,
    Future<void> Function() action) async {
  final yes = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
                  title: const Text('Confirmation'),
                  content: Text(message),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(c, false),
                        child: const Text('Annuler')),
                    FilledButton(
                        onPressed: () => Navigator.pop(c, true),
                        child: const Text('Supprimer'))
                  ])) ??
      false;
  if (yes) await action();
}
