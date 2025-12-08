import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:telQ_mobile/core/routes/app_route.dart';

import 'package:telQ_mobile/features/auth/presentation/widgets/glass_button.dart';
import 'package:telQ_mobile/features/auth/presentation/widgets/widget_bubble.dart';
import '../cubit/onboarding_cubit.dart';
import '../widgets/onboarding_cards.dart';

const _orange = Color(0xFFF5821F);

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // init pake default pref
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OnboardingCubit>().initialize();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2E9),
      body: Stack(
        children: [
          const Bubble(size: 160, alignment: Alignment(-1.05, -1.05)),
          const Bubble(size: 140, alignment: Alignment(1.05, -0.75)),
          const Bubble(size: 130, alignment: Alignment(-1.0, 0.95)),
          const Bubble(size: 150, alignment: Alignment(1.05, 1.05)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset('assets/images/Logo_TelQ.png', height: 26),
                  ),
                  Expanded(
                    child: BlocBuilder<OnboardingCubit, OnboardingState>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            Expanded(
                              child: PageView(
                                controller: _pageController,
                                onPageChanged: (i) => context.read<OnboardingCubit>().pageChanged(i),
                                children: const [
                                  _PageOne(),
                                  _PageTwo(),
                                  _PageThree(),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            SmoothPageIndicator(
                              controller: _pageController,
                              count: 3,
                              effect: ExpandingDotsEffect(
                                dotHeight: 8,
                                dotWidth: 8,
                                spacing: 8,
                                activeDotColor: _orange,
                                dotColor: Colors.black26,
                              ),
                            ),
                            const SizedBox(height: 16),
                            GlassButton(
                              label: state.pageIndex == 2 ? 'Mulai Sekarang' : 'Lanjut',
                              loading: false,
                              onPressed: () {
                                if (state.pageIndex == 2) {
                                  Navigator.pushReplacementNamed(context, AppRoute.login.path);
                                } else {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 280),
                                    curve: Curves.easeOut,
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageOne extends StatelessWidget {
  const _PageOne();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          Image.asset('assets/images/hero_index.png', height: 230, fit: BoxFit.contain),
          const SizedBox(height: 18),
          Text(
            'Temukan Paket Telekomunikasi yang Paling Cocok Untukmu!',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Text(
            'Dapatkan rekomendasi paket data, telepon, dan hiburan berdasarkan kebiasaanmu.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54, height: 1.4),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _PageTwo extends StatelessWidget {
  const _PageTwo();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const preferences = [
      ('Streaming', Icons.tv, Color(0xFFF5821F)),
      ('Gaming', Icons.sports_esports, Color(0xFFEE4B5E)),
      ('Roaming', Icons.public, Color(0xFF4A90E2)),
      ('Hemat Biaya', Icons.savings, Color(0xFF8A56E6)),
    ];

    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              Text(
                'Bantu kami mengetahui preferensi anda',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: Colors.black87),
              ),
              const SizedBox(height: 6),
              Text(
                'Apa yang paling penting bagi Anda dalam memilih paket data?',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: preferences
                    .map(
                      (p) => ChoicePill(
                        icon: p.$2,
                        label: p.$1,
                        activeColor: p.$3,
                        bgColor: Colors.white,
                        selected: state.selectedPreference == p.$1,
                        onTap: () => context.read<OnboardingCubit>().selectPreference(p.$1),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Rekomendasi paket ', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                        Text(
                          state.selectedPreference ?? 'Streaming',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900, color: _orange),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildProductList(state),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductList(OnboardingState state) {
    if (state.isLoadingFiltered) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(color: _orange),
        ),
      );
    }

    if (state.filteredProducts.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: Text(
            'Pilih preferensi untuk melihat rekomendasi',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: state.filteredProducts.take(5).map((product) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ProductCard(
              name: product.name,
              subtitle: product.subtitle,
              price: product.formattedPrice,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PageThree extends StatelessWidget {
  const _PageThree();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Text(
                'Keunggulan TelQ',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: Colors.black87),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Expanded(
                    child: FeatureCard(
                      icon: Icons.wifi,
                      title: 'Sinyal Genceng',
                      subtitle: 'Akses internet lancar untuk streaming, chat, & kerja.',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: FeatureCard(
                      icon: Icons.signal_cellular_alt,
                      title: 'Sinyal Stabil',
                      subtitle: 'Koneksi stabil untuk aktivitas harian.',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: FeatureCard(
                      icon: Icons.security,
                      title: 'Keamanan',
                      subtitle: 'Data aman dengan enkripsi.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'BEST DEAL',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                'Mudah & hemat hanya di TelQ Store. Tarif flat ongkir hanya Rp5.000 untuk kartu SIM',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 12),
              // gambar payment method
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _paymentLogo('assets/images/gopay.png'),
                  const SizedBox(width: 16),
                  _paymentLogo('assets/images/bca.png'),
                  const SizedBox(width: 16),
                  _paymentLogo('assets/images/ovo.png'),
                  const SizedBox(width: 16),
                  _paymentLogo('assets/images/dana.png'),
                ],
              ),
              const SizedBox(height: 12),
              _buildBestDeals(state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBestDeals(OnboardingState state) {
    if (state.isLoadingBestDeals) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(color: _orange),
        ),
      );
    }

    if (state.bestDeals.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: Text(
            'Memuat penawaran terbaik...',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: state.bestDeals.take(5).map((product) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ProductCard(
              name: product.name,
              subtitle: product.subtitle,
              price: product.formattedPrice,
            ),
          );
        }).toList(),
      ),
    );
  }
}

Widget _paymentLogo(String assetPath) => Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Image.asset(
        assetPath,
        height: 24,
        width: 48,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const SizedBox(
          height: 24,
          width: 48,
          child: Icon(Icons.payment, color: Colors.grey),
        ),
      ),
    );