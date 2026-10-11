import 'dart:async';

import 'package:bakemart/core/services/location_services.dart';
import 'package:bakemart/core/shared/cubits/location_cubit/location_cubit.dart';
import 'package:bakemart/core/shared/cubits/location_cubit/location_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fixtures.dart';
import '../helpers/supabase_fakes.dart';

void main() {
  late MockLocationServices services;
  late StreamController<Position> positions;

  LocationCubit build() {
    final cubit = LocationCubit(
      locationServices: services,
      positionStream: () => positions.stream,
    );
    addTearDown(cubit.close);
    return cubit;
  }

  List<LocationState> collect(LocationCubit cubit) {
    final states = <LocationState>[];
    cubit.stream.listen(states.add);
    return states;
  }

  setUp(() {
    services = MockLocationServices();
    positions = StreamController<Position>.broadcast();
  });

  tearDown(() {
    positions.close();
  });

  test('starts in LocationInitial', () {
    when(
          () => services.getCurrentLocation(),
    ).thenAnswer((_) async => fakePosition(30, 31));

    final cubit = build();

    expect(cubit.state, isA<LocationInitial>());
  });

  test('emits the current location then every streamed update', () async {
    when(
          () => services.getCurrentLocation(),
    ).thenAnswer((_) async => fakePosition(30, 31));
    final cubit = build();
    final states = collect(cubit);
    await pumpEventQueue();

    positions.add(fakePosition(31, 32));
    await pumpEventQueue();

    expect(states, hasLength(2));
    expect((states[0] as LocationUpdated).lat, 30);
    expect((states[0] as LocationUpdated).lng, 31);
    expect((states[1] as LocationUpdated).lat, 31);
    expect((states[1] as LocationUpdated).lng, 32);
  });

  test('emits a failure with the reason for a service exception', () async {
    when(() => services.getCurrentLocation()).thenAnswer(
          (_) => Future<Position>.error(
        LocationServiceException(
          'Location services are disabled.',
          LocationFailureReason.serviceDisabled,
        ),
      ),
    );
    final cubit = build();
    final states = collect(cubit);

    await pumpEventQueue();

    final failure = states.single as LocationFailure;
    expect(failure.error, 'Location services are disabled.');
    expect(failure.reason, LocationFailureReason.serviceDisabled);
  });

  test('emits an unknown failure for any other error', () async {
    when(
          () => services.getCurrentLocation(),
    ).thenAnswer((_) => Future<Position>.error(Exception('boom')));
    final cubit = build();
    final states = collect(cubit);

    await pumpEventQueue();

    final failure = states.single as LocationFailure;
    expect(failure.reason, LocationFailureReason.unknown);
    expect(failure.error, contains('boom'));
  });

  test('emits a failure when the position stream errors', () async {
    when(
          () => services.getCurrentLocation(),
    ).thenAnswer((_) async => fakePosition(30, 31));
    final cubit = build();
    final states = collect(cubit);
    await pumpEventQueue();

    positions.addError('gps lost');
    await pumpEventQueue();

    expect(states.last, isA<LocationFailure>());
    expect((states.last as LocationFailure).error, 'gps lost');
  });

  test('retryTracking tries again after a failure', () async {
    when(() => services.getCurrentLocation()).thenAnswer(
          (_) => Future<Position>.error(
        LocationServiceException(
          'Location permissions are denied.',
          LocationFailureReason.permissionDenied,
        ),
      ),
    );
    final cubit = build();
    final states = collect(cubit);
    await pumpEventQueue();
    when(
          () => services.getCurrentLocation(),
    ).thenAnswer((_) async => fakePosition(30, 31));

    cubit.retryTracking();
    await pumpEventQueue();

    expect(states, [isA<LocationFailure>(), isA<LocationUpdated>()]);
  });

  test('close stops listening to the position stream', () async {
    when(
          () => services.getCurrentLocation(),
    ).thenAnswer((_) async => fakePosition(30, 31));
    final cubit = build();
    await pumpEventQueue();
    expect(positions.hasListener, true);

    await cubit.close();

    expect(positions.hasListener, false);
  });
}