import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../services/location_services.dart';
import 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  final LocationServices _locationServices;
  final Stream<Position> Function() _positionStream;
  StreamSubscription<Position>? _locationSubscription;

  LocationCubit({
    LocationServices? locationServices,
    Stream<Position> Function()? positionStream,
  }) : _locationServices = locationServices ?? LocationServices(),
        _positionStream =
            positionStream ??
                (() => Geolocator.getPositionStream(
                  locationSettings: const LocationSettings(
                    accuracy: LocationAccuracy.high,
                    distanceFilter: 100,
                  ),
                )),
        super(LocationInitial()) {
    _startTracking();
  }

  void _startTracking() async {
    try {
      final position = await _locationServices.getCurrentLocation();
      emit(LocationUpdated(lat: position.latitude, lng: position.longitude));
      _locationSubscription = _positionStream().listen(
            (position) => emit(
          LocationUpdated(lat: position.latitude, lng: position.longitude),
        ),
        onError: (error) => emit(LocationFailure(error.toString())),
      );
    } on LocationServiceException catch (e) {
      emit(LocationFailure(e.message, reason: e.reason));
    } catch (e) {
      emit(LocationFailure(e.toString()));
    }
  }

  void retryTracking() {
    _startTracking();
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    return super.close();
  }
}