import 'package:bakemart/core/dependency_injection/dependency_injection.dart';
import 'package:bakemart/core/routing/app_routes.dart';
import 'package:bakemart/core/theming/theming_colors.dart';
import 'package:bakemart/core/utils/enums/bingo_keys.dart';
import 'package:bakemart/features/onboarding/data/onboarding_pages.dart';
import 'package:bakemart/features/onboarding/logic/onboarding_cubit/onboarding_cubit.dart';
import 'package:bingo/bingo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/shared/widgets/glass_card/glass_card.dart';
import '../../../core/utils/constants/constant_images.dart';
import '../../../core/utils/extensions/context_extensions.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DependencyInjection.getIt<OnboardingCubit>(),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatelessWidget {
  const _OnboardingView();

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final cubit = context.read<OnboardingCubit>();

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
            opacity: context.isDark ? 0.45 : 0.35,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: .center,
          children: [
            Padding(
              padding: .only(top: 80, bottom: 20),
              child: Text(
                "Welcome",
                style: GoogleFonts.audiowide(fontSize: 25, color: ThemingColors.primaryColor),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: cubit.pageController,
                itemCount: onboardingPages.length,
                onPageChanged: cubit.pageChanged,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: .circular(15),
                      image: DecorationImage(
                        image: AssetImage(
                          context.isDark
                              ? onboardingPages[index].darkImage
                              : onboardingPages[index].lightImage,
                        ),
                        fit: .fill,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: .only(top: 30, bottom: 50),
              child: SmoothPageIndicator(
                controller: cubit.pageController,
                count: onboardingPages.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: ThemingColors.primaryColor,
                  dotColor: ThemingColors.primaryColor.withAlpha(
                    (0.3 * 255).toInt(),
                  ),
                  dotHeight: 4,
                  dotWidth: 8,
                ),
              ),
            ),
            BlocBuilder<OnboardingCubit, int>(
              builder: (context, currentPage) {
                return Container(
                  height: 130,
                  width: .infinity,
                  padding: .symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      Text(
                        onboardingPages[currentPage].title,
                        style: GoogleFonts.audiowide(
                          fontSize: 20,
                          color: ThemingColors.primaryColor,
                        ),
                      ),
                      Text(
                        onboardingPages[currentPage].description,
                        style: TextStyle(),
                        textAlign: .center,
                      ),
                    ],
                  ),
                );
              },
            ),
            Padding(
              padding: .only(bottom: 70),
              child: SizedBox(
                width: screenWidth * 0.65,
                child: BlocBuilder<OnboardingCubit, int>(
                  builder: (context, currentPage) {
                    final bool isLastPage =
                        currentPage == (onboardingPages.length - 1);
                    return Row(
                      children: [
                        if (currentPage >= 1)
                          InkWell(
                            splashColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: cubit.previousPage,
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
                            onTap: () async {
                              if (isLastPage) {
                                Bingo.mark(BingoKeys.seenOnboarding, true);
                                if (context.mounted) {
                                  Navigator.of(
                                    context,
                                  ).pushReplacementNamed(AppRoutes.signIn.route);
                                }
                              } else {
                                cubit.nextPage();
                              }
                            },
                            child: GlassCard(
                              margin: EdgeInsets.zero,
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              dark: !isLastPage,
                              green: isLastPage,
                              child: Text(
                                isLastPage ? "Get started" : "Next",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
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
          ],
        ),
      ),
    );
  }
}