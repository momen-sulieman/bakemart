import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const String _testRootRoute = '/__test_root__';

final Finder loadingDots = find.byWidgetPredicate(
      (widget) => widget.runtimeType.toString() == 'StaggeredDotsWave',
);

class FileAssetLoader extends AssetLoader {
  const FileAssetLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async {
    final file = File('$path/${locale.languageCode}.json');
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }
}

class RouteRecorder extends NavigatorObserver {
  final List<RouteSettings> pushed = [];

  List<String?> get names => pushed.map((route) => route.name).toList();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null && route.settings.name != _testRootRoute) {
      pushed.add(route.settings);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null && newRoute.settings.name != _testRootRoute) {
      pushed.add(newRoute.settings);
    }
  }
}

void useTallSurface(WidgetTester tester, {Size size = const Size(800, 1600)}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<void> pumpLocalizedWidget(
    WidgetTester tester,
    Widget child, {
      Locale locale = const Locale('en'),
      List<NavigatorObserver> observers = const [],
      bool settle = true,
    }) async {
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      assetLoader: const FileAssetLoader(),
      fallbackLocale: const Locale('en'),
      startLocale: locale,
      child: Builder(
        builder: (context) => MaterialApp(
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          debugShowCheckedModeBanner: false,
          navigatorObservers: observers,
          initialRoute: _testRootRoute,
          onGenerateRoute: (settings) => MaterialPageRoute(
            settings: settings,
            builder: (_) =>
            settings.name == _testRootRoute ? child : const SizedBox(),
          ),
        ),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }
}