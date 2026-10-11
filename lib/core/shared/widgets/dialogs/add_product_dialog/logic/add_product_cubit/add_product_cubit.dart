import 'dart:io';

import 'package:bakemart/core/dependency_injection/dependency_injection.dart';
import 'package:bakemart/core/shared/models/product_model.dart';
import 'package:bakemart/core/shared/models/recipe_model.dart';
import 'package:bakemart/core/shared/widgets/supabase_image/logic/supabase_image_cubit/supabase_image_cubit.dart';
import 'package:bakemart/core/utils/enums/buckts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../../../utils/enums/storage_items.dart';
import '../../../../../../utils/extensions/string_extension.dart';


part 'add_product_state.dart';

typedef RecipeFieldDescriptor = (
String label,
TextEditingController controller,
String unit,
RecipeModel Function(RecipeModel recipe, int? value) apply,
);

class AddProductCubit extends Cubit<AddProductState> {
  AddProductCubit({
    required this.bakeryId,
    required this.flourTypes,
    required this.onSave,
    this.initialFlourIndex = 1,
  })  : flourType = flourTypes[initialFlourIndex],
        imageCubit = DependencyInjection.getIt<SupabaseImageCubit>(
          param1: Buckets.productsImages,
          param2: null,
        ),
        super(AddProductState(isValid: false)) {
    recipeFields = [
      (StorageItems.yeast, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(yeast: v)),
      (StorageItems.salt, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(salt: v)),
      (StorageItems.sugar, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(sugar: v)),
      (StorageItems.eggs, TextEditingController(), "egg".tr(), (r, v) => r.copyWith(eggs: v)),
      (StorageItems.ghee, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(ghee: v)),
      (StorageItems.oil, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(oil: v)),
      (StorageItems.butter, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(butter: v)),
      (StorageItems.sesame, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(sesame: v)),
      (StorageItems.blackSeeds, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(blackSeeds: v)),
      (StorageItems.fennel, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(fennel: v)),
      (StorageItems.anise, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(anise: v)),
      (StorageItems.mahlab, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(mahlab: v)),
      (StorageItems.cinnamon, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(cinnamon: v)),
      (StorageItems.bakingPowder, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(bakingPowder: v)),
      (StorageItems.bakingSoda, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(bakingSoda: v)),
      (StorageItems.chocolate, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(chocolate: v)),
      (StorageItems.conditioner, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(conditioner: v)),
      (StorageItems.vanilla, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(vanilla: v)),
      (StorageItems.milk, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(milk: v)),
      (StorageItems.milkPowder, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(milkPowder: v)),
      (StorageItems.whippingCream, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(whippingCream: v)),
      (StorageItems.condensedMilk, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(condensedMilk: v)),
      (StorageItems.datePaste, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(datePaste: v)),
      (StorageItems.malban, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(malban: v)),
      (StorageItems.custard, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(custard: v)),
      (StorageItems.cocoa, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(cocoa: v)),
      (StorageItems.coconutPowder, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(coconutPowder: v)),
      (StorageItems.blackMolasses, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(blackMolasses: v)),
      (StorageItems.whiteCheese, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(whiteCheese: v)),
      (StorageItems.roumyCheese, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(roumyCheese: v)),
      (StorageItems.istanbouliCheese, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(istanbouliCheese: v)),
      (StorageItems.mozzarella, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(mozzarella: v)),
      (StorageItems.olives, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(olives: v)),
      (StorageItems.peanut, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(peanut: v)),
      (StorageItems.cashew, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(cashew: v)),
      (StorageItems.almond, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(almond: v)),
      (StorageItems.pistachio, TextEditingController(), "gram".tr(), (r, v) => r.copyWith(pistachio: v)),
    ];
  }

  final String bakeryId;
  final List<String> flourTypes;
  final int initialFlourIndex;
  final void Function(ProductModel product, File? image) onSave;

  final String generatedId = const Uuid().v4();
  final SupabaseImageCubit imageCubit;
  String flourType;

  final productNameController = TextEditingController();
  final productPriceController = TextEditingController();
  final productWeightController = TextEditingController();
  final quantityController = TextEditingController();
  late final List<RecipeFieldDescriptor> recipeFields;

  void setFlourType(String type) {
    flourType = type;
  }

  void revalidate() {
    final coreFieldsFilled = productNameController.text.isNotEmpty &&
        productPriceController.text.isNotEmpty &&
        productWeightController.text.isNotEmpty &&
        quantityController.text.isNotEmpty;
    final atLeastOneRecipeItemFilled =
    recipeFields.any((field) => field.$2.text.isNotEmpty);
    final isValid = coreFieldsFilled && atLeastOneRecipeItemFilled;
    if (isValid != state.isValid) {
      emit(AddProductState(isValid: isValid));
    }
  }

  void save() {
    RecipeModel recipe = RecipeModel(
      bakeryId: bakeryId,
      productId: generatedId,
      flourType: flourType,
    );
    for (final field in recipeFields) {
      recipe = field.$4(recipe, int.tryParse(field.$2.text.toEnglishDigits()));
    }

    final product = ProductModel(
      bakeryId: bakeryId,
      productName: "",
      productWeight: 0,
      productPrice: 0,
      productRecipe: recipe,
      quantityPerBatch: 0,
      yesterdayProduced: 0,
      yesterdaySold: 0,
      totalProduced: 0,
      totalSold: 0,
      notSoldWaste: 0,
      manufacturingWaste: 0,
      mealsWaste: 0,
      available: 0,
    ).copyWith(
      productId: generatedId,
      bakeryId: bakeryId,
      productName: productNameController.text.capitalize(),
      productPrice: double.tryParse(productPriceController.text.toEnglishDigits()),
      productWeight: int.tryParse(productWeightController.text.toEnglishDigits()),
      quantityPerBatch: int.tryParse(quantityController.text.toEnglishDigits()),
      productRecipe: recipe,
    );

    final imageState = imageCubit.state;
    onSave(product, imageState is ImagePicked ? imageState.imageFile : null);
  }

  @override
  Future<void> close() {
    productNameController.dispose();
    productPriceController.dispose();
    productWeightController.dispose();
    quantityController.dispose();
    for (final field in recipeFields) {
      field.$2.dispose();
    }
    imageCubit.close();
    return super.close();
  }
}