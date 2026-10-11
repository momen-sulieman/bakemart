import 'package:bakemart/features/authentication/forgot_password/logic/forgot_password_cubit/forgot_password_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../../core/shared/models/my_clipper.dart';
import '../../../../core/shared/widgets/glass_card/glass_card.dart';
import '../../../../core/shared/widgets/text_form_field/text_form_field.dart';
import '../../../../core/theming/theming_colors.dart';
import '../../../../core/utils/constants/constant_images.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/form_keys/form_keys.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Form(
        key: forgotPasswordFormKey,
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
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: .only(left: 25),
                          child: Text(
                            "Reset password",
                            style: GoogleFonts.molle(
                              fontSize: 30,
                              color: ThemingColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.05),
                      SizedBox(
                        width: screenWidth * 0.7,
                        child: CustomTextFormField(
                          "Email",
                          auth: true,
                          controller: context
                              .read<ForgotPasswordCubit>()
                              .emailController,
                          prefixIcon: Icons.alternate_email,
                          validate: true,
                          emailValidation: true,
                        ),
                      ),
                      Spacer(),
                      BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
                        listener: (context, state) {
                          if (state is ForgotPasswordSuccess) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("E-mail sent!")),
                            );
                          } else if (state is ForgotPasswordFailure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Request Failed!")),
                            );
                          }
                        },
                        builder: (context, state) => InkWell(
                          onTap: () {
                            if (state is! ForgotPasswordLoading &&
                                forgotPasswordFormKey.currentState!
                                    .validate()) {
                              context
                                  .read<ForgotPasswordCubit>()
                                  .resetPassword();
                            }
                          },
                          child: SizedBox(
                            width: screenWidth * 0.7,
                            height: 45,
                            child: GlassCard(
                              margin: .zero,
                              otherRadius: 30,
                              padding: .zero,
                              child: Center(
                                child: state is ForgotPasswordLoading
                                    ? LoadingAnimationWidget.staggeredDotsWave(
                                        color: ThemingColors.primaryColor,
                                        size: 25,
                                      )
                                    : Text(
                                        "Send an e-mail",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: ThemingColors.primaryColor,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 70),
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
