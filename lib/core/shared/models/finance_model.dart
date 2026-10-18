import '../../../../../../../core/shared/models/waste_model.dart';
import '../../utils/enums/finance_table_columns.dart';

class FinanceModel {
  final String bakeryId;
  final String branchId;
  final DateTime? date;
  final double cleaningExpenses;
  final List<WasteModel> wastes;
  final double payrollExpenses;
  final double profit;

  FinanceModel({
    required this.bakeryId,
    required this.branchId,
    this.date,
    required this.cleaningExpenses,
    required this.wastes,
    this.payrollExpenses = 0.0,
    this.profit = 0.0,
  });

  double get totalExpenses {
    return cleaningExpenses + payrollExpenses;
  }

  double get netProfit {
    return profit - totalExpenses;
  }

  factory FinanceModel.fromJson(Map<String, dynamic> json) {
    // Check 'wastes' key first, fallback to legacy 'meals' key if 'wastes' is null
    final rawWastes = json[FinanceTableColumns.wastes] as List? ??
        json['meals'] as List?;

    return FinanceModel(
      bakeryId: json[FinanceTableColumns.bakeryId] as String? ?? "",
      branchId: json[FinanceTableColumns.branchId] as String? ?? "",
      date: json[FinanceTableColumns.date] != null
          ? DateTime.parse(json[FinanceTableColumns.date] as String).toLocal()
          : null,
      cleaningExpenses:
      (json[FinanceTableColumns.cleaningExpenses] as num?)?.toDouble() ??
          0.0,
      wastes: rawWastes
          ?.map((item) => WasteModel.fromJson(item as Map<String, dynamic>))
          .toList() ??
          const [],
      payrollExpenses:
      (json[FinanceTableColumns.payrollExpenses] as num?)?.toDouble() ??
          0.0,
      profit: (json[FinanceTableColumns.profit] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      FinanceTableColumns.bakeryId: bakeryId,
      FinanceTableColumns.branchId: branchId,
      if (date != null)
        FinanceTableColumns.date: date!.toIso8601String().split('T').first,
      FinanceTableColumns.cleaningExpenses: cleaningExpenses,
      FinanceTableColumns.wastes:
      wastes.map((waste) => waste.toJson()).toList(),
      FinanceTableColumns.payrollExpenses: payrollExpenses,
      FinanceTableColumns.profit: profit,
    };
  }

  FinanceModel copyWith({
    String? bakeryId,
    String? branchId,
    DateTime? date,
    double? cleaningExpenses,
    List<WasteModel>? wastes,
    double? payrollExpenses,
    double? profit,
  }) {
    return FinanceModel(
      bakeryId: bakeryId ?? this.bakeryId,
      branchId: branchId ?? this.branchId,
      date: date ?? this.date,
      cleaningExpenses: cleaningExpenses ?? this.cleaningExpenses,
      wastes: wastes ?? this.wastes,
      payrollExpenses: payrollExpenses ?? this.payrollExpenses,
      profit: profit ?? this.profit,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FinanceModel &&
        other.bakeryId == bakeryId &&
        other.branchId == branchId &&
        other.date == date &&
        other.cleaningExpenses == cleaningExpenses &&
        other.payrollExpenses == payrollExpenses &&
        other.profit == profit;
  }

  @override
  int get hashCode => Object.hash(
    bakeryId,
    branchId,
    date,
    cleaningExpenses,
    payrollExpenses,
    profit,
  );
}