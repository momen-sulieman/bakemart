import 'dart:async';

import 'package:bakemart/core/network/response_result.dart';
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
    cleaningExpenses: 0,
    wastes: [],
  );
  FinanceModel editableCurrentFilteredExpenses = FinanceModel(
    bakeryId: "",
    cleaningExpenses: 0,
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

  void setMealDeleted(bool status){
    mealDeleted=status;
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
        cleaningExpenses: 0,
        wastes: [],
        date: this.selectedDate,
      );
      editableCurrentFilteredExpenses = currentFilteredExpenses;
    }
    emit(ExpensesFilterSuccess());
  }

  void checkUpdate() {
    updated =
        currentFilteredExpenses.cleaningExpenses !=
            editableCurrentFilteredExpenses.cleaningExpenses ||
            !ListEquality().equals(
              currentFilteredExpenses.wastes,
              editableCurrentFilteredExpenses.wastes,
            );
    emit(ExpensesFilterSuccess());
  }

  void changeEditMode() {
    editableCurrentFilteredExpenses = currentFilteredExpenses;
    editMode = !editMode;
    inputValidity = false;
    updated = false;
    mealDeleted=false;
    emit(ExpensesFilterSuccess());
  }

  void cancelChanges() {
    editableCurrentFilteredExpenses = currentFilteredExpenses;
    updated = false;
    editMode = false;
    inputValidity = false;
    mealDeleted=false;
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

  void changeSideExpenses(double newValue) {
    editableCurrentFilteredExpenses = editableCurrentFilteredExpenses.copyWith(
      cleaningExpenses: newValue,
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