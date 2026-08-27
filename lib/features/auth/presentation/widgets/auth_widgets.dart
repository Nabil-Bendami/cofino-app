import 'package:flutter/material.dart';

class AuthPalette {
  static const background = Color(0xFFF3F3F3);
  static const card = Color(0xFF2C2E33);
  static const dark = Color(0xFF242529);
  static const cream = Color(0xFFFFFFFF);
  static const mutedCream = Color(0xFFECECEC);
  static const field = Color(0xFFF8F8F8);

  // Welcome dark theme palette
  static const darkRoast = Color(0xFF2C2E33);
  static const darkRoastGradientTop = Color(0xFF393B41);
  static const goldenAmber = Color(0xFFF58A14);
  static const darkAmberText = Color(0xFFFFFFFF);
  static const subtitleTaupe = Color(0xFFD2D2D4);
}

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthPalette.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: constraints.maxHeight - 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CoffeeImageHeader extends StatelessWidget {
  const CoffeeImageHeader({super.key, this.height = 205});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Image.asset(
        'lib/menu-image/coffe-normal.png',
        fit: BoxFit.cover,
        alignment: const Alignment(0, .25),
        errorBuilder: (_, __, ___) => const ColoredBox(
          color: AuthPalette.mutedCream,
          child: Center(
              child: Icon(Icons.coffee, size: 64, color: AuthPalette.dark)),
        ),
      ),
    );
  }
}

class AuthTabSwitcher extends StatelessWidget {
  const AuthTabSwitcher({
    super.key,
    required this.signInSelected,
    required this.onSignIn,
    required this.onSignUp,
  });

  final bool signInSelected;
  final VoidCallback onSignIn;
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    Widget tab(String label, bool selected, VoidCallback onTap) => Expanded(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: AuthPalette.cream,
                      fontSize: 16,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 3,
                    width: selected ? 62 : 0,
                    decoration: BoxDecoration(
                      color: AuthPalette.cream,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

    return Row(
      children: [
        tab('Connexion', signInSelected, onSignIn),
        tab('Inscription', !signInSelected, onSignUp),
      ],
    );
  }
}

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      autofillHints: autofillHints,
      style: const TextStyle(color: AuthPalette.dark),
      decoration: _decoration(label, icon),
    );
  }
}

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.label = 'Mot de passe',
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      autofillHints: const [AutofillHints.password],
      style: const TextStyle(color: AuthPalette.dark),
      decoration: _decoration(widget.label, Icons.lock_outline).copyWith(
        suffixIcon: IconButton(
          tooltip:
              _obscure ? 'Afficher le mot de passe' : 'Masquer le mot de passe',
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(_obscure
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined),
          color: AuthPalette.dark,
        ),
      ),
    );
  }
}

InputDecoration _decoration(String label, IconData icon) => InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AuthPalette.dark),
      prefixIcon: Icon(icon, color: AuthPalette.dark),
      filled: true,
      fillColor: AuthPalette.field,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AuthPalette.goldenAmber, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF8A2635)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF8A2635), width: 2),
      ),
    );

class PrimaryAuthButton extends StatelessWidget {
  const PrimaryAuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AuthPalette.goldenAmber,
          disabledBackgroundColor:
              AuthPalette.goldenAmber.withValues(alpha: .65),
          foregroundColor: AuthPalette.cream,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
          elevation: 5,
          shadowColor: Colors.black38,
        ),
        child: loading
            ? const LoadingButton()
            : Text(label,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class LoadingButton extends StatelessWidget {
  const LoadingButton({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.square(
        dimension: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AuthPalette.cream,
        ),
      );
}

class AuthErrorMessage extends StatelessWidget {
  const AuthErrorMessage({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE5E8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFF8A2635), size: 20),
            const SizedBox(width: 8),
            Expanded(
                child: Text(message,
                    style: const TextStyle(color: Color(0xFF681B29)))),
          ],
        ),
      );
}

class AuthCard extends StatelessWidget {
  const AuthCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: DecoratedBox(
          decoration: const BoxDecoration(color: AuthPalette.card),
          child: child,
        ),
      );
}
