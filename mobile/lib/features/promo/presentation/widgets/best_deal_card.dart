import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../product/domain/entities/product.dart';

class BestDealCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onBuy;
  final VoidCallback? onDetail;

  const BestDealCard({
    super.key,
    required this.product,
    this.onBuy,
    this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFFFA600), Colors.white],
          stops: [0.0, 0.6],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFA600).withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ini yang best seller
          Positioned(
            top: 12,
            left: 12,
            child: _buildBestSellerBadge(),
          ),
          // cuman hiasan
          Positioned(
            top: -15,
            right: 30,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFFA600).withValues(alpha: 0.3),
                    const Color(0xFFFF7D00).withValues(alpha: 0.2),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 10,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF7D00).withValues(alpha: 0.15),
              ),
            ),
          ),
          // konten
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32), // kasih jarak
                // nama produk
                Text(
                  product.productName,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                // yang putih2
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // tulisan benefit
                      Row(
                        children: [
                          _buildBenefit(
                            icon: Icons.access_time,
                            label: '${product.durationDays} Hari',
                          ),
                          const SizedBox(width: 16),
                          _buildBenefit(
                            icon: Icons.data_usage,
                            label: '${product.dataGb} GB',
                          ),
                        ],
                      ),
                      // bonus info
                      if (_hasBonus()) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8F0),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFFFA600).withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.card_giftcard,
                                size: 16,
                                color: Color(0xFFFFA600),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _buildBonusText(),
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      // harga dan tombol2
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Harga',
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  color: Colors.grey[500],
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                'Rp ${_formatPrice(product.price)}',
                                style: GoogleFonts.outfit(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFAF5920),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: onDetail,
                                child: Text(
                                  'DETAIL',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: onBuy,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFA600),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                ),
                                child: Text(
                                  'BELI',
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestSellerBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            'Best Seller',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFEF4444),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  bool _hasBonus() {
    return product.streamingGbBonus > 0 ||
        product.gamingGbBonus > 0 ||
        product.socialGbBonus > 0 ||
        product.callMinutesBonus > 0 ||
        product.roamingDaysBonus > 0;
  }

  String _buildBonusText() {
    final bonuses = <String>[];
    if (product.streamingGbBonus > 0) {
      bonuses.add('Streaming ${product.streamingGbBonus}GB');
    }
    if (product.gamingGbBonus > 0) {
      bonuses.add('Gaming ${product.gamingGbBonus}GB');
    }
    if (product.socialGbBonus > 0) {
      bonuses.add('Social ${product.socialGbBonus}GB');
    }
    if (product.callMinutesBonus > 0) {
      bonuses.add('Nelpon ${product.callMinutesBonus} Menit');
    }
    if (product.roamingDaysBonus > 0) {
      bonuses.add('Roaming ${product.roamingDaysBonus} Hari');
    }
    return 'Bonus: ${bonuses.join(', ')}';
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
  }
}
