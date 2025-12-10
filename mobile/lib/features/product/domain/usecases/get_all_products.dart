import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetAllProducts {
  final ProductRepository repository;
  GetAllProducts(this.repository);

  Future<List<Product>> call() {
    return repository.getAllProducts();
  }
}
