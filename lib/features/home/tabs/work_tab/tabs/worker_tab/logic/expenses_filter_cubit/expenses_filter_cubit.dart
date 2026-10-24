import 'dart:async';

import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/expenses_model.dart';
import 'package:bakemart/core/shared/models/finance_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../../core/shared/models/waste_model.dart';
import '../../../../../../../../core/shared/models/product_model.dart';
import '../../data/worker_repo.dart';
import '../worker_cubit/worker_cubit.dart';

part 'expenses_filter_state.dart';

class ExpensesFilterCubit extends Cubit<ExpensesFilterState> {
  final WorkerRepo _repo;
  final WorkerCubit _workerCubit;
  late final StreamSubscription _workerSubscription;

  ExpensesFilterCubit(this._repo, this._workerCubit)
    : super(ExpensesFilterInitial()) {
    filter();
    _workerSubscription = _workerCubit.stream.listen((state) {
      if (!editMode) {
        filter();
      }
    });
  }

  FinanceModel currentFilteredExpenses = FinanceModel(
    bakeryId: "",
    branchId: "",
    expenses: [],
    wastes: [],
  );
  FinanceModel editableCurrentFilteredExpenses = FinanceModel(
    bakeryId: "",
    branchId: "",
    expenses: [],
    wastes: [],
  );
  DateTime selectedDate = DateTime.now();
  int selectedDay = DateTime.now().day;
  int selectedMonth = DateTime.now().month;
  bool mealDeleted = true;
  bool isExpanded = true;
  bool editMode = false;
  bool updated = false;
  bool inputValidity = false;
  List<ExpensesModel> currentExpenses = [];
  List<ExpensesModel> editableExpenses = [];
  bool expenseStringValidity = false;
  bool expenseValueValidity = false;
  bool expenseUpdated = false;
  int expensesCounter = 0;

  void setExpensesUpdated(bool status) {
    expenseUpdated = status;
    emit(ExpensesFilterSuccess());
  }
  void setExpensesRowCount(int rows) {
    expensesCounter = rows > 0 ? rows - 1 : 0;
    emit(ExpensesFilterSuccess());
  }

  void addExpense({required ExpensesModel expense}) {
    editableExpenses.add(expense);
    expensesCounter = expensesCounter + 1;
    expenseUpdated = true;
    emit(ExpensesFilterSuccess());
  }

  void removeExpense({required int index}) {
    if (index >= 0 && index < editableExpenses.length) {
      editableExpenses.removeAt(index);
      expensesCounter = expensesCounter - 1;
      expenseUpdated = true;
      emit(ExpensesFilterSuccess());
    }
  }

  void textfieldMechanism({
    bool? expenseStringValidityStatus,
    bool? expenseValueValidityStatus,
  }) {
    if (expenseStringValidityStatus != null) {
      expenseStringValidity = expenseStringValidityStatus;
      if (expenseStringValidity && expenseValueValidity) {
        expenseStringValidity = false;
        expenseValueValidity = false;
        expensesCounter = expensesCounter + 1;
        emit(ExpensesFilterSuccess());
      }
    }
    if (expenseValueValidityStatus != null) {
      expenseValueValidity = expenseValueValidityStatus;
      if (expenseStringValidity && expenseValueValidity) {
        expenseStringValidity = false;
        expenseValueValidity = false;
        expensesCounter = expensesCounter + 1;
        emit(ExpensesFilterSuccess());
      }
    }
  }

  void setMealDeleted(bool status) {
    mealDeleted = status;
    emit(ExpensesFilterSuccess());
  }

  DateTime _clampedDate(int year, int month, int day) {
    final int lastDayOfMonth = DateTime(year, month + 1, 0).day;
    final int clampedDay = day > lastDayOfMonth ? lastDayOfMonth : day;
    return DateTime(year, month, clampedDay);
  }

  void filterByDay(int day) {
    selectedDay = day;
    filter(selectedDate: _clampedDate(selectedDate.year, selectedMonth, day));
  }

  void filterByMonth(int month) {
    selectedMonth = month;
    filter(selectedDate: _clampedDate(selectedDate.year, month, selectedDay));
  }
  void filter({DateTime? selectedDate}) {
    emit(ExpensesFilterLoading());
    this.selectedDate = selectedDate ?? this.selectedDate;
    final filterResult = _repo.filterExpensesByDate(
      allExpenses: _workerCubit.finance ?? [],
      selectedDate: this.selectedDate,
    );
    if (filterResult is SuccessResponse<FinanceModel?> &&
        filterResult.data != null) {
      currentFilteredExpenses = filterResult.data!;
      editableCurrentFilteredExpenses = currentFilteredExpenses;
    } else {
      currentFilteredExpenses = FinanceModel(
        bakeryId: currentFilteredExpenses.bakeryId,
        branchId: currentFilteredExpenses.branchId,
        expenses: [],
        wastes: [],
        date: this.selectedDate,
      );
      editableCurrentFilteredExpenses = currentFilteredExpenses;
    }
    currentExpenses = currentFilteredExpenses.expenses;
    editableExpenses = List.of(currentExpenses);
    expensesCounter = editableExpenses.length;
    expenseStringValidity = false;
    expenseValueValidity = false;
    expenseUpdated = false;
    emit(ExpensesFilterSuccess());
  }

