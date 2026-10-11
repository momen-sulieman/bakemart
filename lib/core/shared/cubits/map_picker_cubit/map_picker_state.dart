part of 'map_picker_cubit.dart';

class MapPickerState {
  final LatLng target;
  final bool hasDragged;

  const MapPickerState({required this.target, required this.hasDragged});

  MapPickerState copyWith({LatLng? target, bool? hasDragged}) {
    return MapPickerState(
      target: target ?? this.target,
      hasDragged: hasDragged ?? this.hasDragged,
    );
  }
}