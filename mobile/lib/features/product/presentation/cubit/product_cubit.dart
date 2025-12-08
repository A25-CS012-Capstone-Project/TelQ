import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:telQ_mobile/core/error/failure.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_all_products.dart';
import '../../domain/usecases/get_products_by_category.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final GetAllProducts getAllProducts;
  final GetProductsByCategory getProductsByCategory;

  ProductCubit({
    required this.getAllProducts,
    required this.getProductsByCategory,
  }) : super(const ProductState());

  Future<void> loadProducts() async {
    emit(state.copyWith(status: ProductStatus.loading, error: null));
    try {
      final products = await getAllProducts();
      emit(state.copyWith(status: ProductStatus.success, products: products));
    } catch (e) {
      final message = e is Failure ? e.message : e.toString();
      emit(state.copyWith(status: ProductStatus.failure, error: message));
    }
  }

  Future<void> loadByCategory(String category) async {
    emit(state.copyWith(
      status: ProductStatus.loading,
      selectedCategory: category,
      error: null,
    ));
    try {
      final products = category.isEmpty
          ? await getAllProducts()
          : await getProductsByCategory(category);
      emit(state.copyWith(status: ProductStatus.success, products: products));
    } catch (e) {
      final message = e is Failure ? e.message : e.toString();
      emit(state.copyWith(status: ProductStatus.failure, error: message));
    }
  }

  void selectProduct(Product? product) {
    emit(state.copyWith(selectedProduct: product));
  }

  void clearSelectedProduct() {
    emit(state.copyWith(selectedProduct: null, clearSelectedProduct: true));
  }
}
