import 'package:bakemart/core/routing/app_routes.dart';
import 'package:bakemart/core/shared/cubits/location_cubit/location_cubit.dart';
import 'package:bakemart/core/shared/cubits/obscurity_cubit/obscurity_cubit.dart';
import 'package:bakemart/core/shared/models/home_screen_model.dart';
import 'package:bakemart/features/authentication/forgot_password/logic/forgot_password_cubit/forgot_password_cubit.dart';
import 'package:bakemart/features/authentication/sign_in/logic/sgin_in_cubit/sign_in_cubit.dart';
import 'package:bakemart/features/authentication/sign_in/ui/sign_in_screen.dart';
import 'package:bakemart/features/authentication/sign_up/logic/sign_up_cubit/sign_up_cubit.dart';
import 'package:bakemart/features/authentication/sign_up/ui/sign_up_screen.dart';
import 'package:bakemart/features/bakery_details/ui/bakery_details_screen.dart';
import 'package:bakemart/features/home/ui/home_screen.dart';
import 'package:bakemart/features/onboarding/ui/onboarding_screen.dart';
import 'package:bakemart/features/splash/logic/splash_cubit/splash_cubit.dart';
import 'package:bakemart/features/splash/ui/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/authentication/forgot_password/ui/forgot_password_screen.dart';
import '../../features/authentication/sign_up/data/sign_up_repo.dart';
import '../../features/bakery_details/logic/quantity_counter_cubit/quantity_counter_cubit.dart';
import '../../features/home/logic/home_screen_cubit/home_screen_cubit.dart';
import '../../features/home/tabs/home_tab/logic/active_orders_cubit/active_orders_cubit.dart';
import '../dependency_injection/dependency_injection.dart';
import '../shared/models/order_model.dart';
import '../shared/widgets/cart/logic/cart_cubit/cart_cubit.dart';
import '../shared/widgets/location_picker_map/delivery_route_map_screen.dart';
import '../shared/widgets/supabase_image/logic/supabase_image_cubit/supabase_image_cubit.dart';
import '../utils/enums/buckts.dart';

class AppRouter {
  AppRouter._();

  static Route onGenerateRoute(RouteSettings settings) {
    switch (AppRoutes.fromRoute(settings.name)) {
      case AppRoutes.splash:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => BlocProvider(
            create: (context) => DependencyInjection.getIt<SplashCubit>(),
            child: SplashScreen(),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: Offset.zero,
                    end: const Offset(0, 1),
                  ).animate(
                    CurvedAnimation(
                      parent: secondaryAnimation,
                      curve: Curves.easeInOut,
                    ),
                  ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        );
      case AppRoutes.onBoarding:
        return MaterialPageRoute(builder: (_) => OnboardingScreen());
      case AppRoutes.signIn:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) =>
                    DependencyInjection.getIt<ObscurityCubit>(),
              ),
              BlocProvider(
                create: (context) => DependencyInjection.getIt<SignInCubit>(),
              ),
            ],
            child: SignInScreen(),
          ),
        );
      case AppRoutes.signUp:
        final SupabaseImageCubit signUpImageCubit = SupabaseImageCubit(
          Buckets.usersImages,
          null,
        );
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) =>
                    DependencyInjection.getIt<ObscurityCubit>(),
              ),
              BlocProvider.value(value: signUpImageCubit),
              BlocProvider(
                create: (context) => SignUpCubit(
                  DependencyInjection.getIt<SignUpRepo>(),
                  signUpImageCubit,
                ),
              ),
            ],
            child: SignUpScreen(),
          ),
        );
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) =>
                DependencyInjection.getIt<ForgotPasswordCubit>(),
            child: ForgotPasswordScreen(),
          ),
        );
      case AppRoutes.home:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) =>
                        DependencyInjection.getIt<HomeScreenCubit>(),
                  ),
                  BlocProvider(
                    create: (context) =>
                        DependencyInjection.getIt<SupabaseImageCubit>(),
                  ),
                  BlocProvider.value(
                    value: DependencyInjection.getIt<CartCubit>(),
                  ),
                  BlocProvider.value(
                    value: DependencyInjection.getIt<LocationCubit>(),
                  ),
                  BlocProvider.value(
                    value: DependencyInjection.getIt<ActiveOrdersCubit>(),
                  ),
                ],
                child: HomeScreen(),
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, -1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                  ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        );
      case AppRoutes.bakeryDetails:
        final bakery = settings.arguments as HomeDataBakeriesModel;
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) =>
                    DependencyInjection.getIt<SupabaseImageCubit>(),
              ),
              BlocProvider(
                create: (context) =>
                    DependencyInjection.getIt<QuantityCounterCubit>(),
              ),
              BlocProvider.value(value: DependencyInjection.getIt<CartCubit>()),
              BlocProvider.value(
                value: DependencyInjection.getIt<LocationCubit>(),
              ),
            ],
            child: BakeryDetailsScreen(bakery: bakery),
          ),
        );
      case AppRoutes.deliveryRouteMap:
        final order = settings.arguments as OrderModel;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: DependencyInjection.getIt<LocationCubit>(),
            child: DeliveryRouteMapScreen(order: order),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => DependencyInjection.getIt<SplashCubit>(),
            child: SplashScreen(),
          ),
        );
    }
  }
}
