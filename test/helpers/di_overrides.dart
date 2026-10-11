import 'package:bakemart/core/dependency_injection/dependency_injection.dart';
import 'package:bakemart/core/shared/widgets/supabase_image/logic/supabase_image_cubit/supabase_image_cubit.dart';

void ensureImageCubitFactory() {
  final getIt = DependencyInjection.getIt;
  if (!getIt.isRegistered<SupabaseImageCubit>()) {
    getIt.registerFactoryParam<SupabaseImageCubit, String, String?>(
          (bucket, id) => SupabaseImageCubit(bucket, id),
    );
  }
}

Future<void> overrideSingleton<T extends Object>(T instance) async {
  final getIt = DependencyInjection.getIt;
  if (getIt.isRegistered<T>()) {
    await getIt.unregister<T>();
  }
  getIt.registerSingleton<T>(instance);
}

Future<void> removeSingleton<T extends Object>() async {
  final getIt = DependencyInjection.getIt;
  if (getIt.isRegistered<T>()) {
    await getIt.unregister<T>();
  }
}