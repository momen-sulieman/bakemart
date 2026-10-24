class ExpensesModel {
  final String item;
  final double value;

  const ExpensesModel({
    required this.item,
    required this.value,
  });

  ExpensesModel copyWith({
    String? item,
    double? value,
  }) {
    return ExpensesModel(
      item: item ?? this.item,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': item,
      'value': value,
    };
  }

  factory ExpensesModel.fromJson(Map<String, dynamic> json) {
    return ExpensesModel(
      item: json['item'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpensesModel && other.item == item && other.value == value;
  }

  @override
  int get hashCode => Object.hash(item, value);
}