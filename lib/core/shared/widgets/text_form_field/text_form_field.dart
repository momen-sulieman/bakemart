import 'package:bakemart/core/utils/extensions/context_extensions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../theming/theming_colors.dart';

class CustomTextFormField extends StatelessWidget {
  final String title, validationText;
  final String? hint;
  final double? labelSize;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscurity,
      validate,
      emailValidation,
      passwordValidation,
      passwordMatch,
      auth,
      isPhone;
  final String selectedCountryCode;
  final List<String> availableCountryCodes;
  final ValueChanged<String?>? onCountryChanged;
  final TextInputType keyBoardType;
  final TextCapitalization capitalization;
  final TextEditingController controller;
  final TextEditingController? otherController;
  final void Function(String)? onChanged;
  final String? errorText;

  const CustomTextFormField(
    this.title, {
    required this.controller,
    this.hint,
    this.labelSize=12,
    this.prefixIcon,
    this.suffixIcon,
    this.validate = false,
    this.auth = false,
    this.emailValidation = false,
    this.passwordValidation = false,
    this.passwordMatch = false,
    this.isPhone = false,
    this.selectedCountryCode = '+20',
    this.availableCountryCodes = const ['+20', '+966', '+971', '+1', '+44'],
    this.onCountryChanged,
    this.otherController,
    this.keyBoardType = TextInputType.text,
    this.obscurity = false,
    this.validationText = "cannotBeEmpty",
    this.capitalization = TextCapitalization.none,
    this.onChanged,
    this.errorText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = context.isDark ? Colors.blueGrey : Colors.blueGrey;

    Widget? leadingPrefix;
    if (isPhone) {
      leadingPrefix = Padding(
        padding: const EdgeInsets.only(left: 12, right: 6),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedCountryCode,
            icon: Icon(Icons.arrow_drop_down, size: 18, color: iconColor),
            borderRadius: .circular(20),
            elevation: 0,
            dropdownColor: context.isDark
                ? Colors.blueGrey
                : ThemingColors.white,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: context.isDark ? ThemingColors.white : ThemingColors.black,
            ),
            menuWidth: 65,
            items: availableCountryCodes.map((code) {
              return DropdownMenuItem<String>(value: code, child: Text(code));
            }).toList(),
            onChanged: onCountryChanged,
          ),
        ),
      );
    } else if (prefixIcon != null) {
      leadingPrefix = Icon(prefixIcon, size: 18, color: iconColor);
    }

    return TextFormField(
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      controller: controller,

      validator: validate
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return validationText.tr();
              }
              if (isPhone) {
                if (value.length < 8 || value.length > 11) {
                  return 'phoneValidation'.tr();
                }
              }
              if (emailValidation) {
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value)) {
                  return 'emailValidation'.tr();
                }
              }
              if (passwordValidation) {
                if (value.length < 8) {
                  return 'passwordValidation'.tr();
                }
              }
              if (passwordMatch && otherController != null) {
                if (value != otherController!.text) {
                  return 'passwordMissmatch'.tr();
                }
              }
              return null;
            }
          : null,
      obscureText: obscurity,
      cursorColor: context.isDark
          ? ThemingColors.white.withAlpha((0.6 * 255).toInt())
          : ThemingColors.black.withAlpha((0.6 * 255).toInt()),
      textCapitalization: capitalization,
      keyboardType: isPhone ? TextInputType.phone : keyBoardType,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        hintStyle: TextStyle(
          fontSize: 12,
          color: context.isDark
              ? auth
                    ? ThemingColors.white.withAlpha((0.3 * 255).toInt())
                    : ThemingColors.white
              : auth
              ? Colors.blueGrey.withAlpha((0.5 * 255).toInt())
              : ThemingColors.black,
        ),
        filled: true,
        fillColor: context.isDark
            ? ThemingColors.black.withAlpha((0.6 * 255).toInt())
            : ThemingColors.white.withAlpha((0.6 * 255).toInt()),
        labelText: title,
        labelStyle: TextStyle(
          fontSize: 12,
          color: context.isDark
              ? auth
                    ? Colors.blueGrey
                    : ThemingColors.white
              : auth
              ? Colors.blueGrey
              : ThemingColors.black,
        ),
        floatingLabelStyle: TextStyle(
          fontSize: labelSize,
          color: auth
              ? Colors.blueGrey
              : context.isDark
              ? ThemingColors.white
              : ThemingColors.black,
        ),
        prefixIcon: leadingPrefix,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: context.isDark
                ? auth
                      ? Colors.blueGrey.withAlpha((0.5 * 255).toInt())
                      : ThemingColors.white.withAlpha((0.4 * 255).toInt())
                : auth
                ? Colors.blueGrey.withAlpha((0.5 * 255).toInt())
                : ThemingColors.black.withAlpha((0.4 * 255).toInt()),
            width: 0.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.redAccent, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: context.isDark
                ? auth
                      ? Colors.blueGrey.withAlpha((0.5 * 255).toInt())
                      : ThemingColors.white.withAlpha((0.4 * 255).toInt())
                : auth
                ? Colors.blueGrey.withAlpha((0.5 * 255).toInt())
                : ThemingColors.black.withAlpha((0.4 * 255).toInt()),
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: context.isDark
                ? auth
                      ? Colors.blueGrey
                      : ThemingColors.white
                : auth
                ? Colors.blueGrey
                : ThemingColors.black,
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: Colors.redAccent.withAlpha((0.4 * 255).toInt()),
            width: 0.5,
          ),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
      onChanged: onChanged,
    );
  }
}
