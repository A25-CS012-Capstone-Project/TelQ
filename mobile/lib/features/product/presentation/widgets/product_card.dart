import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onBuy;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onBuy,
  });

  String _formatPrice(int price) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  String _parseProductName() {
    final words = product.productName.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) {
      final gbIndex = words.indexWhere((w) => w.contains('GB'));
      if (gbIndex != -1 && gbIndex > 0) {
        return '${words.sublist(0, gbIndex).join(' ')}\n${words.sublist(gbIndex).join(' ')}';
      }
      return '${words.sublist(0, 2).join(' ')}\n${words.sublist(2).join(' ')}';
    }
    return product.productName;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xBFFF7D00), // rgba(255, 125, 0, 0.76)
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(4, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // headernya ya biar bagus
          Container(
            padding: const EdgeInsets.all(20),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // dekorasi yang bulet2 itu apalah
                Positioned(
                  top: -10,
                  right: -30,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF9A02F), Color(0xFFAF5920)],
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 50,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Color(0xFFAF5920),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  top: 25,
                  right: 10,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFAF5920),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // nama produk
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Text(
                    _parseProductName(),
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3E3B3B),
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // area yang ada kontenya
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KEUNTUNGAN',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                _buildBenefitItem(
                  Icons.access_time,
                  'Masa berlaku ${product.durationDays} Hari',
                ),
                const SizedBox(height: 8),
                _buildBenefitItem(
                  Icons.data_usage,
                  'Kuota utama ${product.dataGb} GB',
                ),
                const SizedBox(height: 16),
                // ini yang ada harganya
                Container(
                  padding: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HARGA',
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[500],
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatPrice(product.price),
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFF7D00),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // ini button aksi atau action button
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onBuy,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7D00),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          'BELI',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: onTap,
                      child: Text(
                        'DETAIL',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[400]),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: const Color(0xFF3E3B3B),
          ),
        ),
      ],
    );
  }
}
