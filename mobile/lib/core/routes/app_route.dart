enum AppRoute {
  onboarding,
  login,
  register,
  questionnaire,
  home,
  product,
  promo,
}

extension AppRoutePath on AppRoute {
  String get path {
    switch (this) {
      case AppRoute.onboarding:
        return '/';
      case AppRoute.login:
        return '/login';
      case AppRoute.register:
        return '/register';
      case AppRoute.questionnaire:
        return '/questionnaire';
      case AppRoute.home:
        return '/home';
      case AppRoute.product:
        return '/product';
      case AppRoute.promo:
        return '/promo';
    }
  }
}
