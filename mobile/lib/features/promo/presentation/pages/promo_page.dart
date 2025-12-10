import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/routes/app_route.dart';
import '../../../../core/widgets/animated_bottom_nav.dart';
import '../../../../core/helpers/purchase_helper.dart';
import '../cubit/promo_cubit.dart';
import '../widgets/recommendation_card.dart';
import '../widgets/best_deal_card.dart';
import '../widgets/preference_questionnaire.dart';
import '../widgets/promo_detail_sheet.dart';

class PromoPage extends StatefulWidget {
  const PromoPage({super.key});

  @override
  State<PromoPage> createState() => _PromoPageState();
}

class _PromoPageState extends State<PromoPage> {
  int _currentNavIndex = 0; // Promo tab is selected
  String? _customerId;

  @override
  void initState() {
    super.initState();
    _loadUserAndData();
  }

  Future<void> _loadUserAndData() async {
    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getString('customer_id');
    setState(() => _customerId = customerId);

    if (customerId != null && mounted) {
      context.read<PromoCubit>().loadPromoData(customerId);
    }
  }

  void _onNavTap(int index) {
    setState(() => _currentNavIndex = index);
    if (index == 1) {
      Navigator.pushReplacementNamed(context, AppRoute.product.path);
    } else if (index == 2) {
      // TODO: Navigate to Profile page
    }
  }

  void _onPreferenceSelected(String preference) {
    if (_customerId != null) {
      context.read<PromoCubit>().submitPreference(_customerId!, preference);
    }
  }

