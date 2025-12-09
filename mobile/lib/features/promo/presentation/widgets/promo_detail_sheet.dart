import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../product/domain/entities/product.dart';
import '../../domain/entities/recommendation.dart';

/// detail sheet buat promo dan product jadi satu aja
class PromoDetailSheet extends StatelessWidget {
  final Product? product;
  final Recommendation? recommendation;
  final VoidCallback? onBuy;

  const PromoDetailSheet({
    super.key,
    this.product,
    this.recommendation,
    this.onBuy,
  }) : assert(product != null || recommendation != null, 'Either product or recommendation must be provided');

  // Getters
  String get productName => recommendation?.productName ?? product!.productName;
  int get price => recommendation?.price ?? product!.price;
  int get dataGb => recommendation?.dataGb ?? product!.dataGb;
  int get durationDays => recommendation?.durationDays ?? product!.durationDays;
  int get streamingGbBonus => recommendation?.streamingGbBonus ?? product!.streamingGbBonus;
  int get gamingGbBonus => recommendation?.gamingGbBonus ?? product!.gamingGbBonus;
  int get socialGbBonus => recommendation?.socialGbBonus ?? product!.socialGbBonus;
  int get callMinutesBonus => recommendation?.callMinutesBonus ?? product!.callMinutesBonus;
  int get roamingDaysBonus => recommendation?.roamingDaysBonus ?? product!.roamingDaysBonus;
  int get smsBonus => recommendation?.smsBonus ?? product?.smsBonus ?? 0;
  
  // yang ini cuman buat rekomendasi
  String? get reason => recommendation?.reason;
  int? get matchPercentage => recommendation?.matchPercentage;

  String _formatPrice(int price) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Header
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Color(0xFFFF7D00),
                          size: 24,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Detail Paket',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF3E3B3B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // product name yang sesuai dengan rekomendasi
                  if (matchPercentage != null) ...[
                    Center(child: _buildMatchBadge()),
                    const SizedBox(height: 12),
                  ],
                  Center(
                    child: Text(
                      productName,
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF3E3B3B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // yang ini AI insight
                  if (reason != null) ...[
                    _buildInsightSection(),
                    const SizedBox(height: 24),
                  ],
                  // tombol detail
                  _buildDetailRow(
                    Icons.timer,
                    'Masa aktif',
                    '$durationDays HARI',
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.public,
                    'Kuota Internet',
                    '$dataGb GB',
                  ),
                  const SizedBox(height: 24),
                  // bonus section
                  _buildBonusesSection(),
                  const SizedBox(height: 24),
                  // section harga
                  Container(
                    padding: const EdgeInsets.only(top: 16),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Color(0xFFFF7D00), width: 2),
                      ),
                    ),
                    child: _buildDetailRow(
                      Icons.attach_money,
                      'Total Harga',
                      _formatPrice(price),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // tombol beli
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onBuy?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7D00),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        'Beli Sekarang',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMatchBadge() {
    final pct = matchPercentage!;
    Color bgColor;
    Color textColor;
    String icon;

    if (pct >= 80) {
      bgColor = const Color(0xFFD1FAE5);
      textColor = const Color(0xFF047857);
      icon = '🔥';
    } else if (pct >= 60) {
      bgColor = const Color(0xFFFEF3C7);
      textColor = const Color(0xFFB45309);
      icon = '👍';
    } else {
      bgColor = const Color(0xFFF3F4F6);
      textColor = const Color(0xFF4B5563);
      icon = '✨';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            'Match $pct%',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF7D00).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline,
            size: 24,
            color: Color(0xFFFF7D00),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI INSIGHT',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFF7D00),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reason!,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFF7D00), size: 32),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF3E3B3B),
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFFF7D00),
          ),
        ),
      ],
    );
  }

  Widget _buildBonusesSection() {
    final bonuses = <Widget>[];

    bonuses.add(
      _buildBonusItem('Kuota Utama', '$dataGb GB'),
    );

    if (streamingGbBonus > 0) {
      bonuses.add(_buildBonusItem('Bonus Streaming', '$streamingGbBonus GB'));
    }
    if (gamingGbBonus > 0) {
      bonuses.add(_buildBonusItem('Bonus Gaming', '$gamingGbBonus GB'));
    }
    if (callMinutesBonus > 0) {
      bonuses.add(_buildBonusItem('Bonus Telepon', '$callMinutesBonus Menit'));
    }
    if (roamingDaysBonus > 0) {
      bonuses.add(_buildBonusItem('Bonus Roaming', '$roamingDaysBonus Hari'));
    }
    if (socialGbBonus > 0) {
      bonuses.add(_buildBonusItem('Bonus Sosmed', '$socialGbBonus GB'));
    }
    if (smsBonus > 0) {
      bonuses.add(_buildBonusItem('Bonus SMS', '$smsBonus SMS'));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Termasuk:',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF3E3B3B),
            ),
          ),
          const SizedBox(height: 12),
          ...bonuses,
        ],
      ),
    );
  }

  Widget _buildBonusItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFFFF7D00),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$label $value',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: const Color(0xFFFF7D00),
            ),
          ),
        ],
      ),
    );
  }
}
