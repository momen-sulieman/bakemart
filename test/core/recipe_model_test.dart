import 'package:bakemart/core/shared/models/recipe_model.dart';
import 'package:bakemart/core/utils/enums/recipes_table_columns.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  RecipeModel recipe({String? productId}) {
    return RecipeModel(
      bakeryId: 'b1',
      productId: productId,
      flourType: 'white',
      yeast: 5,
      oil: 100,
      ghee: 50,
      butter: 25,
      pistachio: 10,
    );
  }

  test('fromJson falls back to defaults on an empty map', () {
    final parsed = RecipeModel.fromJson({});

    expect(parsed.bakeryId, '');
    expect(parsed.flourType, '');
    expect(parsed.productId, isNull);
    expect(parsed.yeast, isNull);
    expect(parsed.pistachio, isNull);
  });

  test('fromJson converts numeric ingredients to ints', () {
    final parsed = RecipeModel.fromJson({
      RecipesTableColumns.bakeryId: 'b1',
      RecipesTableColumns.flourType: 'brown',
      RecipesTableColumns.oil: 12.0,
      RecipesTableColumns.sugar: 3,
    });

    expect(parsed.flourType, 'brown');
    expect(parsed.oil, 12);
    expect(parsed.sugar, 3);
  });

  test('toJson omits a null or empty product id', () {
    expect(
      recipe().toJson().containsKey(RecipesTableColumns.productId),
      false,
    );
    expect(
      recipe(productId: '').toJson().containsKey(RecipesTableColumns.productId),
      false,
    );
    expect(
      recipe(productId: 'p1').toJson()[RecipesTableColumns.productId],
      'p1',
    );
  });

  test('round trips through json', () {
    final original = recipe(productId: 'p1');

    final parsed = RecipeModel.fromJson(original.toJson());

    expect(parsed, original);
    expect(parsed.hashCode, original.hashCode);
  });

  test('copyWith changes only the given field', () {
    final original = recipe(productId: 'p1');

    final copy = original.copyWith(oil: 999);

    expect(copy.oil, 999);
    expect(copy.ghee, 50);
    expect(copy.bakeryId, 'b1');
    expect(copy, isNot(original));
  });

  test('equality is field based', () {
    expect(recipe(productId: 'p1'), recipe(productId: 'p1'));
    expect(recipe(productId: 'p1'), isNot(recipe(productId: 'p2')));
  });
}