  void changeEditMode() {
    editableCurrentFilteredExpenses = currentFilteredExpenses;
    editableExpenses = List.of(currentFilteredExpenses.expenses);
    expensesCounter = editableExpenses.length;
    editMode = !editMode;
    inputValidity = false;
    updated = false;
    mealDeleted = false;
    emit(ExpensesFilterSuccess());
  }

  void cancelChanges() {
    editableCurrentFilteredExpenses = currentFilteredExpenses;
    editableExpenses = List.of(currentFilteredExpenses.expenses);
    expensesCounter = editableExpenses.length;
    updated = false;
    editMode = false;
    inputValidity = false;
    mealDeleted = false;
    emit(ExpensesFilterSuccess());
  }

  void resetExpensesDraft() {
    editableExpenses = List.of(editableCurrentFilteredExpenses.expenses);
    expensesCounter = editableExpenses.length;
    expenseStringValidity = false;
    expenseValueValidity = false;
    expenseUpdated = false;
    emit(ExpensesFilterSuccess());
  }

  void applyExpensesDraft(List<ExpensesModel> items) {
    editableExpenses = List.of(items);
    expensesCounter = editableExpenses.length;
    expenseStringValidity = false;
    expenseValueValidity = false;
    expenseUpdated = false;
    editableCurrentFilteredExpenses = editableCurrentFilteredExpenses.copyWith(
      expenses: editableExpenses,
    );
    checkUpdate();
  }


  void checkUpdate() {
    updated =
        !ListEquality().equals(
          currentFilteredExpenses.expenses,
          editableCurrentFilteredExpenses.expenses,
        ) ||
        !ListEquality().equals(
          currentFilteredExpenses.wastes,
          editableCurrentFilteredExpenses.wastes,
        );
    emit(ExpensesFilterSuccess());
  }

  void setInputValidity(bool validity) {
    inputValidity = validity;
    emit(ExpensesFilterSuccess());
  }

  void updateTileExpansion(bool expanded) {
    isExpanded = expanded;
    emit(ExpensesFilterSuccess());
  }

  void changeSideExpenses(List<ExpensesModel> newExpenses) {
    editableCurrentFilteredExpenses = editableCurrentFilteredExpenses.copyWith(
      expenses: newExpenses,
    );
    inputValidity = false;
    checkUpdate();
  }

  void addAProduct({
    required ProductModel product,
    required int mealQuantity,
    required int notSoldQuantity,
    required int manufacturingQuantity,
  }) {
    final WasteModel newProduct = WasteModel(
      productId: product.productId!,
      productName: product.productName,
      meal: mealQuantity,
      notSold: notSoldQuantity,
      manufacturing: manufacturingQuantity,
      productPrice: product.productPrice,
      date: selectedDate,
    );

    final List<WasteModel> updatedwastes = List.from(
      editableCurrentFilteredExpenses.wastes,
    )..add(newProduct);

    editableCurrentFilteredExpenses = editableCurrentFilteredExpenses.copyWith(
      wastes: updatedwastes,
    );
    inputValidity = false;
    checkUpdate();
  }

  void removeAProduct({required String targetProductId}) {
    List<WasteModel> updatedList = List.from(
      editableCurrentFilteredExpenses.wastes,
    );
    updatedList.removeWhere((meal) => meal.productId == targetProductId);
    editableCurrentFilteredExpenses = editableCurrentFilteredExpenses.copyWith(
      wastes: updatedList,
    );
    checkUpdate();
  }

  void editMealQuantity({required String productId, required int newQuantity}) {
    final int productIndex = editableCurrentFilteredExpenses.wastes.indexWhere(
      (meal) => meal.productId == productId,
    );

    if (productIndex == -1) return;

    final List<WasteModel> updatedwastes = List.from(
      editableCurrentFilteredExpenses.wastes,
    );
    updatedwastes[productIndex] = updatedwastes[productIndex].copyWith(
      meal: newQuantity,
    );

    editableCurrentFilteredExpenses = editableCurrentFilteredExpenses.copyWith(
      wastes: updatedwastes,
    );
    inputValidity = false;
    checkUpdate();
  }

  void editManufacturingQuantity({
    required String productId,
    required int newQuantity,
  }) {
    final int productIndex = editableCurrentFilteredExpenses.wastes.indexWhere(
      (meal) => meal.productId == productId,
    );

    if (productIndex == -1) return;

    final List<WasteModel> updatedwastes = List.from(
      editableCurrentFilteredExpenses.wastes,
    );
    updatedwastes[productIndex] = updatedwastes[productIndex].copyWith(
      manufacturing: newQuantity,
    );

    editableCurrentFilteredExpenses = editableCurrentFilteredExpenses.copyWith(
      wastes: updatedwastes,
    );
    inputValidity = false;
    checkUpdate();
  }

  void editNotSoldQuantity({
    required String productId,
    required int newQuantity,
  }) {
    final int productIndex = editableCurrentFilteredExpenses.wastes.indexWhere(
      (meal) => meal.productId == productId,
    );

    if (productIndex == -1) return;

    final List<WasteModel> updatedwastes = List.from(
      editableCurrentFilteredExpenses.wastes,
    );
    updatedwastes[productIndex] = updatedwastes[productIndex].copyWith(
      notSold: newQuantity,
    );

    editableCurrentFilteredExpenses = editableCurrentFilteredExpenses.copyWith(
      wastes: updatedwastes,
    );
    inputValidity = false;
    checkUpdate();
  }

  @override
  Future<void> close() {
    _workerSubscription.cancel();
    return super.close();
  }
}
