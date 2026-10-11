import 'package:bakemart/core/shared/cubits/obscurity_cubit/obscurity_cubit.dart';
import 'package:bakemart/core/shared/widgets/cart/data/cart_repo.dart';
import 'package:bakemart/core/shared/widgets/cart/logic/cart_cubit/cart_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/data/bakery_tab_repo.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/logic/bakery_tab_cubit/bakery_tab_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_settings/logic/settings_update_cubit/settings_update_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_status/logic/status_meals_filter_cubit/status_meals_filter_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_storage/logic/unit_cubit/unit_cubit.dart';
import 'package:bakemart/features/home/tabs/home_tab/logic/active_orders_cubit/active_orders_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/delivery_sales_cubit/delivery_sales_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/expenses_cubit/expenses_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/expenses_filter_cubit/expenses_filter_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/production_cubit/production_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/shifts_cubit/shifts_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/shifts_filter_cubit/shifts_filter_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/window_sales_cubit/window_sales_cubit.dart';
import 'package:get_it/get_it.dart';
import '../../features/authentication/forgot_password/data/forgot_password_repo.dart';
import '../../features/authentication/forgot_password/logic/forgot_password_cubit/forgot_password_cubit.dart';
import '../../features/authentication/sign_in/data/sign__in_repo.dart';
import '../../features/authentication/sign_in/logic/sgin_in_cubit/sign_in_cubit.dart';
import '../../features/authentication/sign_up/data/sign_up_repo.dart';
import '../../features/bakery_details/logic/quantity_counter_cubit/quantity_counter_cubit.dart';
import '../../features/home/logic/home_screen_cubit/home_screen_cubit.dart';
import '../../features/home/tabs/bakery_tab/tabs/bakery_settings/data/settings_repo.dart';
import '../../features/home/tabs/bakery_tab/tabs/bakery_settings/logic/settings_cubit/settings_cubit.dart';
import '../../features/home/tabs/bakery_tab/tabs/bakery_status/logic/status_finance_filter_cubit/status_finance_filter_cubit.dart';
import '../../features/home/tabs/bakery_tab/tabs/bakery_status/logic/status_sales_filter_cubit/status_sales_filter_cubit.dart';
import '../../features/home/tabs/bakery_tab/tabs/bakery_status/logic/status_shifts_filter_cubit/status_shifts_filter_cubit.dart';
import '../../features/home/tabs/bakery_tab/tabs/bakery_storage/data/storage_repo.dart';
import '../../features/home/tabs/bakery_tab/tabs/bakery_storage/logic/storage_cubit/storage_cubit.dart';
import '../../features/home/tabs/home_tab/data/home_repo.dart';
import '../../features/home/tabs/home_tab/logic/home_data_cubit/home_data_cubit.dart';
import '../../features/home/tabs/work_tab/tabs/delivery_tab/data/delivery_repo.dart';
import '../../features/home/tabs/work_tab/tabs/delivery_tab/logic/delivery_cubit/delivery_cubit.dart';
import '../../features/home/tabs/work_tab/tabs/worker_tab/data/worker_repo.dart';
import '../../features/home/tabs/work_tab/tabs/worker_tab/logic/history_filter_cubit/history_filter_cubit.dart';
import '../../features/home/tabs/work_tab/tabs/worker_tab/logic/worker_cubit/worker_cubit.dart';
import '../../features/onboarding/logic/onboarding_cubit/onboarding_cubit.dart';
import '../../features/splash/data/splash_repo.dart';
import '../../features/splash/logic/splash_cubit/splash_cubit.dart';
import '../shared/cubits/location_cubit/location_cubit.dart';
import '../shared/widgets/supabase_image/logic/supabase_image_cubit/supabase_image_cubit.dart';

class DependencyInjection {
  DependencyInjection._();

  static final GetIt getIt = GetIt.instance;