  void _onRefreshRecommendations() {
    if (_customerId != null) {
      context.read<PromoCubit>().refreshRecommendations(_customerId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2E9),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            if (_customerId != null) {
              await context.read<PromoCubit>().loadPromoData(_customerId!);
            }
          },
          color: const Color(0xFFFF7D00),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildContent(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF7D00), Color(0xFFFFA600)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF7D00).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Promo & Rekomendasi',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Paket terbaik berdasarkan kebiasaanmu',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<PromoCubit, PromoState>(
      builder: (context, state) {
        if (state.status == PromoStatus.loading) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFFFF7D00)),
            ),
          );
        }

        if (state.status == PromoStatus.failure) {
          return _buildErrorState(state.error);
        }

        if (state.status == PromoStatus.coldStart ||
            state.status == PromoStatus.submittingPreference) {
          return _buildColdStartContent(state);
        }

        return _buildMainContent(state);
      },
    );
  }

  Widget _buildErrorState(String? error) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              error ?? 'Gagal memuat data',
              style: GoogleFonts.outfit(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_customerId != null) {
                  context.read<PromoCubit>().loadPromoData(_customerId!);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7D00),
              ),
              child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColdStartContent(PromoState state) {
    return Column(
      children: [
        const SizedBox(height: 24),
        PreferenceQuestionnaire(
          onPreferenceSelected: _onPreferenceSelected,
          isLoading: state.status == PromoStatus.submittingPreference,
          selectedPreference: state.selectedPreference,
        ),
        if (state.bestDeals.isNotEmpty) ...[
          const SizedBox(height: 32),
          _buildBestDealsSection(state),
        ],
      ],
    );
  }

  Widget _buildMainContent(PromoState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // yang section rekomendasi
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rekomendasi AI',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3E3B3B),
                    ),
                  ),
                  Text(
                    'Berdasarkan pola penggunaanmu',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: state.status == PromoStatus.refreshing
                    ? null
                    : _onRefreshRecommendations,
                icon: state.status == PromoStatus.refreshing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFFF7D00),
                        ),
                      )
                    : const Icon(Icons.refresh, size: 18),
                label: Text(
                  'Perbarui',
                  style: GoogleFonts.outfit(fontSize: 13),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFF7D00),
                ),
              ),
            ],
          ),
        ),
        // list rekomendasi guys
        if (state.recommendations.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Center(
                child: Text(
                  'Belum ada rekomendasi. Coba beli paket terlebih dahulu!',
                  style: GoogleFonts.outfit(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: state.recommendations.length,
            itemBuilder: (context, index) {
              final rec = state.recommendations[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: RecommendationCard(
                  recommendation: rec,
                  onDetail: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => PromoDetailSheet(recommendation: rec),
                    );
                  },
                  onBuy: () {
                    PurchaseHelper.buyProduct(
                      context: context,
                      productId: rec.productId,
                      productName: rec.productName,
                    );
                  },
                ),
              );
            },
          ),
        // best deal section
        if (state.bestDeals.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildBestDealsSection(state),
        ],
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildBestDealsSection(PromoState state) {
    // show 8 item tapi ternyata cuman 4 ya gapapa sih namanya juga coba coba
    final dealsToShow = state.bestDeals.take(8).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                'Best Seller',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3E3B3B),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '🔥 ${dealsToShow.length} Paket',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Paket paling diminati pelanggan',
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: dealsToShow.length,
          itemBuilder: (context, index) {
            final deal = dealsToShow[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: BestDealCard(
                product: deal,
                onDetail: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => PromoDetailSheet(product: deal),
                  );
                },
                onBuy: () {
                  PurchaseHelper.buyProduct(
                    context: context,
                    productId: deal.productId,
                    productName: deal.productName,
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return AnimatedBottomNav(
      currentIndex: _currentNavIndex,
      onTap: _onNavTap,
      items: const [
        NavItem(index: 0, icon: Icons.local_offer, label: 'Promo'),
        NavItem(index: 1, icon: Icons.shopping_cart, label: 'Product'),
        NavItem(index: 2, icon: Icons.person, label: 'User'),
      ],
    );
  }
}

/// yang ini yang di home shell biar gak perlu render ulang tiap balik home terus ke rekomendasi
class PromoPageContent extends StatefulWidget {
  const PromoPageContent({super.key});

  @override
  State<PromoPageContent> createState() => _PromoPageContentState();
}

class _PromoPageContentState extends State<PromoPageContent> {
  String? _customerId;

  @override
  void initState() {
    super.initState();
    _loadCustomerId();
  }

  Future<void> _loadCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getString('customer_id');
    if (mounted) {
      setState(() => _customerId = customerId);
      // biar cubit di load dulu
      final cubit = context.read<PromoCubit>();
      if (cubit.state.status == PromoStatus.idle && customerId != null) {
        cubit.loadPromoData(customerId);
      }
    }
  }

  void _onPreferenceSelected(String preference) {
    if (_customerId != null) {
      context.read<PromoCubit>().submitPreference(_customerId!, preference);
    }
  }

  void _onRefreshRecommendations() {
    if (_customerId != null) {
      context.read<PromoCubit>().refreshRecommendations(_customerId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2E9),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            if (_customerId != null) {
              await context.read<PromoCubit>().loadPromoData(_customerId!);
            }
          },
          color: const Color(0xFFFF7D00),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF7D00), Color(0xFFFFA600)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_offer, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Promo Spesial',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Rekomendasi terbaik untukmu',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<PromoCubit, PromoState>(
      builder: (context, state) {
        switch (state.status) {
          case PromoStatus.idle:
          case PromoStatus.loading:
            return const SizedBox(
              height: 300,
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFFF7D00)),
              ),
            );
          case PromoStatus.failure:
            return _buildErrorContent(state.error);
          case PromoStatus.coldStart:
          case PromoStatus.submittingPreference:
            return _buildColdStartContent(state);
          case PromoStatus.success:
          case PromoStatus.refreshing:
            return _buildMainContent(state);
        }
      },
    );
  }

  Widget _buildErrorContent(String? error) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              error ?? 'Gagal memuat data',
              style: GoogleFonts.outfit(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_customerId != null) {
                  context.read<PromoCubit>().loadPromoData(_customerId!);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7D00),
              ),
              child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColdStartContent(PromoState state) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: PreferenceQuestionnaire(
            onPreferenceSelected: _onPreferenceSelected,
            isLoading: state.status == PromoStatus.submittingPreference,
            selectedPreference: state.selectedPreference,
          ),
        ),
        if (state.bestDeals.isNotEmpty) _buildBestDealsSection(state),
      ],
    );
  }

  Widget _buildMainContent(PromoState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // rekomendasi section
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '✨ Untukmu',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3E3B3B),
                    ),
                  ),
                  if (state.status == PromoStatus.refreshing)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFFF7D00),
                      ),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Color(0xFFFF7D00)),
                      onPressed: _onRefreshRecommendations,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Dipilih AI berdasarkan kebutuhanmu',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        // rekomendasi cards
        ...state.recommendations.map((rec) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: RecommendationCard(
            recommendation: rec,
            onBuy: () {
              PurchaseHelper.buyProduct(
                context: context,
                productId: rec.productId,
                productName: rec.productName,
              );
            },
            onDetail: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => PromoDetailSheet(
                  recommendation: rec,
                  onBuy: () {
                    PurchaseHelper.buyProduct(
                      context: context,
                      productId: rec.productId,
                      productName: rec.productName,
                    );
                  },
                ),
              );
            },
          ),
        )),
        const SizedBox(height: 20),
        // section best deals
        if (state.bestDeals.isNotEmpty) _buildBestDealsSection(state),
      ],
    );
  }

  Widget _buildBestDealsSection(PromoState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🔥 Best Seller',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3E3B3B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Paket paling laris minggu ini',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: state.bestDeals.length > 8 ? 8 : state.bestDeals.length,
          itemBuilder: (context, index) {
            final deal = state.bestDeals[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: BestDealCard(
                product: deal,
                onBuy: () {
                  PurchaseHelper.buyProduct(
                    context: context,
                    productId: deal.productId,
                    productName: deal.productName,
                  );
                },
                onDetail: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => PromoDetailSheet(
                      product: deal,
                      onBuy: () {
                        PurchaseHelper.buyProduct(
                          context: context,
                          productId: deal.productId,
                          productName: deal.productName,
                        );
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
