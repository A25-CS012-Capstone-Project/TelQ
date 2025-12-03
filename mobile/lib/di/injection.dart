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

final getIt = GetIt.instance;

void configureDependencies() {
  // Core clients
  getIt.registerLazySingleton<http.Client>(() => http.Client());

  // API client (base URL configured in app_config.dart)
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(client: getIt(), baseUrl: apiBaseUrl),
  );

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
}
