import 'package:bakemart/core/routing/app_routes.dart';
import 'package:bakemart/core/shared/cubits/obscurity_cubit/obscurity_cubit.dart';
import 'package:bakemart/core/shared/widgets/glass_card/glass_card.dart';
import 'package:bakemart/core/shared/widgets/text_form_field/text_form_field.dart';
import 'package:bakemart/core/theming/theming_colors.dart';
import 'package:bakemart/core/utils/constants/constant_images.dart';
import 'package:bakemart/core/utils/extensions/context_extensions.dart';
import 'package:bakemart/core/utils/form_keys/form_keys.dart';
import 'package:bakemart/features/authentication/sign_up/logic/sign_up_cubit/sign_up_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../../core/shared/models/my_clipper.dart';
import '../../../../core/shared/widgets/supabase_image/logic/supabase_image_cubit/supabase_image_cubit.dart';
import '../../../../core/shared/widgets/supabase_image/ui/supabase_image.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SignUpCubit>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Form(
        key: signUpFormKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final screenWidth = constraints.maxWidth;
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: screenHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      ClipPath(
                        clipper: MyClipper(),
                        child: Container(
                          height: screenHeight * 0.15,
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
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(
                            "Sign up",
                            style: GoogleFonts.molle(
                              fontSize: 40,
                              color: ThemingColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      InkWell(
                        hoverColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () =>
                            context.read<SupabaseImageCubit>().pickImage(false),
                        child: Stack(
                          children: [
                            ClipOval(
                              child: Container(
                                width: screenWidth * 0.26,
                                height: screenWidth * 0.26,
                                color: ThemingColors.primaryColor.withAlpha(
                                  (0.2 * 255).toInt(),
                                ),
                                child: const SupabaseImage(),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: 1.5,
                                    color: ThemingColors.primaryColor.withAlpha(
                                      (0.5 * 255).toInt(),
                                    ),
                                  ),
                                  color: context.isDark
                                      ? ThemingColors.darkGrey
                                      : ThemingColors.lightGrey,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 18,
                                  color: ThemingColors.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        height: 80,
                        width: screenWidth * 0.7,
                        child: CustomTextFormField(
                          "First name",
                          auth: true,
                          capitalization: TextCapitalization.words,
                          controller: cubit.firstNameController,
                          validate: true,
                        ),
                      ),
                      SizedBox(
                        height: 80,
                        width: screenWidth * 0.7,
                        child: CustomTextFormField(
                          "Second name",
                          auth: true,
                          validate: true,
                          capitalization: TextCapitalization.words,
                          controller: cubit.secondNameController,
                        ),
                      ),
                      SizedBox(
                        height: 80,
                        width: screenWidth * 0.7,
                        child: BlocBuilder<SignUpCubit, SignUpState>(
                          builder: (context, state) {
                            return CustomTextFormField(
                              "Phone Number",
                              controller: cubit.phoneController,
                              isPhone: true,
                              validate: true,
                              auth: true,
                              selectedCountryCode: cubit.countryCode,
                              onCountryChanged: (newCode) {
                                if (newCode != null) {
                                  cubit.updateCountryCode(newCode);
                                }
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 80,
                        width: screenWidth * 0.7,
                        child: CustomTextFormField(
                          "Email",
                          auth: true,
                          keyBoardType: TextInputType.emailAddress,
                          controller: cubit.emailController,
                          prefixIcon: Icons.alternate_email,
                          validate: true,
                          emailValidation: true,
                        ),
                      ),
                      BlocBuilder<ObscurityCubit, bool>(
                        builder: (context, obscurityState) {
                          return Column(
                            children: [
                              SizedBox(
                                height: 80,
                                width: screenWidth * 0.7,
                                child: CustomTextFormField(
                                  "Password",
                                  auth: true,
                                  controller: cubit.passwordController,
                                  prefixIcon: Icons.lock,
                                  obscurity: obscurityState,
                                  validate: true,
                                  passwordValidation: true,
                                  suffixIcon: InkWell(
                                    hoverColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      context.read<ObscurityCubit>().change();
                                    },
                                    child: Icon(
                                      obscurityState
                                          ? Icons.remove_red_eye
                                          : Icons.remove_red_eye_outlined,
                                      size: 20,
                                      color: Colors.blueGrey.withAlpha(
                                        obscurityState ? 255 : (0.5 * 255).toInt(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 80,
                                width: screenWidth * 0.7,
                                child: CustomTextFormField(
                                  "Confirm password",
                                  auth: true,
                                  controller: cubit.confirmPasswordController,
                                  otherController: cubit.passwordController,
                                  prefixIcon: Icons.lock,
                                  obscurity: obscurityState,
                                  validate: true,
                                  passwordValidation: true,
                                  passwordMatch: true,
                                  suffixIcon: InkWell(
                                    hoverColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      context.read<ObscurityCubit>().change();
                                    },
                                    child: Icon(
                                      obscurityState
                                          ? Icons.remove_red_eye
                                          : Icons.remove_red_eye_outlined,
                                      size: 20,
                                      color: Colors.blueGrey.withAlpha(
                                        obscurityState ? 255 : (0.5 * 255).toInt(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.16,
                                ),
                                child: const Row(
                                  children: [
                                    Expanded(child: Divider(thickness: 1)),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                                      child: Text(
                                        'Optional',
                                        style: TextStyle(fontSize: 11),
                                      ),
                                    ),
                                    Expanded(child: Divider(thickness: 1)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),
                              SizedBox(
                                height: 80,
                                width: screenWidth * 0.7,
                                child: CustomTextFormField(
                                  "Street name",
                                  auth: true,
                                  controller: cubit.streetController,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.15,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 80,
                                        width: screenWidth * 0.7,
                                        child: CustomTextFormField(
                                          "Building no.",
                                          auth: true,
                                          controller: cubit.buildingController,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: SizedBox(
                                        height: 80,
                                        width: screenWidth * 0.7,
                                        child: CustomTextFormField(
                                          "Apartment no.",
                                          auth: true,
                                          controller: cubit.apartmentController,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const Spacer(),
                      BlocConsumer<SignUpCubit, SignUpState>(
                        listener: (context, state) {
                          if (state is SignUpSuccess) {
                            Navigator.of(context)
                                .pushReplacementNamed(AppRoutes.splash.route);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                elevation: 0,
                                backgroundColor: Colors.transparent,
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 10),
                                content: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GlassCard(
                                      margin: EdgeInsets.zero,
                                      padding: .symmetric(
                                        vertical: 7,
                                        horizontal: 20,
                                      ),
                                      otherRadius: 30,
                                      green: true,
                                      child: Text(
                                        "welcome".tr(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: context.isDark
                                              ? ThemingColors.white
                                              : ThemingColors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            );
                          } else if (state is SignUpFailure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  elevation: 0,
                                  backgroundColor: Colors.transparent,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 10),
                                  content: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 250,
                                        ),
                                        child: GlassCard(
                                          margin: EdgeInsets.zero,
                                          padding: .symmetric(
                                            vertical: 7,
                                            horizontal: 20,
                                          ),
                                          otherRadius: 30,
                                          orange: true,
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
                                    ],
                                  ),
                                )
                            );
                          }
                        },
                        builder: (context, state) {
                          return InkWell(
                            hoverColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              if (state is! SignUpLoading &&
                                  signUpFormKey.currentState!.validate()) {
                                cubit.signUp();
                              }
                            },
                            child: SizedBox(
                              width: screenWidth * 0.7,
                              height: 45,
                              child: GlassCard(
                                margin: EdgeInsets.zero,
                                otherRadius: 30,
                                padding: EdgeInsets.zero,
                                child: (state is SignUpLoading)
                                    ? Center(
                                  child: LoadingAnimationWidget
                                      .staggeredDotsWave(
                                    color: ThemingColors.primaryColor,
                                    size: 25,
                                  ),
                                )
                                    : const Center(
                                  child: Text(
                                    "Sign up",
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
                      const SizedBox(height: 70),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}