import 'dart:ui' as ui;

import 'package:bakemart/core/shared/widgets/glass_card/glass_card.dart';
import 'package:bakemart/core/theming/theming_colors.dart';
import 'package:bakemart/core/utils/extensions/context_extensions.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/ui/widgets/creation_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../../../core/shared/cubits/location_cubit/location_cubit.dart';
import '../../data/creation_onboarding_pages.dart';
import '../../logic/bakery_tab_cubit/bakery_tab_cubit.dart';

class CreationOnboardingScreen extends StatelessWidget {
  const CreationOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: DependencyInjection.getIt<BakeryTabCubit>(),
      child: const _CreationOnboardingView(),
    );
  }
}

class _CreationOnboardingView extends StatelessWidget {
  const _CreationOnboardingView();

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final cubit = context.read<BakeryTabCubit>();
    return Center(
      child: Column(
        crossAxisAlignment: .center,
        children: [
          Expanded(
            child: Directionality(
              textDirection: context.locale.languageCode == 'ar'
                  ? ui.TextDirection.rtl
                  : ui.TextDirection.ltr,
              child: PageView.builder(
                controller: cubit.pageController,
                itemCount: creationOnboardingPages.length,
                onPageChanged: cubit.onboardingPageChanged,
                itemBuilder: (context, index) {
                  return Container(
                    margin: .only(top: 60),
                    decoration: BoxDecoration(
                      borderRadius: .circular(15),
                      image: DecorationImage(
                        image: AssetImage(
                          context.isDark
                              ? creationOnboardingPages[index].darkImage
                              : creationOnboardingPages[index].lightImage,
                        ),
                        fit: .fill,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: .only(top: 30, bottom: 50),
            child: Directionality(
              textDirection: context.locale.languageCode == 'ar'
                  ? ui.TextDirection.rtl
                  : ui.TextDirection.ltr,
              child: SmoothPageIndicator(
                controller: cubit.pageController,
                count: creationOnboardingPages.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: ThemingColors.primaryColor,
                  dotColor: ThemingColors.primaryColor.withAlpha(
                    (0.25 * 255).toInt(),
                  ),
                  dotHeight: 4,
                  dotWidth: 8,
                ),
              ),
            ),
          ),
          BlocBuilder<BakeryTabCubit, BakeryTabState>(
            builder: (context, state) {
              final currentPage = cubit.currentOnboardingPage;
              return Container(
                height: 100,
                width: .infinity,
                padding: .symmetric(horizontal: 15),
                child: Column(
                  children: [
                    Text(
                      creationOnboardingPages[currentPage].title,
                      style: GoogleFonts.audiowide(
                        fontSize: 20,
                        color: ThemingColors.primaryColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      creationOnboardingPages[currentPage].description,
                      textAlign: .center,
                      textDirection: context.locale.languageCode == "ar"
                          ? .rtl
                          : .ltr,
                      style: TextStyle(
                        fontSize: context.locale.languageCode == "ar" ? 16 : 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: .only(bottom: 140, top: 40),
            child: SizedBox(
              width: screenWidth * 0.65,
              child: Directionality(
                textDirection: context.locale.languageCode == 'ar'
                    ? ui.TextDirection.rtl
                    : ui.TextDirection.ltr,
                child: BlocBuilder<BakeryTabCubit, BakeryTabState>(
                  builder: (context, state) {
                    final currentPage = cubit.currentOnboardingPage;
                    final bool isLastPage =
                        currentPage == (creationOnboardingPages.length - 1);
                    return Row(
                      children: [
                        if (currentPage >= 1)
                          InkWell(
                            splashColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: cubit.previousOnboardingPage,
                            child: GlassCard(
                              margin: .only(right: 10),
                              padding: .symmetric(horizontal: 15, vertical: 5),
                              dark: true,
                              child: Icon(Icons.arrow_back, size: 18),
                            ),
                          ),
                        Expanded(
                          child: InkWell(
                            splashColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              if (isLastPage) {
                                showDialog(
                                  barrierColor: Colors.transparent,
                                  context: context,
                                  builder: (context) {
                                    return MultiBlocProvider(
                                      providers: [
                                        BlocProvider.value(value: cubit),
                                        BlocProvider.value(
                                          value:
                                              DependencyInjection.getIt<
                                                LocationCubit
                                              >(),
                                        ),
                                      ],
                                      child: CreationScreen(),
                                    );
                                  },
                                );
                              } else {
                                cubit.nextOnboardingPage();
                              }
                            },
                            child: GlassCard(
                              margin: .zero,
                              padding: .symmetric(vertical: 5),
                              dark: !isLastPage,
                              green: isLastPage,
                              child: Text(
                                isLastPage
                                    ? "createYourBakery".tr()
                                    : "next".tr(),
                                textAlign: .center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: .bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
