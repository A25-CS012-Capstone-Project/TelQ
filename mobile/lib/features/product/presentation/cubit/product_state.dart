part of 'product_cubit.dart';

enum ProductStatus { idle, loading, success, failure }

class ProductState extends Equatable {
  final ProductStatus status;
  final List<Product> products;
  final String? selectedCategory;
  final String? error;
  final Product? selectedProduct;

  const ProductState({
    this.status = ProductStatus.idle,
    this.products = const [],
    this.selectedCategory,
    this.error,
    this.selectedProduct,
  });

  ProductState copyWith({
    ProductStatus? status,
    List<Product>? products,
    String? selectedCategory,
    String? error,
    Product? selectedProduct,
    bool clearSelectedProduct = false,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      error: error,
      selectedProduct: clearSelectedProduct ? null : (selectedProduct ?? this.selectedProduct),
    );
  }

  @override
  List<Object?> get props => [status, products, selectedCategory, error, selectedProduct];
}
