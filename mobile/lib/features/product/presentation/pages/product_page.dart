import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_route.dart';
import '../../../../core/widgets/animated_bottom_nav.dart';
import '../../../../core/helpers/purchase_helper.dart';
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
    if (index == 0) {
      Navigator.pushReplacementNamed(context, AppRoute.promo.path);
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
                    PurchaseHelper.buyProduct(
                      context: context,
                      productId: product.productId,
                      productName: product.productName,
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

/// ini yang dipake di home-shell
class ProductPageContent extends StatefulWidget {
  const ProductPageContent({super.key});

  @override
  State<ProductPageContent> createState() => _ProductPageContentState();
}

class _ProductPageContentState extends State<ProductPageContent> {
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
    // hanya load ini jika cubit belum di load
    final cubit = context.read<ProductCubit>();
    if (cubit.state.status == ProductStatus.idle) {
      cubit.loadProducts();
    }
  }

  void _onCategoryTap(String category) {
    setState(() => _selectedCategory = category);
    context.read<ProductCubit>().loadByCategory(
          category == 'Semua' ? '' : category,
        );
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
                Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Tidak ada produk ditemukan',
                  style: GoogleFonts.outfit(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
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
                  PurchaseHelper.buyProduct(
                    context: context,
                    productId: product.productId,
                    productName: product.productName,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
