class AuthValidators {
  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Veuillez saisir votre adresse e-mail.';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Saisissez une adresse e-mail valide.';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir votre mot de passe.';
    }
    if (value.length < 6) return 'Le mot de passe doit contenir 6 caractères.';
    return null;
  }

  static String? confirmation(String? value, String password) {
    final error = AuthValidators.password(value);
    if (error != null) return error;
    if (value != password) return 'Les mots de passe ne correspondent pas.';
    return null;
  }
}
