enum AppRoute {
  onboarding,
  login,
  register,
}

extension AppRoutePath on AppRoute {
  String get path {
    switch (this) {
      case AppRoute.onboarding:
        return '/onboarding';
      case AppRoute.login:
        return '/login';
      case AppRoute.register:
        return '/register';
    }
  }
}
