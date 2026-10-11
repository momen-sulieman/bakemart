import '../../../services/location_services.dart';

abstract class LocationState {}

class LocationInitial extends LocationState {}

class LocationUpdated extends LocationState {
  final double lat;
  final double lng;
  LocationUpdated({required this.lat, required this.lng});
}

class LocationFailure extends LocationState {
  final String error;
  final LocationFailureReason reason;
  LocationFailure(this.error, {this.reason = LocationFailureReason.unknown});
}