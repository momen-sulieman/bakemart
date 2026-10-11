import 'package:bakemart/features/home/tabs/bakery_tab/logic/bakery_tab_cubit/bakery_tab_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_settings/ui/settings_tab_screen.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_status/ui/status_tab_screen.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_storage/ui/storage_tab_screen.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/ui/widgets/creation_onboarding_screen.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../../../core/shared/widgets/faded_screen/faded_screen.dart';
import '../../../../../core/theming/theming_colors.dart';
import '../../../../../core/utils/constants/constant_images.dart';
import '../../../../../core/utils/extensions/context_extensions.dart';

class BakeryTabScreen extends StatelessWidget {
  const BakeryTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    return BlocBuilder<BakeryTabCubit, BakeryTabState>(
      builder: (context, bakeryState) {
        final cubit = context.read<BakeryTabCubit>();
        if (bakeryState is HasNoBakery) {
          return Scaffold(
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
                  opacity: context.isDark ? 0.4 : 0.3,
                ),
              ),
              clipBehavior: Clip.hardEdge,
              child: CreationOnboardingScreen(),
            ),
          );
        } else if (bakeryState is BakeryTabLoading) {
          return Scaffold(
            extendBody: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
                side: BorderSide(
                  color: ThemingColors.primaryColor.withAlpha(
                    (0.15 * 255).toInt(),
                  ),
                  width: 4,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(76),
                child: SizedBox(),
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
              child: Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: ThemingColors.primaryColor,
                  size: 25,
                ),
              ),
            ),
          );
        } else if (bakeryState is HasBakery) {
          if (!cubit.bakery.verified) {
            return Scaffold(
              extendBody: true,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                  side: BorderSide(
                    color: ThemingColors.primaryColor.withAlpha(
                      (0.15 * 255).toInt(),
                    ),
                    width: 4,
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(76),
                  child: SizedBox(),
                ),
              ),
              body: RefreshIndicator(
                edgeOffset: 0,
                strokeWidth: 2,
                displacement: 0,
                elevation: 0,
                color: ThemingColors.primaryColor,
                backgroundColor: Colors.transparent,
                onRefresh: () async {
                  cubit.check();
                },
                child: Container(
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
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      width: screenWidth,
                      height: screenHeight-350,
                      child: Column(
                        mainAxisAlignment: .center,
                        children: [
                          FadedScreen(
                            size: 70,
                            icon: Icons.hourglass_top,
                            text: "pending".tr(),
                            colored: true,
                            iconColor: Colors.blueGrey,
                            textLightFade: 0.8,
                            textDarkFade: 0.5,
                          ),
                          Text(
                            "verificationPendingMessage".tr(),
                            style: TextStyle(fontSize:context.locale.languageCode=="ar"?14: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          return DefaultTabController(
            initialIndex: 1,
            length: 3,
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
                    Tab(text: "settingsTab".tr()),
                    Tab(text: "recordsTab".tr()),
                    Tab(text: "storageTab".tr()),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  SettingsTabScreen(),
                  StatusTabScreen(),
                  StorageTabScreen(),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          extendBody: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
              side: BorderSide(
                color: ThemingColors.primaryColor.withAlpha(
                  (0.15 * 255).toInt(),
                ),
                width: 4,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(76),
              child: SizedBox(),
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
            child: Center(
              child: InkWell(
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  cubit.setLocation();
                  cubit.check();
                },
                child: Column(
                  mainAxisAlignment: .center,
                  children: [
                    FadedScreen(
                      size: 80,
                      icon: Icons.cell_tower,
                      text: "noInternet".tr(),
                    ),
                    Row(
                      mainAxisAlignment: .center,
                      children: [
                        Padding(
                          padding: .only(right: 5),
                          child: Icon(
                            Icons.refresh,
                            size: 16,
                            color: ThemingColors.primaryColor,
                          ),
                        ),
                        Text(
                          "tapToRetry".tr(),
                          style: TextStyle(fontSize: 12, fontWeight: .bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
