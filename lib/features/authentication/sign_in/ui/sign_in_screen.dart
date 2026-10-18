import 'package:bakemart/core/routing/app_routes.dart';
import 'package:bakemart/core/shared/cubits/obscurity_cubit/obscurity_cubit.dart';
import 'package:bakemart/core/shared/widgets/text_button/text_button.dart';
import 'package:bakemart/core/shared/widgets/text_form_field/text_form_field.dart';
import 'package:bakemart/core/theming/theming_colors.dart';
import 'package:bakemart/core/utils/constants/constant_images.dart';
import 'package:bakemart/core/utils/form_keys/form_keys.dart';
import 'package:bakemart/features/authentication/sign_in/logic/sgin_in_cubit/sign_in_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../../core/shared/models/my_clipper.dart';
import '../../../../core/shared/widgets/glass_card/glass_card.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocBuilder<SignInCubit, SignInState>(
        builder: (context, signInState) {
          return BlocBuilder<ObscurityCubit, bool>(
            builder: (context, obscurityState) {
              return Form(
                key: signInFormKey,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenHeight = constraints.maxHeight;
                    final screenWidth = constraints.maxWidth;
                    return SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: screenHeight),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              ClipPath(
                                clipper: MyClipper(),
                                child: Container(
                                  height: screenHeight * 0.45,
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
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: .only(left: 25),
                                  child: Text(
                                    "Login",
                                    style: GoogleFonts.molle(
                                      fontSize: 40,
                                      color: ThemingColors.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 30),
                              SizedBox(
                                height: 80,
                                width: screenWidth * 0.7,
                                child: CustomTextFormField(
                                  "Email",
                                  auth: true,
                                  controller: context
                                      .read<SignInCubit>()
                                      .emailController,
                                  prefixIcon: Icons.alternate_email,
                                  validate: true,
                                  emailValidation: true,
                                ),
                              ),
                              SizedBox(
                                height: 80,
                                width: screenWidth * 0.7,
                                child: CustomTextFormField(
                                  "Password",
                                  auth: true,
                                  controller: context
                                      .read<SignInCubit>()
                                      .passwordController,
                                  prefixIcon: Icons.lock,
                                  obscurity: obscurityState,
                                  validate: true,
                                  passwordValidation: true,
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      context.read<ObscurityCubit>().change();
                                    },
                                    icon: Icon(
                                      obscurityState
                                          ? Icons.remove_red_eye
                                          : Icons.remove_red_eye_outlined,
                                      size: 20,
                                      color: context.isDark
                                          ? obscurityState
                                                ? Colors.blueGrey
                                                : Colors.blueGrey.withAlpha(
                                                    (0.5 * 255).toInt(),
                                                  )
                                          : obscurityState
                                          ? Colors.blueGrey
                                          : Colors.blueGrey.withAlpha(
                                              (0.5 * 255).toInt(),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              CustomTextButton(
                                title: "",
                                onTap: () {
                                  Navigator.of(
                                    context,
                                  ).pushNamed(AppRoutes.forgotPassword.route);
                                },
                                subTitle: "Forgot password",
                              ),
                              SizedBox(height: 10),
                              CustomTextButton(
                                title: "Don't have an account yet?  ",
                                onTap: () {
                                  Navigator.of(
                                    context,
                                  ).pushNamed(AppRoutes.signUp.route);
                                },
                                subTitle: "Sign up",
                              ),
                              SizedBox(height: 50,),
                              BlocConsumer<SignInCubit, SignInState>(
                                listener: (context, state) {
                                  if (state is SignInSuccess) {
                                    Navigator.of(context).pushReplacementNamed(
                                      AppRoutes.home.route,
                                    );
                                  } else if (state is SignInFailure) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        elevation: 0,
                                        backgroundColor: Colors.transparent,
                                        duration: Duration(seconds: 3),
                                        content: Center(
                                          child: GlassCard(
                                            margin: .zero,
                                            padding: .symmetric(
                                              vertical: 7,
                                              horizontal: 20,
                                            ),
                                            orange: true,
                                            otherRadius: 30,
                                            child: Text(
                                              state.error,
                                              maxLines: 1,
                                              overflow: .ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: .bold,
                                                color: context.isDark
                                                    ? ThemingColors.white
                                                    : ThemingColors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                builder: (context, state) {
                                  return InkWell(
                                    hoverColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      if (state is! SignInLoading && signInFormKey.currentState!.validate()) {
                                        context.read<SignInCubit>().signIn();
                                      }
                                    },
                                    child: SizedBox(
                                      width: screenWidth * 0.7,
                                      height: 45,
                                      child: GlassCard(
                                        margin: EdgeInsets.zero,
                                        otherRadius: 30,
                                        padding: EdgeInsets.zero,
                                        child: (state is SignInLoading)
                                            ? Center(
                                          child: LoadingAnimationWidget.staggeredDotsWave(
                                            color: ThemingColors.primaryColor,
                                            size: 25,
                                          ),
                                        )
                                            : Center(
                                          child: Text(
                                            "Login",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: ThemingColors.primaryColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 70),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
