import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'auth_validators.dart';
import 'widgets/auth_widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _showManagedMessage = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _showManagedMessage = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: AuthCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CoffeeImageHeader(height: 185),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    AuthTabSwitcher(
                      signInSelected: false,
                      onSignIn: () => context.go('/login'),
                      onSignUp: () {},
                    ),
                    const SizedBox(height: 12),
                    if (_showManagedMessage) ...[
                      const AuthErrorMessage(
                        message:
                            'La création de compte est gérée par le Manager de votre café. Demandez-lui votre invitation.',
                      ),
                      const SizedBox(height: 12),
                    ],
                    AuthTextField(
                      controller: _name,
                      label: 'Nom complet',
                      icon: Icons.person_outline,
                      validator: (value) => (value?.trim().isEmpty ?? true)
                          ? 'Veuillez saisir votre nom.'
                          : null,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    AuthTextField(
                      controller: _email,
                      label: 'Adresse e-mail',
                      icon: Icons.mail_outline,
                      validator: AuthValidators.email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    PasswordField(
                      controller: _password,
                      validator: AuthValidators.password,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    PasswordField(
                      controller: _confirmation,
                      label: 'Confirmer le mot de passe',
                      validator: (value) => AuthValidators.confirmation(
                        value,
                        _password.text,
                      ),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 20),
                    PrimaryAuthButton(
                      label: 'Demander un accès',
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
