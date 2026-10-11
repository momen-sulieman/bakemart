import 'package:bakemart/core/shared/widgets/supabase_image/logic/supabase_image_cubit/supabase_image_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeSupabaseClient extends Mock implements SupabaseClient {}

void _mockAppLinks() {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  for (final name in const [
    'com.llfbandit.app_links/messages',
    'com.llfbandit.app_links/events',
  ]) {
    messenger.setMockMethodCallHandler(MethodChannel(name), (call) async {
      return null;
    });
  }
}

Future<void> setupTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  _mockAppLinks();
  SharedPreferences.setMockInitialValues({});
  await EasyLocalization.ensureInitialized();

  try {
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      anonKey: 'test-anon-key',
    );
  } catch (_) {}

  if (!GetIt.instance.isRegistered<SupabaseImageCubit>()) {
    GetIt.instance.registerFactoryParam<SupabaseImageCubit, String, String?>(
          (filePath, fileName) =>
          SupabaseImageCubit(filePath, null, supabase: _FakeSupabaseClient()),
    );
  }
}