import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/register_user.dart';
import '../features/auth/domain/usecases/login_user.dart';
import '../features/auth/presentation/cubit/login_cubit.dart';
import '../features/auth/presentation/cubit/register_cubit.dart';
import '../features/onboarding/presentation/cubit/onboarding_cubit.dart';

// Product feature imports
import '../features/product/data/datasources/product_remote_data_source.dart';
import '../features/product/data/repositories/product_repository_impl.dart';
import '../features/product/domain/repositories/product_repository.dart';
import '../features/product/domain/usecases/get_all_products.dart';
import '../features/product/domain/usecases/get_products_by_category.dart';
import '../features/product/presentation/cubit/product_cubit.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  // Core clients
  getIt.registerLazySingleton<http.Client>(() => http.Client());

  // API client (base URL configured in app_config.dart)
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(client: getIt(), baseUrl: apiBaseUrl),
  );

  // ==================== Auth Feature ====================
  // Data sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(api: getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt()));

  // Use cases
  getIt.registerLazySingleton<LoginUser>(() => LoginUser(getIt()));
  getIt.registerLazySingleton<RegisterUser>(() => RegisterUser(getIt()));

  // Presentation
  getIt.registerFactory<LoginCubit>(() => LoginCubit(getIt()));
  getIt.registerFactory<RegisterCubit>(() => RegisterCubit(getIt()));
  getIt.registerFactory<OnboardingCubit>(() => OnboardingCubit());

  // ==================== Product Feature ====================
  // Data sources
  getIt.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(api: getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(getIt()),
  );

  // Use cases
  getIt.registerLazySingleton<GetAllProducts>(() => GetAllProducts(getIt()));
  getIt.registerLazySingleton<GetProductsByCategory>(
    () => GetProductsByCategory(getIt()),
  );

  // Presentation
  getIt.registerFactory<ProductCubit>(
    () => ProductCubit(
      getAllProducts: getIt(),
      getProductsByCategory: getIt(),
    ),
  );
}
