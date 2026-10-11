import 'dart:ui' as ui;

import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_status/logic/status_meals_filter_cubit/status_meals_filter_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_status/ui/widgets/financial_status_tile.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_status/ui/widgets/wastes_status_tile.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_status/ui/widgets/sales_status_tile.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_status/ui/widgets/shifts_status_tile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../../../../core/theming/theming_colors.dart';
import '../../../../../../../core/utils/constants/constant_images.dart';
import '../../../../../../../core/utils/extensions/context_extensions.dart';
import '../../../logic/bakery_tab_cubit/bakery_tab_cubit.dart';
import '../logic/status_finance_filter_cubit/status_finance_filter_cubit.dart';
import '../logic/status_sales_filter_cubit/status_sales_filter_cubit.dart';
import '../logic/status_shifts_filter_cubit/status_shifts_filter_cubit.dart';

class StatusTabScreen extends StatelessWidget {
  const StatusTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              DependencyInjection.getIt<StatusFinanceFilterCubit>(),
        ),
        BlocProvider(
          create: (context) =>
              DependencyInjection.getIt<StatusShiftsFilterCubit>(),
        ),
        BlocProvider(
          create: (context) =>
              DependencyInjection.getIt<StatusMealsFilterCubit>(),
        ),
        BlocProvider(
          create: (context) =>
              DependencyInjection.getIt<StatusSalesFilterCubit>(),
        ),
      ],
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: context.isDark
              ? ThemingColors.black.withAlpha((0.7 * 255).toInt())
              : ThemingColors.white.withAlpha((0.8 * 255).toInt()),
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(20),
            child: Container(
              height: 70,
              width: .infinity,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: ThemingColors.primaryColor.withAlpha(
                      (0.15 * 255).toInt(),
                    ),
                    width: 5,
                  ),
                ),
                borderRadius: .only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
            ),
          ),
        ),
        body: Container(
          height: screenHeight + 100,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                context.isDark
                    ? ConstantImages.darkBackground
                    : ConstantImages.lightBackground,
              ),
              fit: BoxFit.cover,
              opacity: context.isDark ? 0.35 : 0.25,
            ),
          ),
          clipBehavior: Clip.hardEdge,
          child: RefreshIndicator(
            edgeOffset: 190,
            strokeWidth: 2,
            displacement: 0,
            elevation: 0,
            color: ThemingColors.primaryColor,
            backgroundColor: Colors.transparent,
            onRefresh: () async {
              await context.read<BakeryTabCubit>().loadAll();
            },
            child: SingleChildScrollView(
              padding: .only(bottom: 120,top: 190),
              child: Directionality(
                textDirection: context.locale.languageCode == 'ar'
                    ? ui.TextDirection.rtl
                    : ui.TextDirection.ltr,
                child: Column(
                  children: [
                    FinancialStatusTile(),
                    SalesStatusTile(),
                    WastesStatusTile(),
                    ShiftsStatusTile(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
