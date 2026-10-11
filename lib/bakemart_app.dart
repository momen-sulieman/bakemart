import 'package:bakemart/core/routing/app_router.dart';
import 'package:bakemart/core/theming/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';


class BakemartApp extends StatelessWidget {
  const BakemartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightMode,
      darkTheme: AppTheme.darkMode,
      themeMode: ThemeMode.system,
      onGenerateRoute:AppRouter.onGenerateRoute ,
    );
  }
}
