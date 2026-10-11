import 'package:collection/collection.dart';

import '../../utils/enums/bakeries_table_columns.dart';

class BakeryModel {
  final String bakeryId;
  final String bakeryName;
  final double bakeryLat;
  final double bakeryLng;
  final List<String> supervisorId;
  final bool verified;

  BakeryModel({
    required this.bakeryId,
    required this.bakeryName,
    required this.bakeryLat,
    required this.bakeryLng,
    required this.supervisorId,
    this.verified = false,
  });

  factory BakeryModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedSupervisorIds = [];
    if (json[BakeriesTableColumns.supervisorId] is List) {
      parsedSupervisorIds = (json[BakeriesTableColumns.supervisorId] as List)
          .map((item) => item.toString())
          .toList();
    } else if (json[BakeriesTableColumns.supervisorId] is String &&
        (json[BakeriesTableColumns.supervisorId] as String).isNotEmpty) {
      parsedSupervisorIds = [json[BakeriesTableColumns.supervisorId] as String];
    }

    return BakeryModel(
      bakeryId: json[BakeriesTableColumns.bakeryId] as String? ?? '',
      bakeryName: json[BakeriesTableColumns.bakeryName] as String? ?? '',
      bakeryLat: (json[BakeriesTableColumns.bakeryLat] as num?)?.toDouble() ?? 0.0,
      bakeryLng: (json[BakeriesTableColumns.bakeryLng] as num?)?.toDouble() ?? 0.0,
      supervisorId: parsedSupervisorIds,
      verified: json[BakeriesTableColumns.verified] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      BakeriesTableColumns.bakeryId: bakeryId,
      BakeriesTableColumns.bakeryName: bakeryName,
      BakeriesTableColumns.bakeryLat: bakeryLat,
      BakeriesTableColumns.bakeryLng: bakeryLng,
      BakeriesTableColumns.supervisorId: supervisorId,
      BakeriesTableColumns.verified: verified,
    };
  }

  BakeryModel copyWith({
    String? bakeryId,
    String? bakeryName,
    double? bakeryLat,
    double? bakeryLng,
    List<String>? supervisorId,
    bool? verified,
  }) {
    return BakeryModel(
      bakeryId: bakeryId ?? this.bakeryId,
      bakeryName: bakeryName ?? this.bakeryName,
      bakeryLat: bakeryLat ?? this.bakeryLat,
      bakeryLng: bakeryLng ?? this.bakeryLng,
      supervisorId: supervisorId ?? this.supervisorId,
      verified: verified ?? this.verified,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BakeryModel &&
        other.bakeryId == bakeryId &&
        other.bakeryName == bakeryName &&
        other.bakeryLat == bakeryLat &&
        other.bakeryLng == bakeryLng &&
        other.verified == verified &&
        const ListEquality<String>().equals(other.supervisorId, supervisorId);
  }

  @override
  int get hashCode => Object.hash(
    bakeryId,
    bakeryName,
    bakeryLat,
    bakeryLng,
    verified,
    const ListEquality<String>().hash(supervisorId),
  );
}