  static Future<void> init() async {
    //repos
    getIt.registerLazySingleton<ForgotPasswordRepo>(() => ForgotPasswordRepo());
    getIt.registerLazySingleton<SignUpRepo>(() => SignUpRepo());
    getIt.registerLazySingleton<SignInRepo>(() => SignInRepo());
    getIt.registerLazySingleton<CartRepo>(() => CartRepo());
    getIt.registerLazySingleton<SettingsRepo>(() => SettingsRepo());
    getIt.registerLazySingleton<BakeryTabRepo>(() => BakeryTabRepo());
    getIt.registerLazySingleton<StorageRepo>(() => StorageRepo());
    getIt.registerLazySingleton<HomeRepo>(() => HomeRepo());
    getIt.registerLazySingleton<DeliveryRepo>(() => DeliveryRepo());
    getIt.registerLazySingleton<WorkerRepo>(() => WorkerRepo());
    getIt.registerLazySingleton<SplashRepo>(() => SplashRepo());

    //cubits
    getIt.registerFactory<OnboardingCubit>(() => OnboardingCubit());
    getIt.registerFactoryParam<SupabaseImageCubit, String, String?>(
      (filePath, fileName) => SupabaseImageCubit(filePath, fileName),
    );
    getIt.registerFactory(() => ObscurityCubit());
    getIt.registerFactory(() => UnitCubit());
    getIt.registerFactory(() => QuantityCounterCubit());
    getIt.registerFactory(() => HomeScreenCubit());
    getIt.registerLazySingleton(() => LocationCubit());
    getIt.registerLazySingleton(
          () => CartCubit(
        getIt<CartRepo>(),
        getIt<LocationCubit>(),
      ),
    );
    getIt.registerFactory(
      () => ForgotPasswordCubit(getIt<ForgotPasswordRepo>()),
    );
    getIt.registerFactory(() => SignInCubit(getIt<SignInRepo>()));
    getIt.registerFactory(
      () => SettingsCubit(getIt<SettingsRepo>(), getIt<BakeryTabCubit>()),
    );
    getIt.registerFactory(() => SettingsUpdateCubit(getIt<SettingsCubit>()));
    getIt.registerFactory(
      () => StorageCubit(getIt<StorageRepo>(), getIt<BakeryTabCubit>()),
    );
    getIt.registerFactory(
      () => HomeDataCubit(
        getIt<HomeRepo>(),
        getIt<ActiveOrdersCubit>(),
        getIt<CartCubit>(),
      ),
    );
    getIt.registerLazySingleton(() => ActiveOrdersCubit(getIt<HomeRepo>()));
    getIt.registerLazySingleton(
      () => BakeryTabCubit(getIt<BakeryTabRepo>(), getIt<LocationCubit>()),
    );
    getIt.registerFactory(
      () => StatusFinanceFilterCubit(
        getIt<BakeryTabRepo>(),
        getIt<BakeryTabCubit>(),
      ),
    );
    getIt.registerFactory(
      () => StatusShiftsFilterCubit(
        getIt<BakeryTabRepo>(),
        getIt<BakeryTabCubit>(),
      ),
    );
    getIt.registerFactory(
      () => StatusMealsFilterCubit(
        getIt<BakeryTabRepo>(),
        getIt<BakeryTabCubit>(),
      ),
    );
    getIt.registerFactory(
      () => StatusSalesFilterCubit(
        getIt<BakeryTabRepo>(),
        getIt<BakeryTabCubit>(),
      ),
    );
    getIt.registerFactory(
      () => WindowSalesCubit(getIt<WorkerRepo>(), getIt<WorkerCubit>()),
    );
    getIt.registerFactory(
      () => ProductionCubit(getIt<WorkerRepo>(), getIt<WorkerCubit>()),
    );
    getIt.registerFactory(
      () => DeliverySalesCubit(getIt<WorkerRepo>()),
    );
    getIt.registerLazySingleton(
      () => ExpensesCubit(getIt<WorkerRepo>(), getIt<WorkerCubit>()),
    );
    getIt.registerFactory(
      () => ExpensesFilterCubit(getIt<WorkerRepo>(), getIt<WorkerCubit>()),
    );
    getIt.registerFactory(
      () => ShiftsCubit(getIt<WorkerRepo>(), getIt<WorkerCubit>()),
    );
    getIt.registerFactory(
      () => ShiftsFilterCubit(getIt<WorkerRepo>(), getIt<WorkerCubit>()),
    );
    getIt.registerFactory(
          () => HistoryFilterCubit(getIt<WorkerRepo>()),
    );
    getIt.registerLazySingleton(
      () => DeliveryCubit(getIt<DeliveryRepo>(), getIt<LocationCubit>()),
    );
    getIt.registerLazySingleton(() => WorkerCubit(getIt<WorkerRepo>()));
    getIt.registerFactory(() => SplashCubit(getIt<SplashRepo>()));
  }
}
