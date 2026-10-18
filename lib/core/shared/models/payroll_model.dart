import '../../utils/enums/payrolls_table_columns.dart';

class PayrollModel {
  final String bakeryId;
  final String branchId;
  final bool payrollMethod;
  final double? ajan;
  final double? faran;
  final double? tawlaji;
  final double? chef;
  final double? coChef;
  final double? bagger;
  final double? supervisor;

  PayrollModel({
    required this.bakeryId,
    required this.branchId,
    required this.payrollMethod,
    this.ajan,
    this.faran,
    this.tawlaji,
    this.chef,
    this.coChef,
    this.bagger,
    this.supervisor,
  });

  factory PayrollModel.fromJson(Map<String, dynamic> json) {
    return PayrollModel(
      bakeryId: json[PayrollsTableColumns.bakeryId] as String? ?? '',
      branchId: json[PayrollsTableColumns.branchId] as String? ?? '',
      payrollMethod: json[PayrollsTableColumns.payrollMethod] as bool? ?? false,
      ajan: (json[PayrollsTableColumns.ajan] as num?)?.toDouble(),
      faran: (json[PayrollsTableColumns.faran] as num?)?.toDouble(),
      tawlaji: (json[PayrollsTableColumns.tawlaji] as num?)?.toDouble(),
      chef: (json[PayrollsTableColumns.chef] as num?)?.toDouble(),
      coChef: (json[PayrollsTableColumns.coChef] as num?)?.toDouble(),
      bagger: (json[PayrollsTableColumns.bagger] as num?)?.toDouble(),
      supervisor: (json[PayrollsTableColumns.supervisor] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      PayrollsTableColumns.bakeryId: bakeryId,
      PayrollsTableColumns.branchId: branchId,
      PayrollsTableColumns.payrollMethod: payrollMethod,
      PayrollsTableColumns.ajan: ajan,
      PayrollsTableColumns.faran: faran,
      PayrollsTableColumns.tawlaji: tawlaji,
      PayrollsTableColumns.chef: chef,
      PayrollsTableColumns.coChef: coChef,
      PayrollsTableColumns.bagger: bagger,
      PayrollsTableColumns.supervisor: supervisor,
    };
  }

  PayrollModel copyWith({
    String? bakeryId,
    String? branchId,
    bool? payrollMethod,
    double? ajan,
    double? faran,
    double? tawlaji,
    double? chef,
    double? coChef,
    double? bagger,
    double? supervisor,
  }) {
    return PayrollModel(
      bakeryId: bakeryId ?? this.bakeryId,
      branchId: branchId ?? this.branchId,
      payrollMethod: payrollMethod ?? this.payrollMethod,
      ajan: ajan ?? this.ajan,
      faran: faran ?? this.faran,
      tawlaji: tawlaji ?? this.tawlaji,
      chef: chef ?? this.chef,
      coChef: coChef ?? this.coChef,
      bagger: bagger ?? this.bagger,
      supervisor: supervisor ?? this.supervisor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PayrollModel &&
        other.bakeryId == bakeryId &&
        other.branchId == branchId &&
        other.payrollMethod == payrollMethod &&
        other.ajan == ajan &&
        other.faran == faran &&
        other.tawlaji == tawlaji &&
        other.chef == chef &&
        other.coChef == coChef &&
        other.bagger == bagger &&
        other.supervisor == supervisor;
  }

  @override
  int get hashCode => Object.hash(
    bakeryId,
    branchId,
    payrollMethod,
    ajan,
    faran,
    tawlaji,
    chef,
    coChef,
    bagger,
    supervisor,
  );
}