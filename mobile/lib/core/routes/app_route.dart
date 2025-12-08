enum AppRoute {
  onboarding,
  login,
  register,
  product,
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
      case AppRoute.product:
        return '/product';
    }
  }
}
