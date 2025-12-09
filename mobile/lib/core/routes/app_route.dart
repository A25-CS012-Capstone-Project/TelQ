enum AppRoute {
  onboarding,
  login,
  register,
  home,
  product,
  promo,
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
      case AppRoute.home:
        return '/home';
      case AppRoute.product:
        return '/product';
      case AppRoute.promo:
        return '/promo';
    }
  }
}
