import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/login_cubit.dart';
import '../../features/inventory/data/datasources/inventory_remote_datasource.dart';
import '../../features/inventory/data/repositories/inventory_repository_impl.dart';
import '../../features/inventory/domain/repositories/inventory_repository.dart';
import '../../features/inventory/presentation/cubit/inventory_cubit.dart';
import '../../features/inventory/presentation/cubit/product_form_cubit.dart';
import '../../features/inventory/presentation/cubit/stock_movement_cubit.dart';
import '../../features/services/data/datasources/services_remote_datasource.dart';
import '../../features/services/data/repositories/services_repository_impl.dart';
import '../../features/services/domain/repositories/services_repository.dart';
import '../../features/services/presentation/cubit/service_form_cubit.dart';
import '../../features/services/presentation/cubit/services_cubit.dart';
import '../../features/work_orders/data/datasources/customers_remote_datasource.dart';
import '../../features/work_orders/data/datasources/work_orders_remote_datasource.dart';
import '../../features/work_orders/data/repositories/customers_repository_impl.dart';
import '../../features/work_orders/data/repositories/work_orders_repository_impl.dart';
import '../../features/work_orders/domain/repositories/customers_repository.dart';
import '../../features/work_orders/domain/repositories/work_orders_repository.dart';
import '../../features/work_orders/presentation/cubit/create_order_cubit.dart';
import '../../features/work_orders/presentation/cubit/order_detail_cubit.dart';
import '../../features/work_orders/presentation/cubit/work_orders_cubit.dart';
import '../network/dio_client.dart';
import '../storage/session_storage.dart';
import '../theme/theme_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // --- Core ---
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  getIt.registerLazySingleton<SessionStorage>(() => SessionStorage(getIt()));
  getIt.registerLazySingleton<Dio>(
    () => DioClient.create(
      storage: getIt(),
      // Looked up lazily to avoid a circular dependency Dio <-> AuthCubit.
      onSessionExpired: () => getIt<AuthCubit>().sessionExpired(),
    ),
  );
  getIt.registerLazySingleton<ThemeCubit>(() => ThemeCubit(getIt()));

  // --- Feature: auth ---
  getIt.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasource(getIt()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<AuthCubit>(() => AuthCubit(getIt()));
  getIt.registerFactory<LoginCubit>(() => LoginCubit(getIt(), getIt()));

  // --- Feature: services ---
  getIt.registerLazySingleton<ServicesRemoteDatasource>(
    () => ServicesRemoteDatasource(getIt()),
  );
  getIt.registerLazySingleton<ServicesRepository>(
    () => ServicesRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerFactory<ServicesCubit>(() => ServicesCubit(getIt()));
  getIt.registerFactory<ServiceFormCubit>(() => ServiceFormCubit(getIt()));

  // --- Feature: inventory ---
  getIt.registerLazySingleton<InventoryRemoteDatasource>(
    () => InventoryRemoteDatasource(getIt()),
  );
  getIt.registerLazySingleton<InventoryRepository>(
    () => InventoryRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerFactory<InventoryCubit>(() => InventoryCubit(getIt()));
  getIt.registerFactory<ProductFormCubit>(() => ProductFormCubit(getIt()));
  getIt.registerFactory<StockMovementCubit>(() => StockMovementCubit(getIt()));

  // --- Feature: work orders ---
  getIt.registerLazySingleton<WorkOrdersRemoteDatasource>(
    () => WorkOrdersRemoteDatasource(getIt()),
  );
  getIt.registerLazySingleton<CustomersRemoteDatasource>(
    () => CustomersRemoteDatasource(getIt()),
  );
  getIt.registerLazySingleton<WorkOrdersRepository>(
    () => WorkOrdersRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<CustomersRepository>(
    () => CustomersRepositoryImpl(getIt()),
  );
  getIt.registerFactory<WorkOrdersCubit>(() => WorkOrdersCubit(getIt()));
  getIt.registerFactory<CreateOrderCubit>(
    () => CreateOrderCubit(getIt(), getIt()),
  );
  // param1 = order code (one cubit per opened order).
  getIt.registerFactoryParam<OrderDetailCubit, String, void>(
    (orderCode, _) => OrderDetailCubit(
      getIt(),
      getIt(),
      getIt(),
      orderCode: orderCode,
    ),
  );
}
