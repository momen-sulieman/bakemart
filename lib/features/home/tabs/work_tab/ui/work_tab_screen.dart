import 'package:bakemart/core/theming/theming_colors.dart';
import 'package:bakemart/core/utils/extensions/context_extensions.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/delivery_sales_cubit/delivery_sales_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/expenses_cubit/expenses_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/expenses_filter_cubit/expenses_filter_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/production_cubit/production_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/shifts_cubit/shifts_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/shifts_filter_cubit/shifts_filter_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/window_sales_cubit/window_sales_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/worker_cubit/worker_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/ui/worker_tab_screen.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/dependency_injection/dependency_injection.dart';
import '../tabs/delivery_tab/logic/delivery_cubit/delivery_cubit.dart';
import '../tabs/delivery_tab/ui/delivery_tab_screen.dart';

class WorkTabScreen extends StatelessWidget {
  const WorkTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: ButtonsTabBar(
            duration: 0,
            splashColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            unselectedBackgroundColor: context.isDark
                ? ThemingColors.lightGrey.withAlpha((0.15 * 255).toInt())
                : ThemingColors.darkGrey.withAlpha((0.09 * 255).toInt()),
            contentPadding: .symmetric(horizontal: 25),
            radius: 50,
            borderWidth: 2,
            borderColor: ThemingColors.primaryColor,
            unselectedBorderColor: Colors.transparent,
            labelStyle: TextStyle(
              color: ThemingColors.primaryColor,
              fontWeight: .bold,
            ),
            unselectedLabelStyle: TextStyle(
              color: context.isDark
                  ? ThemingColors.white.withAlpha((0.4 * 255).toInt())
                  : ThemingColors.darkGrey.withAlpha((0.5 * 255).toInt()),
            ),
            tabs: [
              Tab(
                icon: Padding(
                  padding: .only(right: 5),
                  child: Icon(Icons.delivery_dining_outlined, size: 17),
                ),
                text: "deliveryTab".tr(),
              ),
              Tab(
                icon: Padding(
                  padding: .only(right: 5),
                  child: Icon(Icons.factory_outlined, size: 17),
                ),
                text: "bakeryTab".tr(),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            BlocProvider.value(
              value: DependencyInjection.getIt<DeliveryCubit>(),
              child: DeliveryTabScreen(),
            ),
            MultiBlocProvider(
              providers: [
                BlocProvider.value(
                  value: DependencyInjection.getIt<WorkerCubit>(),
                ),
                BlocProvider(
                  create: (context) =>
                      DependencyInjection.getIt<WindowSalesCubit>(),
                ),
                BlocProvider(
                  create: (context) =>
                      DependencyInjection.getIt<DeliverySalesCubit>(),
                ),
                BlocProvider(
                  create: (context) =>
                      DependencyInjection.getIt<ExpensesCubit>(),
                ),
                BlocProvider(
                  create: (context) =>
                      DependencyInjection.getIt<ExpensesFilterCubit>(),
                ),
                BlocProvider(
                  create: (context) =>
                      DependencyInjection.getIt<ProductionCubit>(),
                ),
                BlocProvider(
                  create: (context) => DependencyInjection.getIt<ShiftsCubit>(),
                ),
                BlocProvider(
                  create: (context) =>
                      DependencyInjection.getIt<ShiftsFilterCubit>(),
                ),
              ],
              child: WorkerTabScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
