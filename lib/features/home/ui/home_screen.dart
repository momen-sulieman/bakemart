import 'dart:ui' as ui;

import 'package:bakemart/core/shared/cubits/location_cubit/location_cubit.dart';
import 'package:bakemart/core/shared/cubits/location_cubit/location_state.dart';
import 'package:bakemart/core/theming/theming_colors.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/logic/bakery_tab_cubit/bakery_tab_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/ui/bakery_tab_screen.dart';
import 'package:bakemart/features/home/tabs/home_tab/ui/home_tab_screen.dart';
import 'package:bakemart/features/home/tabs/work_tab/ui/work_tab_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:floating_modern_navbar/floating_modern_navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../core/utils/extensions/context_extensions.dart';
import '../logic/home_screen_cubit/home_screen_cubit.dart';
import '../tabs/home_tab/logic/home_data_cubit/home_data_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<FloatingNavBarItem> bottomNavBarItems = [
      FloatingNavBarItem(
        icon: Icons.work_outline,
        label: "work".tr(),
        activeIcon: Icons.work,
      ),
      FloatingNavBarItem(
        icon: Icons.home_outlined,
        label: "home".tr(),
        activeIcon: Icons.home,
      ),
      FloatingNavBarItem(
        icon: Icons.factory_outlined,
        label: "myBakery".tr(),
        activeIcon: Icons.factory,
      ),
    ];
    final List<Widget> tabs = [
      WorkTabScreen(),
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => DependencyInjection.getIt<HomeDataCubit>(),
          ),
        ],
        child: HomeTabScreen(),
      ),
      BlocProvider(
        create: (context) => DependencyInjection.getIt<BakeryTabCubit>(),
        child: BakeryTabScreen(),
      ),
    ];
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, locationState) {
        if (locationState is LocationUpdated) {
          return BlocBuilder<HomeScreenCubit, int>(
            builder: (context, selctedIndex) {
              return Scaffold(
                extendBody: true,
                bottomNavigationBar: Directionality(
                  textDirection: ui.TextDirection.ltr,
                  child: FloatingModernNavBar(
                    height: 80,
                    iconSize: 30,
                    unselectedLabelStyle: TextStyle(fontSize: 15),
                    selectedLabelStyle: TextStyle(fontSize: 15),
                    selectedIconScale: 1,
                    itemBorderRadius: 50,
                    borderRadius: 50,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    variant: FloatingNavBarVariant.modern,
                    backgroundColor: context.isDark
                        ? ThemingColors.black.withAlpha((0.5 * 255).toInt())
                        : ThemingColors.white.withAlpha((0.5 * 255).toInt()),
                    borderWidth: 2,
                    borderColor: context.isDark
                        ? ThemingColors.white.withAlpha((0.1 * 255).toInt())
                        : ThemingColors.black.withAlpha((0.15 * 255).toInt()),
                    selectedItemColor: Colors.transparent,
                    selectedLabelColor: ThemingColors.primaryColor,
                    splashColor: Colors.transparent,
                    currentIndex: selctedIndex,
                    onTap: (index) =>
                        context.read<HomeScreenCubit>().changeTab(index),
                    items: bottomNavBarItems,
                  ),
                ),
                body: Directionality(
                  textDirection: ui.TextDirection.ltr,
                  child: IndexedStack(index: selctedIndex, children: tabs),
                ),
              );
            },
          );
        }
        return SizedBox();
      },
    );
  }
}
