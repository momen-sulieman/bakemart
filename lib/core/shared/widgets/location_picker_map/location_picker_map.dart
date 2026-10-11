import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../theming/theming_colors.dart';
import '../../cubits/map_picker_cubit/map_picker_cubit.dart';

enum LocationMapMode { setter, viewer }

class MapMarkerData {
  final double lat;
  final double lng;
  final IconData icon;
  final Color? color;

  const MapMarkerData({
    required this.lat,
    required this.lng,
    required this.icon,
    this.color,
  });
}

class LocationPickerMap extends StatelessWidget {
  final double initialLat;
  final double initialLng;
  final LocationMapMode mode;
  final double? deviceLat;
  final double? deviceLng;
  final double? resetLat;
  final double? resetLng;
  final IconData? resetMarkerIcon;
  final bool alwaysShow;
  final bool hideWhenRecenter;
  final bool hideOnSet;
  final bool alwaysShowPin;
  final void Function(double lat, double lng)? onPositionChanged;
  final void Function(double lat, double lng)? onSet;
  final List<MapMarkerData> markers;
  final List<LatLng> routePoints;

  const LocationPickerMap.setter({
    required this.initialLat,
    required this.initialLng,
    required this.onSet,
    this.deviceLat,
    this.deviceLng,
    this.resetLat,
    this.resetLng,
    this.resetMarkerIcon,
    this.alwaysShow = true,
    this.hideWhenRecenter = false,
    this.hideOnSet = false,
    this.alwaysShowPin = false,
    this.onPositionChanged,
    super.key,
  }) : mode = LocationMapMode.setter,
       markers = const [],
       routePoints = const [];

  const LocationPickerMap.viewer({
    required this.initialLat,
    required this.initialLng,
    this.markers = const [],
    this.routePoints = const [],
    this.deviceLat,
    this.deviceLng,
    super.key,
  })  : mode = LocationMapMode.viewer,
        onSet = null,
        onPositionChanged = null,
        resetLat = null,
        resetLng = null,
        resetMarkerIcon = null,
        alwaysShow = true,
        hideWhenRecenter = false,
        hideOnSet = false,
        alwaysShowPin = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MapPickerCubit(initialLat: initialLat, initialLng: initialLng),
      child: _LocationPickerMapView(
        mode: mode,
        deviceLat: deviceLat,
        deviceLng: deviceLng,
        resetLat: resetLat,
        resetLng: resetLng,
        resetMarkerIcon: resetMarkerIcon,
        alwaysShow: alwaysShow,
        hideWhenRecenter: hideWhenRecenter,
        hideOnSet: hideOnSet,
        alwaysShowPin: alwaysShowPin,
        onPositionChanged: onPositionChanged,
        onSet: onSet,
        markers: markers,
        routePoints: routePoints,
      ),
    );
  }
}

class _LocationPickerMapView extends StatelessWidget {
  final LocationMapMode mode;
  final double? deviceLat;
  final double? deviceLng;
  final double? resetLat;
  final double? resetLng;
  final IconData? resetMarkerIcon;
  final bool alwaysShow;
  final bool hideWhenRecenter;
  final bool hideOnSet;
  final bool alwaysShowPin;
  final void Function(double lat, double lng)? onPositionChanged;
  final void Function(double lat, double lng)? onSet;
  final List<MapMarkerData> markers;
  final List<LatLng> routePoints;

