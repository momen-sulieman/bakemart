import 'package:bakemart/features/splash/logic/splash_cubit/splash_cubit.dart';
import 'package:bakemart/core/theming/theming_colors.dart';
import 'package:bakemart/core/utils/constants/constant_images.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../core/shared/models/my_clipper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/extensions/context_extensions.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: BlocListener<SplashCubit, SplashState>(
        listener: (context, splashState) {
          if (splashState is SplashSuccess) {
            Navigator.of(context).pushReplacementNamed(splashState.route);
          } else if (splashState is SplashFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(splashState.error)));
          }
        },
        child: Center(
          child: Column(
            crossAxisAlignment: .center,
            children: [
              ClipPath(
                clipper: MyClipper(),
                child: Container(
                  height: screenHeight * 0.6,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        context.isDark
                            ? ConstantImages.darkBackground
                            : ConstantImages.lightBackground,
                      ),
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              ),
              Container(
                width: 80,
                height: 80,
                margin: .only(top: 20),
                decoration: BoxDecoration(
                  borderRadius: .circular(20),
                  image: DecorationImage(
                    image: AssetImage(
                      context.isDark
                          ? ConstantImages.splashDark
                          : ConstantImages.splashLight,
                    ),
                    fit: .cover,
                  ),
                ),
              ),
              SizedBox(height: 15),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Bake",
                      style: TextStyle(
                        fontSize: 18,
                        color: ThemingColors.primaryColor,
                        fontWeight: .bold,
                      ),
                    ),
                    TextSpan(
                      text: "mart",
                      style: TextStyle(fontSize: 18,color: Colors.blue),
                    ),
                  ],
                ),
              ),
              Spacer(),
              LoadingAnimationWidget.staggeredDotsWave(
                color: ThemingColors.primaryColor,
                size: 35,
              ),
              SizedBox(height: 70),
            ],
          ),
        ),
      ),
    );
  }
}
