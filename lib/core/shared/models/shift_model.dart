import 'package:collection/collection.dart';

import '../../utils/enums/shifts_table_columns.dart';

class ShiftModel {
  final String bakeryId;
  final String branchId;
  final String workerId;
  final String workerName;
  final double wage;
  final List<String> role;
  final List<int> numberOfBatches;
  final DateTime? date;
  final double? rate;

  ShiftModel({
    required this.bakeryId,
    required this.branchId,
    required this.workerId,
    required this.workerName,
    required this.wage,
    required this.role,
    required this.numberOfBatches,
    this.date,
    this.rate,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    // Handle parsing the roles list
    List<String> parsedRoles = ['General'];
    if (json[ShiftsTableColumns.role] is List) {
      parsedRoles = (json[ShiftsTableColumns.role] as List)
          .map((item) => item.toString())
          .toList();
    } else if (json[ShiftsTableColumns.role] is String &&
        (json[ShiftsTableColumns.role] as String).isNotEmpty) {
      parsedRoles = [json[ShiftsTableColumns.role] as String];
    }

    List<int> parsedBatches = [];
    if (json[ShiftsTableColumns.numberOfBatches] is List) {
      parsedBatches = (json[ShiftsTableColumns.numberOfBatches] as List)
          .map((item) => (item as num).toInt())
          .toList();
    } else if (json[ShiftsTableColumns.numberOfBatches] is num) {
      // Fallback: If database still has old single integers, convert it to a single-element list
      parsedBatches = [(json[ShiftsTableColumns.numberOfBatches] as num).toInt()];
    }

    return ShiftModel(
      bakeryId: json[ShiftsTableColumns.bakeryId] as String? ?? '',
      branchId: json[ShiftsTableColumns.branchId] as String? ?? '',
      workerId: json[ShiftsTableColumns.workerId] as String? ?? '',
      workerName:
      json[ShiftsTableColumns.workerName] as String? ?? 'Unknown Worker',
      wage: (json[ShiftsTableColumns.wage] as num?)?.toDouble() ?? 0.0,
      role: parsedRoles,
      numberOfBatches: parsedBatches,
      date: json[ShiftsTableColumns.date] != null
          ? DateTime.parse(json[ShiftsTableColumns.date] as String).toLocal()
          : null,
      rate: (json[ShiftsTableColumns.rate] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ShiftsTableColumns.bakeryId: bakeryId,
      ShiftsTableColumns.branchId: branchId,
      ShiftsTableColumns.workerId: workerId,
      ShiftsTableColumns.workerName: workerName,
      ShiftsTableColumns.wage: wage,
      ShiftsTableColumns.role: role,
      ShiftsTableColumns.numberOfBatches: numberOfBatches,
      if (date != null)
        ShiftsTableColumns.date: date!.toIso8601String().split('T').first,
      if (rate != null) ShiftsTableColumns.rate: rate,
    };
  }

  ShiftModel copyWith({
    String? bakeryId,
    String? branchId,
    String? workerId,
    String? workerName,
    double? wage,
    List<String>? role,
    List<int>? numberOfBatches,
    DateTime? date,
    double? rate,
  }) {
    return ShiftModel(
      bakeryId: bakeryId ?? this.bakeryId,
      branchId: branchId ?? this.branchId,
      workerId: workerId ?? this.workerId,
      workerName: workerName ?? this.workerName,
      wage: wage ?? this.wage,
      role: role ?? this.role,
      numberOfBatches: numberOfBatches ?? this.numberOfBatches,
      date: date ?? this.date,
      rate: rate ?? this.rate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShiftModel &&
        other.bakeryId == bakeryId &&
        other.branchId == branchId &&
        other.workerId == workerId &&
        other.workerName == workerName &&
        other.wage == wage &&
        const ListEquality<String>().equals(other.role, role) &&
        const ListEquality<int>().equals(other.numberOfBatches, numberOfBatches) &&
        other.date == date &&
        other.rate == rate;
  }

  @override
  int get hashCode => Object.hash(
    bakeryId,
    branchId,
    workerId,
    workerName,
    wage,
    const ListEquality<String>().hash(role),
    const ListEquality<int>().hash(numberOfBatches),
    date,
    rate,
  );
}