  const _LocationPickerMapView({
    required this.mode,
    required this.deviceLat,
    required this.deviceLng,
    required this.resetLat,
    required this.resetLng,
    required this.resetMarkerIcon,
    required this.alwaysShow,
    required this.hideWhenRecenter,
    required this.hideOnSet,
    required this.alwaysShowPin,
    required this.onPositionChanged,
    required this.onSet,
    required this.markers,
    required this.routePoints,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MapPickerCubit>();
    return BlocBuilder<MapPickerCubit, MapPickerState>(
      builder: (context, state) {
        final bool hasDevice = deviceLat != null && deviceLng != null;
        final bool hasReset = resetLat != null && resetLng != null;
        final bool visible = alwaysShow || state.hasDragged;

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Directionality(
            textDirection: ui.TextDirection.ltr,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: cubit.mapController,
                  options: MapOptions(
                    initialCenter: state.target,
                    initialZoom: 16,
                    onPositionChanged: (position, hasGesture) {
                      cubit.onCameraMoved(position.center, hasGesture);
                      if (hasGesture && mode == LocationMapMode.setter) {
                        onPositionChanged?.call(
                          position.center.latitude,
                          position.center.longitude,
                        );
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.bakemart.app',
                    ),
                    if (routePoints.length >= 2)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: routePoints,
                            strokeWidth: 4,
                            color: ThemingColors.primaryColor,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        if (hasDevice)
                          Marker(
                            point: LatLng(deviceLat!, deviceLng!),
                            width: 18,
                            height: 18,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ThemingColors.primaryColor,
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                            ),
                          ),
                        if (hasReset && resetMarkerIcon != null)
                          Marker(
                            point: LatLng(resetLat!, resetLng!),
                            width: 34,
                            height: 34,
                            alignment: Alignment.bottomCenter,
                            child: Icon(
                              resetMarkerIcon,
                              size: 35,
                              color: ThemingColors.black,
                            ),
                          ),
                        if (mode == LocationMapMode.viewer)
                          for (final marker in markers)
                            Marker(
                              point: LatLng(marker.lat, marker.lng),
                              width: 34,
                              height: 34,
                              alignment: Alignment.bottomCenter,
                              child: Icon(
                                marker.icon,
                                size: 34,
                                color: marker.color ?? ThemingColors.black,
                              ),
                            ),
                      ],
                    ),
                    const RichAttributionWidget(
                      alignment: AttributionAlignment.bottomLeft,
                      attributions: [
                        TextSourceAttribution('OpenStreetMap contributors'),
                      ],
                    ),
                  ],
                ),
                if (mode == LocationMapMode.setter && (alwaysShowPin || visible))
                  IgnorePointer(
                    child: Center(
                      child: Transform.translate(
                        offset: const Offset(0, -18),
                        child: Icon(
                          Icons.location_pin,
                          size: 40,
                          color: ThemingColors.black,
                        ),
                      ),
                    ),
                  ),
                if (mode == LocationMapMode.setter && hasReset && visible)
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        hoverColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                        onTap: () =>
                            cubit.recenter(resetLat!, resetLng!, forceHide: true),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ThemingColors.black.withAlpha(
                              (0.7 * 255).toInt(),
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            resetMarkerIcon ?? Icons.location_on_outlined,
                            size: 20,
                            color: ThemingColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (visible)
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Row(
                        children: [
                          Expanded(
                            child: mode == LocationMapMode.setter
                                ? Center(
                                    child: InkWell(
                                      hoverColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () {
                                        onSet?.call(
                                          state.target.latitude,
                                          state.target.longitude,
                                        );
                                        if (hideOnSet) cubit.collapse();
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          left: 60,
                                          right: 20,
                                        ),
                                        height: 30,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(30),
                                            bottomLeft: Radius.circular(30),
                                          ),
                                          color: ThemingColors.black.withAlpha(
                                            (0.7 * 255).toInt(),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "setLocation".tr(),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: ThemingColors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                          ),
                          if (hasDevice)
                            Container(
                              margin: const EdgeInsets.only(right: 40),
                              height: 30,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(30),
                                  bottomLeft: Radius.circular(30),
                                ),
                                color: ThemingColors.black.withAlpha(
                                  (0.7 * 255).toInt(),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: InkWell(
                                hoverColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () => cubit.recenter(
                                  deviceLat!,
                                  deviceLng!,
                                  hideOnRecenter: hideWhenRecenter,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                  child: Icon(
                                    Icons.my_location,
                                    size: 18,
                                    color: ThemingColors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
