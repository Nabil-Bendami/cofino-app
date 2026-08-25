class RouteProfile {
  const RouteProfile({required this.role, required this.isActive});
  final String role;
  final bool isActive;
}

String? resolveAppRedirect(
    {required String location,
    required bool authenticated,
    required bool profileLoading,
    RouteProfile? profile}) {
  const publicRoutes = {'/welcome', '/login', '/signup'};
  if (!authenticated) {
    return publicRoutes.contains(location) ? null : '/welcome';
  }
  if (profileLoading) return location == '/' ? null : '/';
  if (profile == null || !profile.isActive) return '/login';
  final home = profile.role == 'manager' ? '/manager' : '/server';
  if (location == '/' || publicRoutes.contains(location)) return home;
  if (location.startsWith('/manager') && profile.role != 'manager') return home;
  if (location.startsWith('/server') && profile.role != 'serveur') return home;
  return null;
}
