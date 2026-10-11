import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

part 'map_picker_state.dart';

class MapPickerCubit extends Cubit<MapPickerState> {
  final MapController mapController = MapController();

  MapPickerCubit({required double initialLat, required double initialLng})
    : super(
        MapPickerState(
          target: LatLng(initialLat, initialLng),
          hasDragged: false,
        ),
      );

  void onCameraMoved(LatLng center, bool hasGesture) {
    if (hasGesture) {
      emit(state.copyWith(target: center, hasDragged: true));
    }
  }
  void collapse() {
    emit(state.copyWith(hasDragged: false));
  }
  void recenter(
    double lat,
    double lng, {
    bool hideOnRecenter = false,
    bool forceHide = false,
  }) {
    final target = LatLng(lat, lng);
    mapController.move(target, mapController.camera.zoom);
    final bool newHasDragged = forceHide
        ? false
        : (hideOnRecenter ? false : state.hasDragged);
    emit(state.copyWith(target: target, hasDragged: newHasDragged));
  }

  @override
  Future<void> close() {
    mapController.dispose();
    return super.close();
  }
}
