import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/routes/app_route.dart';
import '../../../auth/presentation/widgets/widget_bubble.dart';
import '../../domain/entities/profile.dart';
import '../cubit/profile_cubit.dart';

const _orange = Color(0xFFFF7D00);
const _orangeLight = Color(0xFFFFA600);
const _orangeDark = Color(0xFFAF5920);

class ProfilePage extends StatefulWidget {
  /// Callback to navigate to product tab from HomeShell
  final VoidCallback? onNavigateToProduct;

  const ProfilePage({super.key, this.onNavigateToProduct});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _customerId;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserAndProfile();
  }

  Future<void> _loadUserAndProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getString('customer_id');
    final userName = prefs.getString('user_name') ?? 'User';
    
    setState(() {
      _customerId = customerId;
      _userName = userName;
    });

    if (customerId != null && mounted) {
      context.read<ProfileCubit>().loadProfile(customerId);
    }
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    if (!mounted) return;
    
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: 'Logout berhasil! Sampai jumpa lagi 👋',
      confirmBtnColor: _orange,
      confirmBtnTextStyle: const TextStyle(color: Colors.white),
      autoCloseDuration: const Duration(seconds: 2),
      onConfirmBtnTap: () {
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, AppRoute.login.path);
      },
    ).then((_) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoute.login.path);
      }
    });
  }

  String _formatCurrency(num amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2E9),
      body: Stack(
        children: [
          // Background bubbles
          ...BubblePresets.minimalSet(),
          // Main content
          SafeArea(
            child: BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                if (state.status == ProfileStatus.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: _orange),
                  );
                }

                if (state.status == ProfileStatus.failure) {
                  return _buildErrorState(state.error);
                }

                if (state.profile == null) {
                  return const Center(
                    child: CircularProgressIndicator(color: _orange),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    if (_customerId != null) {
                      await context.read<ProfileCubit>().loadProfile(_customerId!);
                    }
                  },
                  color: _orange,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _buildHeader(state.profile!),
                        const SizedBox(height: 16),
                        _buildPersonaSection(state.profile!.personas),
                        const SizedBox(height: 16),
                        _buildBehaviorStats(state.profile!.behaviorStats),
                        const SizedBox(height: 16),
                        _buildPurchaseChart(state.profile!.historyList),
                        const SizedBox(height: 16),
                        _buildHistorySummary(state.profile!.historySummary),
                        const SizedBox(height: 16),
                        _buildHistorySection(state),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            error ?? 'Gagal memuat profil',
            style: GoogleFonts.outfit(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_customerId != null) {
                context.read<ProfileCubit>().loadProfile(_customerId!);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _orange),
            child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(UserProfile profile) {
    final initials = (_userName ?? 'U').substring(0, 1).toUpperCase();
    final tierColor = _getTierColor(profile.header.spendingTier);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar with animated ring
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [_orange, tierColor],
                  ),
                ),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _orange,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName ?? 'User',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3E3B3B),
                      ),
                    ),
                    Text(
                      'ID: ${profile.header.customerId}',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Logout button
              IconButton(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout, color: Colors.red),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Badges
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBadge(profile.header.plan, Colors.blue),
              _buildBadge(profile.header.device, Colors.grey),
              _buildBadge(
                'Spending: ${profile.header.spendingTier.toUpperCase()}',
                tierColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPersonaSection(List<Persona> personas) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_orange, _orangeDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _orange.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                'YOUR PERSONA',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...personas.map((p) => _buildPersonaItem(p)),
        ],
      ),
    );
  }

  Widget _buildPersonaItem(Persona persona) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(persona.icon, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  persona.title,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  persona.desc,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBehaviorStats(BehaviorStats stats) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Behavior Summary',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3E3B3B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Stats grid
          Row(
            children: [
              Expanded(child: _buildStatItem('Rata-rata Data', '${stats.avgDataGb.toStringAsFixed(1)} GB/bln')),
              Expanded(child: _buildStatItem('Frekuensi Topup', '${stats.topupFreq}x /bln')),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatItem('Rata-rata Belanja', _formatCurrency(stats.monthlySpend))),
            ],
          ),
          const SizedBox(height: 20),
          // Progress bars
          _buildProgressBar('Travel Score', stats.travelScore, _orangeLight),
          const SizedBox(height: 12),
          _buildProgressBar('Video Streaming', stats.pctVideo, _orange),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3E3B3B),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(String label, double value, Color color) {
    final percent = (value * 100).clamp(0, 100);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey[600]),
            ),
            Text(
              '${percent.toStringAsFixed(0)}%',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0, 1),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseChart(List<PurchaseHistory> history) {
    if (history.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate category breakdown
    final categoryCount = <String, int>{};
    for (final h in history) {
      final cat = h.category.isNotEmpty ? h.category : 'General';
      categoryCount[cat] = (categoryCount[cat] ?? 0) + 1;
    }

    final total = history.length;
    final sections = categoryCount.entries.map((e) {
      final percentage = (e.value / total) * 100;
      final color = _getCategoryColor(e.key);
      
      return PieChartSectionData(
        value: e.value.toDouble(),
        title: '${percentage.toStringAsFixed(0)}%',
        color: color,
        radius: 50,
        titleStyle: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📈', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Distribusi Pembelian',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3E3B3B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Pie Chart
              SizedBox(
                width: 130,
                height: 130,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 25,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: categoryCount.entries.map((e) {
                    final color = _getCategoryColor(e.key);
                    final percentage = ((e.value / total) * 100).toStringAsFixed(0);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              e.key,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          Text(
                            '${e.value}x ($percentage%)',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF3E3B3B),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySummary(HistorySummary summary) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Pembelian',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF3E3B3B),
            ),
          ),
          const Divider(height: 24),
          _buildSummaryRow('Total Transaksi', '${summary.totalTrx}'),
          const SizedBox(height: 8),
          _buildSummaryRow('Total Pengeluaran', _formatCurrency(summary.totalSpend), isHighlight: true),
          const SizedBox(height: 12),
          Text(
            'Favorit Kamu:',
            style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE9CC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              summary.favoriteProduct,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _orangeDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isHighlight ? _orange : const Color(0xFF3E3B3B),
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection(ProfileState state) {
    final categories = ['All', 'Streaming', 'Gaming', 'Roaming', 'Voice', 'Social'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🕒', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Riwayat Pembelian',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3E3B3B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Category filter chips
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = state.selectedCategory == cat || 
                    (state.selectedCategory == null && cat == 'All');
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => context.read<ProfileCubit>().filterHistory(cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? _orange : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? _orange : Colors.grey[300]!,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          cat,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // History list
          if (state.filteredHistory.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'Tidak ada riwayat pembelian',
                  style: GoogleFonts.outfit(color: Colors.grey[500]),
                ),
              ),
            )
          else
            ...state.filteredHistory.map((h) => _buildHistoryCard(h)),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(PurchaseHistory history) {
    final borderColor = _getCategoryColor(history.category);
    final dateStr = history.purchaseDate != null
        ? DateFormat('dd MMM yyyy').format(history.purchaseDate!)
        : '-';

    return GestureDetector(
      onTap: () {
        // Navigate to product page when card is tapped
        if (widget.onNavigateToProduct != null) {
          widget.onNavigateToProduct!();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(color: borderColor, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        dateStr,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: borderColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          history.category,
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: borderColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    history.productName,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3E3B3B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Data: ${history.dataGb}GB | Durasi: ${history.durationDays} Hari',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatCurrency(history.price),
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3E3B3B),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_cart, size: 12, color: _orange),
                      const SizedBox(width: 4),
                      Text(
                        'Beli Lagi',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'high':
        return Colors.amber;
      case 'mid':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getCategoryColor(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('streaming')) return Colors.red;
    if (cat.contains('gaming')) return Colors.purple;
    if (cat.contains('roaming') || cat.contains('travel')) return Colors.amber;
    if (cat.contains('voice') || cat.contains('call')) return Colors.blue;
    if (cat.contains('social')) return Colors.pink;
    return Colors.grey;
  }
}
