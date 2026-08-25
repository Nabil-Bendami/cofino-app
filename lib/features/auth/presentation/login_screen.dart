import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import 'auth_validators.dart';
import 'widgets/auth_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(authControllerProvider.notifier).signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  Future<void> _forgotPassword() async {
    final controller =
        TextEditingController(text: _emailController.text.trim());
    final key = GlobalKey<FormState>();
    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mot de passe oublié'),
        content: Form(
          key: key,
          child: TextFormField(
            controller: controller,
            validator: AuthValidators.email,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Adresse e-mail',
              prefixIcon: Icon(Icons.mail_outline),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          FilledButton(
            onPressed: () {
              if (key.currentState?.validate() ?? false) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (email == null || !mounted) return;
    final sent =
        await ref.read(authControllerProvider.notifier).resetPassword(email);
    if (!mounted) return;
    if (sent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Un lien de réinitialisation vous a été envoyé.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    ref.listen<AsyncValue<void>>(authControllerProvider, (_, next) {
      next.whenOrNull(error: (error, _) {
        if (mounted) setState(() => _error = error.toString());
      });
    });

    return AuthScaffold(
      child: AuthCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CoffeeImageHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 28),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AuthTabSwitcher(
                        signInSelected: true,
                        onSignIn: () {},
                        onSignUp: () => context.go('/signup'),
                      ),
                      const SizedBox(height: 16),
                      if (_error != null) ...[
                        AuthErrorMessage(message: _error!),
                        const SizedBox(height: 14),
                      ],
                      AuthTextField(
                        controller: _emailController,
                        label: 'Adresse e-mail',
                        icon: Icons.mail_outline,
                        validator: AuthValidators.email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                      ),
                      const SizedBox(height: 14),
                      PasswordField(
                        controller: _passwordController,
                        validator: AuthValidators.password,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _login(),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed:
                              authState.isLoading ? null : _forgotPassword,
                          style: TextButton.styleFrom(
                              foregroundColor: AuthPalette.cream),
                          child: const Text('Mot de passe oublié ?'),
                        ),
                      ),
                      const SizedBox(height: 4),
                      PrimaryAuthButton(
                        label: 'Se connecter',
                        loading: authState.isLoading,
                        onPressed: _login,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
