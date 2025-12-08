import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../cubit/product_cubit.dart';
import '../widgets/product_card.dart';
import '../widgets/product_detail_sheet.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int _currentNavIndex = 1; // Product tab is selected by default

  final List<String> _categories = [
    'Semua',
    'Streaming',
    'Gaming',
    'Hemat',
    'Voice',
    'Roaming',
    'Social',
  ];

  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().loadProducts();
  }

  void _onCategoryTap(String category) {
    setState(() => _selectedCategory = category);
    context.read<ProductCubit>().loadByCategory(
          category == 'Semua' ? '' : category,
        );
  }

  void _onNavTap(int index) {
    setState(() => _currentNavIndex = index);
    // Navigation will be added later for Promo and User tabs
    if (index == 0) {
      // TODO: Navigate to Promo/Best Deals page
    } else if (index == 2) {
      // TODO: Navigate to Profile page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2E9),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCategoryChips(),
            Expanded(child: _buildProductList()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFF7D00),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shopping_cart, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Produk',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3E3B3B),
                  ),
                ),
                Text(
                  'Pilih paket terbaik untukmu',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _onCategoryTap(category),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFF7D00) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFF7D00) : Colors.grey[300]!,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFFFF7D00).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  category,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductList() {
    return BlocConsumer<ProductCubit, ProductState>(
      listenWhen: (prev, curr) => prev.selectedProduct != curr.selectedProduct,
      listener: (context, state) {
        if (state.selectedProduct != null) {
          final cubit = context.read<ProductCubit>();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => ProductDetailSheet(product: state.selectedProduct!),
          ).whenComplete(() {
            cubit.clearSelectedProduct();
          });
        }
      },
      builder: (context, state) {
        if (state.status == ProductStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF7D00)),
          );
        }

        if (state.status == ProductStatus.failure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  state.error ?? 'Gagal memuat produk',
                  style: GoogleFonts.outfit(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<ProductCubit>().loadProducts(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7D00),
                  ),
                  child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        if (state.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Tidak ada produk',
                  style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await context.read<ProductCubit>().loadByCategory(
                  _selectedCategory == 'Semua' ? '' : _selectedCategory,
                );
          },
          color: const Color(0xFFFF7D00),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.products.length,
            itemBuilder: (context, index) {
              final product = state.products[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ProductCard(
                  product: product,
                  onTap: () => context.read<ProductCubit>().selectProduct(product),
                  onBuy: () {
                    // TODO: Implement purchase flow
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Membeli ${product.productName}...'),
                        backgroundColor: const Color(0xFFFF7D00),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.local_offer,
                label: 'Promo',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.shopping_cart,
                label: 'Product',
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.person,
                label: 'User',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = index == _currentNavIndex;
    return GestureDetector(
      onTap: () => _onNavTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 28,
            color: isSelected ? const Color(0xFFFF7D00) : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? const Color(0xFFFF7D00) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
