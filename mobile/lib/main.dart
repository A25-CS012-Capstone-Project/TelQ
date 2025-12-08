import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/routes/app_route.dart';
import 'core/pages/home_shell.dart';
import 'di/injection.dart';
import 'features/auth/presentation/cubit/login_cubit.dart';
import 'features/auth/presentation/cubit/register_cubit.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/product/presentation/cubit/product_cubit.dart';
import 'features/product/presentation/pages/product_page.dart';
import 'features/promo/presentation/cubit/promo_cubit.dart';
import 'features/promo/presentation/pages/promo_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF5821F)),
        scaffoldBackgroundColor: const Color(0xFFF6F2E9),
        useMaterial3: true,
      ),
      initialRoute: AppRoute.onboarding.path,
      routes: {
        AppRoute.onboarding.path: (_) => BlocProvider(
              create: (_) => getIt<OnboardingCubit>(),
              child: const OnboardingPage(),
            ),
        AppRoute.login.path: (_) => BlocProvider(
              create: (_) => getIt<LoginCubit>(),
              child: const LoginPage(),
            ),
        AppRoute.register.path: (_) => BlocProvider(
              create: (_) => getIt<RegisterCubit>(),
              child: const RegisterPage(),
            ),
        AppRoute.home.path: (_) => const HomeShell(initialIndex: 0),
        AppRoute.product.path: (_) => BlocProvider(
              create: (_) => getIt<ProductCubit>(),
              child: const ProductPage(),
            ),
        AppRoute.promo.path: (_) => BlocProvider(
              create: (_) => getIt<PromoCubit>(),
              child: const PromoPage(),
            ),
      },
    );
  }
}
