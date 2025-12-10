import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../di/injection.dart';
import '../widgets/animated_bottom_nav.dart';
import '../../features/product/presentation/cubit/product_cubit.dart';
import '../../features/product/presentation/pages/product_page.dart';
import '../../features/promo/presentation/cubit/promo_cubit.dart';
import '../../features/promo/presentation/pages/promo_page.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/profile/presentation/pages/profile_page.dart';


class HomeShell extends StatefulWidget {
  final int initialIndex;

  const HomeShell({super.key, this.initialIndex = 0});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _currentIndex;
  late final ProductCubit _productCubit;
  late final PromoCubit _promoCubit;
  late final ProfileCubit _profileCubit;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _productCubit = getIt<ProductCubit>();
    _promoCubit = getIt<PromoCubit>();
    _profileCubit = getIt<ProfileCubit>();
    _initializeData();
  }

  Future<void> _initializeData() async {
    _productCubit.loadProducts();
    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getString('customer_id');
    if (customerId != null) {
      _promoCubit.loadPromoData(customerId);
      _profileCubit.loadProfile(customerId);
    }
  }

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _productCubit),
        BlocProvider.value(value: _promoCubit),
        BlocProvider.value(value: _profileCubit),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            const PromoPageContent(),
            const ProductPageContent(),
            ProfilePage(
              onNavigateToProduct: () {
                setState(() => _currentIndex = 1); // Switch to Product tab
              },
            ),
          ],
        ),
        bottomNavigationBar: AnimatedBottomNav(
          currentIndex: _currentIndex,
          onTap: _onNavTap,
          items: const [
            NavItem(index: 0, icon: Icons.local_offer, label: 'Promo'),
            NavItem(index: 1, icon: Icons.shopping_cart, label: 'Product'),
            NavItem(index: 2, icon: Icons.person, label: 'User'),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
