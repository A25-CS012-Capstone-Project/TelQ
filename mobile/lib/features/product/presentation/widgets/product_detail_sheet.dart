import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/product.dart';

class ProductDetailSheet extends StatelessWidget {
  final Product product;

  const ProductDetailSheet({super.key, required this.product});

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
      initialChildSize: 0.7,
      maxChildSize: 0.9,
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
                  // Product name
                  Center(
                    child: Text(
                      product.productName,
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF3E3B3B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Details
                  _buildDetailRow(
                    Icons.timer,
                    'Masa aktif',
                    '${product.durationDays} HARI',
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.public,
                    'Kuota Internet',
                    '${product.dataGb} GB',
                  ),
                  const SizedBox(height: 24),
                  // Bonuses section
                  _buildBonusesSection(),
                  const SizedBox(height: 24),
                  // Price section
                  Container(
                    padding: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: const Color(0xFFFF7D00), width: 2),
                      ),
                    ),
                    child: _buildDetailRow(
                      Icons.attach_money,
                      'Total Harga',
                      _formatPrice(product.price),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Buy button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Membeli ${product.productName}...'),
                            backgroundColor: const Color(0xFFFF7D00),
                          ),
                        );
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
      _buildBonusItem('Kuota Utama', '${product.dataGb} GB'),
    );

    if (product.streamingGbBonus > 0) {
      bonuses.add(_buildBonusItem('Bonus Streaming', '${product.streamingGbBonus} GB'));
    }
    if (product.gamingGbBonus > 0) {
      bonuses.add(_buildBonusItem('Bonus Gaming', '${product.gamingGbBonus} GB'));
    }
    if (product.callMinutesBonus > 0) {
      bonuses.add(_buildBonusItem('Bonus Telepon', '${product.callMinutesBonus} Menit'));
    }
    if (product.roamingDaysBonus > 0) {
      bonuses.add(_buildBonusItem('Bonus Roaming', '${product.roamingDaysBonus} Hari'));
    }
    if (product.socialGbBonus > 0) {
      bonuses.add(_buildBonusItem('Bonus Sosmed', '${product.socialGbBonus} GB'));
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
