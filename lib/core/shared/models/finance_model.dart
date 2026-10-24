import '../../../../../../../core/shared/models/waste_model.dart';
import '../../utils/enums/finance_table_columns.dart';
import 'expenses_model.dart';

class FinanceModel {
  final String bakeryId;
  final String branchId;
  final DateTime? date;
  final List<ExpensesModel> expenses;
  final List<WasteModel> wastes;
  final double payrollExpenses;
  final double profit;

  FinanceModel({
    required this.bakeryId,
    required this.branchId,
    this.date,
    required this.expenses,
    required this.wastes,
    this.payrollExpenses = 0.0,
    this.profit = 0.0,
  });

  // Getter for the sum of all expenses in the list
  double get sideExpenses {
    if (expenses.isEmpty) return 0.0;
    return expenses.fold(0.0, (sum, item) => sum + item.value);
  }

  double get totalExpenses {
    return sideExpenses + payrollExpenses;
  }

  double get netProfit {
    return profit - totalExpenses;
  }

  factory FinanceModel.fromJson(Map<String, dynamic> json) {
    final rawWastes = json[FinanceTableColumns.wastes] as List?;

    final rawExpenses = json[FinanceTableColumns.expenses] as List?;

    return FinanceModel(
      bakeryId: json[FinanceTableColumns.bakeryId] as String,
      branchId: json[FinanceTableColumns.branchId] as String,
      date: json[FinanceTableColumns.date] != null
          ? DateTime.parse(json[FinanceTableColumns.date] as String).toLocal()
          : null,
      expenses: rawExpenses
          ?.map((item) => ExpensesModel.fromJson(item as Map<String, dynamic>))
          .toList() ??
          const [],
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
      FinanceTableColumns.expenses:
      expenses.map((expense) => expense.toJson()).toList(),
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
    List<ExpensesModel>? expenses,
    List<WasteModel>? wastes,
    double? payrollExpenses,
    double? profit,
  }) {
    return FinanceModel(
      bakeryId: bakeryId ?? this.bakeryId,
      branchId: branchId ?? this.branchId,
      date: date ?? this.date,
      expenses: expenses ?? this.expenses,
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
        other.expenses == expenses &&
        other.payrollExpenses == payrollExpenses &&
        other.profit == profit;
  }

  @override
  int get hashCode => Object.hash(
    bakeryId,
    branchId,
    date,
    expenses,
    payrollExpenses,
    profit,
  );
}