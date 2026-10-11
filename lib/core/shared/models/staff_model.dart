import '../../utils/enums/staffs_table_columns.dart';

class StaffModel {
  final String workerName;
  final String workerId;
  final String bakeryId;

  StaffModel({
    required this.workerName,
    required this.workerId,
    required this.bakeryId,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      workerName: json[StaffsTableColumns.workerName] as String? ?? '',
      workerId: json[StaffsTableColumns.workerId] as String? ?? '',
      bakeryId: json[StaffsTableColumns.bakeryId] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      StaffsTableColumns.workerName: workerName,
      StaffsTableColumns.workerId: workerId,
      StaffsTableColumns.bakeryId: bakeryId,
    };
  }

  StaffModel copyWith({
    String? workerName,
    String? workerId,
    String? bakeryId,
  }) {
    return StaffModel(
      workerName: workerName ?? this.workerName,
      workerId: workerId ?? this.workerId,
      bakeryId: bakeryId ?? this.bakeryId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StaffModel &&
        other.workerName == workerName &&
        other.workerId == workerId &&
        other.bakeryId == bakeryId;
  }

  @override
  int get hashCode => Object.hash(
    workerName,
    workerId,
    bakeryId,
  );
}