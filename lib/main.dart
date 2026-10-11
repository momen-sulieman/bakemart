import 'package:bakemart/bakemart_app.dart';
import 'package:bakemart/core/utils/observers/state_observer.dart';
import 'package:bingo/bingo.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/dependency_injection/dependency_injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PaintingBinding.instance.imageCache.maximumSize = 2000;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 200 << 20;
  await Bingo.setup();
  await EasyLocalization.ensureInitialized();
  Bloc.observer = StateObserver();
  DependencyInjection.init();
  await Supabase.initialize(
    url: 'https://qnjasvyfjchjhtufnfsx.supabase.co',
    anonKey: 'sb_publishable_NwZJUepsP5KwNG4g2cB4sQ_ismx8TZY',
  );
  runApp(
    EasyLocalization(
      supportedLocales: [Locale("en"), Locale("ar")],
      path: "assets/translations",
      fallbackLocale: Locale("en"),
      child: BakemartApp(),
    ),
  );
}
