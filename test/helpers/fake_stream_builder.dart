import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

class FakeStreamFilterBuilder extends Stream<SupabaseStreamEvent>
    implements SupabaseStreamFilterBuilder {
  final Stream<SupabaseStreamEvent> _source;

  FakeStreamFilterBuilder(this._source);

  @override
  StreamSubscription<SupabaseStreamEvent> listen(
      void Function(SupabaseStreamEvent event)? onData, {
        Function? onError,
        void Function()? onDone,
        bool? cancelOnError,
      }) {
    return _source.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}