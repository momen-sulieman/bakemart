import 'package:bakemart/core/shared/models/recipe_model.dart';
import 'package:bakemart/core/shared/models/storage_helper.dart';
import 'package:bakemart/core/shared/models/storage_model.dart';
import 'package:bakemart/core/utils/enums/storage_items.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  RecipeModel recipe({
    String flourType = StorageItems.fineWheat,
    int? oil,
    int? yeast,
  }) {
    return RecipeModel(
      bakeryId: 'b1',
      flourType: flourType,
      oil: oil,
      yeast: yeast,
    );
  }

  group('deductRecipeFromStorage', () {
    test('deducts flour based on batches times the base deduction', () {
      final storage = StorageModel(bakeryId: 'b1', fineWheat: 200000, branchId: '');

      final updated = StorageHelper.deductRecipeFromStorage(
        currentStorage: storage,
        recipe: recipe(),
        numberOfBatches: 2,
      );

      expect(updated.fineWheat, 100000);
    });

    test('clamps flour deduction at zero instead of going negative', () {
      final storage = StorageModel(bakeryId: 'b1', fineWheat: 10000, branchId: '');

      final updated = StorageHelper.deductRecipeFromStorage(
        currentStorage: storage,
        recipe: recipe(),
        numberOfBatches: 1,
      );

      expect(updated.fineWheat, 0);
    });

    test('treats null flour storage as zero after deduction', () {
      final storage = StorageModel(bakeryId: 'b1', branchId: '');

      final updated = StorageHelper.deductRecipeFromStorage(
        currentStorage: storage,
        recipe: recipe(),
        numberOfBatches: 1,
      );

      expect(updated.fineWheat, 0);
    });

    test('deducts from the matching flour type only', () {
      final storage = StorageModel(
        bakeryId: 'b1',
        fineWheat: 200000,
        wholeWheat: 200000, branchId: '',
      );

      final updated = StorageHelper.deductRecipeFromStorage(
        currentStorage: storage,
        recipe: recipe(flourType: StorageItems.wholeWheat),
        numberOfBatches: 1,
      );

      expect(updated.fineWheat, 200000);
      expect(updated.wholeWheat, 150000);
    });

    test('falls back to fine wheat for an unknown flour type', () {
      final storage = StorageModel(bakeryId: 'b1', fineWheat: 200000, branchId: '');

      final updated = StorageHelper.deductRecipeFromStorage(
        currentStorage: storage,
        recipe: recipe(flourType: 'unknown'),
        numberOfBatches: 1,
      );

      expect(updated.fineWheat, 150000);
    });

    test('multiplies non-flour ingredients by the batch count', () {
      final storage = StorageModel(bakeryId: 'b1', oil: 1000, branchId: '');

      final updated = StorageHelper.deductRecipeFromStorage(
        currentStorage: storage,
        recipe: recipe(oil: 100),
        numberOfBatches: 3,
      );

      expect(updated.oil, 700);
    });

    test('skips ingredients the recipe does not use', () {
      final storage = StorageModel(bakeryId: 'b1', yeast: 500, branchId: '');

      final updated = StorageHelper.deductRecipeFromStorage(
        currentStorage: storage,
        recipe: recipe(),
        numberOfBatches: 1,
      );

      expect(updated.yeast, 500);
    });

    test('clamps a non-flour ingredient at zero', () {
      final storage = StorageModel(bakeryId: 'b1', yeast: 5, branchId: '');

      final updated = StorageHelper.deductRecipeFromStorage(
        currentStorage: storage,
        recipe: recipe(yeast: 100),
        numberOfBatches: 1,
      );

      expect(updated.yeast, 0);
    });
  });

  group('getItemValue / updateItemValue', () {
    test('getItemValue reads the right field and defaults to 0', () {
      final storage = StorageModel(bakeryId: 'b1', sugar: 50, branchId: '');

      expect(StorageHelper.getItemValue(storage, StorageItems.sugar), 50);
      expect(StorageHelper.getItemValue(storage, StorageItems.salt), 0);
      expect(StorageHelper.getItemValue(storage, 'unknown'), 0);
    });

    test('updateItemValue adds to the existing amount', () {
      final storage = StorageModel(bakeryId: 'b1', sugar: 50, branchId: '');

      final updated = StorageHelper.updateItemValue(
        storage,
        StorageItems.sugar,
        20,
      );

      expect(updated.sugar, 70);
    });

    test('updateItemValue on an unknown item returns storage unchanged', () {
      final storage = StorageModel(bakeryId: 'b1', branchId: '');

      final updated = StorageHelper.updateItemValue(storage, 'unknown', 20);

      expect(updated, same(storage));
    });
  });

  test('isWheat is true only for fine and whole wheat', () {
    expect(StorageHelper.isWheat(StorageItems.fineWheat), true);
    expect(StorageHelper.isWheat(StorageItems.wholeWheat), true);
    expect(StorageHelper.isWheat(StorageItems.corn), false);
  });
}