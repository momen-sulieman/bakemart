import '../../../../../../../core/shared/models/recipe_model.dart';
import '../../../../../../../core/shared/models/storage_model.dart';
import '../../../../../../../core/utils/constants/constant_images.dart';
import '../../../../../../../core/utils/enums/storage_items.dart';

class StorageHelper {
  static const int baseFlourDeduction = 50000;

  static const List<String> allItems = [
    StorageItems.fineWheat,
    StorageItems.wholeWheat,
    StorageItems.corn,
    StorageItems.oats,
    StorageItems.barley,
    StorageItems.semolina,
    StorageItems.phyllo,
    StorageItems.yeast,
    StorageItems.salt,
    StorageItems.sugar,
    StorageItems.eggs,
    StorageItems.ghee,
    StorageItems.oil,
    StorageItems.butter,
    StorageItems.sesame,
    StorageItems.blackSeeds,
    StorageItems.fennel,
    StorageItems.anise,
    StorageItems.mahlab,
    StorageItems.cinnamon,
    StorageItems.bakingPowder,
    StorageItems.bakingSoda,
    StorageItems.conditioner,
    StorageItems.vanilla,
    StorageItems.milk,
    StorageItems.milkPowder,
    StorageItems.whippingCream,
    StorageItems.condensedMilk,
    StorageItems.chocolate,
    StorageItems.datePaste,
    StorageItems.malban,
    StorageItems.custard,
    StorageItems.cocoa,
    StorageItems.coconutPowder,
    StorageItems.blackMolasses,
    StorageItems.whiteCheese,
    StorageItems.roumyCheese,
    StorageItems.istanbouliCheese,
    StorageItems.mozzarella,
    StorageItems.olives,
    StorageItems.peanut,
    StorageItems.cashew,
    StorageItems.almond,
    StorageItems.pistachio,
  ];

  static StorageModel deductRecipeFromStorage({
    required StorageModel currentStorage,
    required RecipeModel recipe,
    required int numberOfBatches,
  }) {
    int? subtract(int? current, int? recipeAmount) {
      if (recipeAmount == null || recipeAmount <= 0) return current;
      if (current == null) return 0;
      final totalDeduction = recipeAmount * numberOfBatches;
      final result = current - totalDeduction;
      return result < 0 ? 0 : result;
    }

    final int totalFlourDeduction = numberOfBatches * baseFlourDeduction;

    int? updatedFineWheat = currentStorage.fineWheat;
    int? updatedWholeWheat = currentStorage.wholeWheat;
    int? updatedCorn = currentStorage.corn;
    int? updatedOats = currentStorage.oats;
    int? updatedBarley = currentStorage.barley;
    int? updatedSemolina = currentStorage.semolina;
    int? updatedPhyllo = currentStorage.phyllo;

    final flour = recipe.flourType.trim();

    switch (flour) {
      case StorageItems.fineWheat:
        updatedFineWheat = (currentStorage.fineWheat != null)
            ? ((currentStorage.fineWheat! - totalFlourDeduction) < 0
            ? 0
            : currentStorage.fineWheat! - totalFlourDeduction)
            : 0;
        break;
      case StorageItems.wholeWheat:
        updatedWholeWheat = (currentStorage.wholeWheat != null)
            ? ((currentStorage.wholeWheat! - totalFlourDeduction) < 0
            ? 0
            : currentStorage.wholeWheat! - totalFlourDeduction)
            : 0;
        break;
      case StorageItems.corn:
        updatedCorn = (currentStorage.corn != null)
            ? ((currentStorage.corn! - totalFlourDeduction) < 0
            ? 0
            : currentStorage.corn! - totalFlourDeduction)
            : 0;
        break;
      case StorageItems.oats:
        updatedOats = (currentStorage.oats != null)
            ? ((currentStorage.oats! - totalFlourDeduction) < 0
            ? 0
            : currentStorage.oats! - totalFlourDeduction)
            : 0;
        break;
      case StorageItems.barley:
        updatedBarley = (currentStorage.barley != null)
            ? ((currentStorage.barley! - totalFlourDeduction) < 0
            ? 0
            : currentStorage.barley! - totalFlourDeduction)
            : 0;
        break;
      case StorageItems.semolina:
        updatedSemolina = (currentStorage.semolina != null)
            ? ((currentStorage.semolina! - totalFlourDeduction) < 0
            ? 0
            : currentStorage.semolina! - totalFlourDeduction)
            : 0;
        break;
      case StorageItems.phyllo:
        updatedPhyllo = (currentStorage.phyllo != null)
            ? ((currentStorage.phyllo! - totalFlourDeduction) < 0
            ? 0
            : currentStorage.phyllo! - totalFlourDeduction)
            : 0;
        break;
      default:
        updatedFineWheat = (currentStorage.fineWheat != null)
            ? ((currentStorage.fineWheat! - totalFlourDeduction) < 0
            ? 0
            : currentStorage.fineWheat! - totalFlourDeduction)
            : 0;
        break;
    }

    return currentStorage.copyWith(
      fineWheat: updatedFineWheat,
      wholeWheat: updatedWholeWheat,
      corn: updatedCorn,
      oats: updatedOats,
      barley: updatedBarley,
      semolina: updatedSemolina,
      phyllo: updatedPhyllo,

      yeast: subtract(currentStorage.yeast, recipe.yeast),
      salt: subtract(currentStorage.salt, recipe.salt),
      sugar: subtract(currentStorage.sugar, recipe.sugar),
      eggs: subtract(currentStorage.eggs, recipe.eggs),
      ghee: subtract(currentStorage.ghee, recipe.ghee),
      oil: subtract(currentStorage.oil, recipe.oil),
      butter: subtract(currentStorage.butter, recipe.butter),
      sesame: subtract(currentStorage.sesame, recipe.sesame),
      blackSeeds: subtract(currentStorage.blackSeeds, recipe.blackSeeds),
      fennel: subtract(currentStorage.fennel, recipe.fennel),
      anise: subtract(currentStorage.anise, recipe.anise),
      mahlab: subtract(currentStorage.mahlab, recipe.mahlab),
      cinnamon: subtract(currentStorage.cinnamon, recipe.cinnamon),
      bakingPowder: subtract(currentStorage.bakingPowder, recipe.bakingPowder),
      bakingSoda: subtract(currentStorage.bakingSoda, recipe.bakingSoda),
      conditioner: subtract(currentStorage.conditioner, recipe.conditioner),
      vanilla: subtract(currentStorage.vanilla, recipe.vanilla),
      milk: subtract(currentStorage.milk, recipe.milk),
      milkPowder: subtract(currentStorage.milkPowder, recipe.milkPowder),
      whippingCream: subtract(currentStorage.whippingCream, recipe.whippingCream),
      condensedMilk: subtract(currentStorage.condensedMilk, recipe.condensedMilk),
      chocolate: subtract(currentStorage.chocolate, recipe.chocolate),
      datePaste: subtract(currentStorage.datePaste, recipe.datePaste),
      malban: subtract(currentStorage.malban, recipe.malban),
      whiteCheese: subtract(currentStorage.whiteCheese, recipe.whiteCheese),
      roumyCheese: subtract(currentStorage.roumyCheese, recipe.roumyCheese),
      istanbouliCheese: subtract(currentStorage.istanbouliCheese, recipe.istanbouliCheese),
      mozzarella: subtract(currentStorage.mozzarella, recipe.mozzarella),
      olives: subtract(currentStorage.olives, recipe.olives),
      peanut: subtract(currentStorage.peanut, recipe.peanut),
      cashew: subtract(currentStorage.cashew, recipe.cashew),
      almond: subtract(currentStorage.almond, recipe.almond),
      pistachio: subtract(currentStorage.pistachio, recipe.pistachio),
      custard: subtract(currentStorage.custard, recipe.custard),
      cocoa: subtract(currentStorage.cocoa, recipe.cocoa),
      coconutPowder: subtract(currentStorage.coconutPowder, recipe.coconutPowder),
      blackMolasses: subtract(currentStorage.blackMolasses, recipe.blackMolasses),
    );
  }

  static int getItemValue(StorageModel storage, String itemName) {
    switch (itemName) {
      case StorageItems.fineWheat: return storage.fineWheat ?? 0;
      case StorageItems.wholeWheat: return storage.wholeWheat ?? 0;
      case StorageItems.corn: return storage.corn ?? 0;
      case StorageItems.oats: return storage.oats ?? 0;
      case StorageItems.barley: return storage.barley ?? 0;
      case StorageItems.semolina: return storage.semolina ?? 0;
      case StorageItems.phyllo: return storage.phyllo ?? 0;
      case StorageItems.yeast: return storage.yeast ?? 0;
      case StorageItems.salt: return storage.salt ?? 0;
      case StorageItems.sugar: return storage.sugar ?? 0;
      case StorageItems.eggs: return storage.eggs ?? 0;
      case StorageItems.ghee: return storage.ghee ?? 0;
      case StorageItems.oil: return storage.oil ?? 0;
      case StorageItems.butter: return storage.butter ?? 0;
      case StorageItems.sesame: return storage.sesame ?? 0;
      case StorageItems.blackSeeds: return storage.blackSeeds ?? 0;
      case StorageItems.fennel: return storage.fennel ?? 0;
      case StorageItems.anise: return storage.anise ?? 0;
      case StorageItems.mahlab: return storage.mahlab ?? 0;
      case StorageItems.cinnamon: return storage.cinnamon ?? 0;
      case StorageItems.bakingPowder: return storage.bakingPowder ?? 0;
      case StorageItems.bakingSoda: return storage.bakingSoda ?? 0;
      case StorageItems.conditioner: return storage.conditioner ?? 0;
      case StorageItems.vanilla: return storage.vanilla ?? 0;
      case StorageItems.milk: return storage.milk ?? 0;
      case StorageItems.milkPowder: return storage.milkPowder ?? 0;
      case StorageItems.whippingCream: return storage.whippingCream ?? 0;
      case StorageItems.condensedMilk: return storage.condensedMilk ?? 0;
      case StorageItems.chocolate: return storage.chocolate ?? 0;
      case StorageItems.datePaste: return storage.datePaste ?? 0;
      case StorageItems.malban: return storage.malban ?? 0;
      case StorageItems.whiteCheese: return storage.whiteCheese ?? 0;
      case StorageItems.roumyCheese: return storage.roumyCheese ?? 0;
      case StorageItems.istanbouliCheese: return storage.istanbouliCheese ?? 0;
      case StorageItems.mozzarella: return storage.mozzarella ?? 0;
      case StorageItems.olives: return storage.olives ?? 0;
      case StorageItems.peanut: return storage.peanut ?? 0;
      case StorageItems.cashew: return storage.cashew ?? 0;
      case StorageItems.almond: return storage.almond ?? 0;
      case StorageItems.pistachio: return storage.pistachio ?? 0;
      case StorageItems.custard: return storage.custard ?? 0;
      case StorageItems.cocoa: return storage.cocoa ?? 0;
      case StorageItems.coconutPowder: return storage.coconutPowder ?? 0;
      case StorageItems.blackMolasses: return storage.blackMolasses ?? 0;
      default: return 0;
    }
  }

  static StorageModel updateItemValue(StorageModel storage, String itemName, int addedAmount) {
    final currentValue = getItemValue(storage, itemName);
    final newValue = currentValue + addedAmount;

    switch (itemName) {
      case StorageItems.fineWheat: return storage.copyWith(fineWheat: newValue);
      case StorageItems.wholeWheat: return storage.copyWith(wholeWheat: newValue);
      case StorageItems.corn: return storage.copyWith(corn: newValue);
      case StorageItems.oats: return storage.copyWith(oats: newValue);
      case StorageItems.barley: return storage.copyWith(barley: newValue);
      case StorageItems.semolina: return storage.copyWith(semolina: newValue);
      case StorageItems.phyllo: return storage.copyWith(phyllo: newValue);
      case StorageItems.yeast: return storage.copyWith(yeast: newValue);
      case StorageItems.salt: return storage.copyWith(salt: newValue);
      case StorageItems.sugar: return storage.copyWith(sugar: newValue);
      case StorageItems.eggs: return storage.copyWith(eggs: newValue);
      case StorageItems.ghee: return storage.copyWith(ghee: newValue);
      case StorageItems.oil: return storage.copyWith(oil: newValue);
      case StorageItems.butter: return storage.copyWith(butter: newValue);
      case StorageItems.sesame: return storage.copyWith(sesame: newValue);
      case StorageItems.blackSeeds: return storage.copyWith(blackSeeds: newValue);
      case StorageItems.fennel: return storage.copyWith(fennel: newValue);
      case StorageItems.anise: return storage.copyWith(anise: newValue);
      case StorageItems.mahlab: return storage.copyWith(mahlab: newValue);
      case StorageItems.cinnamon: return storage.copyWith(cinnamon: newValue);
      case StorageItems.bakingPowder: return storage.copyWith(bakingPowder: newValue);
      case StorageItems.bakingSoda: return storage.copyWith(bakingSoda: newValue);
      case StorageItems.conditioner: return storage.copyWith(conditioner: newValue);
      case StorageItems.vanilla: return storage.copyWith(vanilla: newValue);
      case StorageItems.milk: return storage.copyWith(milk: newValue);
      case StorageItems.milkPowder: return storage.copyWith(milkPowder: newValue);
      case StorageItems.whippingCream: return storage.copyWith(whippingCream: newValue);
      case StorageItems.condensedMilk: return storage.copyWith(condensedMilk: newValue);
      case StorageItems.chocolate: return storage.copyWith(chocolate: newValue);
      case StorageItems.datePaste: return storage.copyWith(datePaste: newValue);
      case StorageItems.malban: return storage.copyWith(malban: newValue);
      case StorageItems.whiteCheese: return storage.copyWith(whiteCheese: newValue);
      case StorageItems.roumyCheese: return storage.copyWith(roumyCheese: newValue);
      case StorageItems.istanbouliCheese: return storage.copyWith(istanbouliCheese: newValue);
      case StorageItems.mozzarella: return storage.copyWith(mozzarella: newValue);
      case StorageItems.olives: return storage.copyWith(olives: newValue);
      case StorageItems.peanut: return storage.copyWith(peanut: newValue);
      case StorageItems.cashew: return storage.copyWith(cashew: newValue);
      case StorageItems.almond: return storage.copyWith(almond: newValue);
      case StorageItems.pistachio: return storage.copyWith(pistachio: newValue);
      case StorageItems.custard: return storage.copyWith(custard: newValue);
      case StorageItems.cocoa: return storage.copyWith(cocoa: newValue);
      case StorageItems.coconutPowder: return storage.copyWith(coconutPowder: newValue);
      case StorageItems.blackMolasses: return storage.copyWith(blackMolasses: newValue);
      default: return storage;
    }
  }

  static String getItemImage(String itemName) {
    switch (itemName) {
      case StorageItems.fineWheat: return ConstantImages.fineWheat;
      case StorageItems.wholeWheat: return ConstantImages.wholeWheat;
      case StorageItems.barley: return ConstantImages.barley;
      case StorageItems.semolina: return ConstantImages.semolina;
      case StorageItems.phyllo: return ConstantImages.phylloDough;
      case StorageItems.corn: return ConstantImages.corn;
      case StorageItems.oats: return ConstantImages.oats;
      case StorageItems.yeast: return ConstantImages.yeast;
      case StorageItems.sugar: return ConstantImages.sugar;
      case StorageItems.salt: return ConstantImages.salt;
      case StorageItems.eggs: return ConstantImages.egg;
      case StorageItems.oil: return ConstantImages.oil;
      case StorageItems.ghee: return ConstantImages.ghee;
      case StorageItems.butter: return ConstantImages.butter;
      case StorageItems.sesame: return ConstantImages.sesame;
      case StorageItems.blackSeeds: return ConstantImages.blackSeeds;
      case StorageItems.fennel: return ConstantImages.fennel;
      case StorageItems.anise: return ConstantImages.anise;
      case StorageItems.mahlab: return ConstantImages.mahlab;
      case StorageItems.cinnamon: return ConstantImages.cinnamon;
      case StorageItems.chocolate: return ConstantImages.chocolate;
      case StorageItems.cashew: return ConstantImages.cashews;
      case StorageItems.pistachio: return ConstantImages.pistachios;
      case StorageItems.peanut: return ConstantImages.peanuts;
      case StorageItems.almond: return ConstantImages.almond;
      case StorageItems.olives: return ConstantImages.olive;
      case StorageItems.blackMolasses: return ConstantImages.blackMolasses;
      case StorageItems.whiteCheese: return ConstantImages.whiteCheese;
      case StorageItems.roumyCheese: return ConstantImages.roumyCheese;
      case StorageItems.istanbouliCheese: return ConstantImages.istanbouliCheese;
      case StorageItems.milk: return ConstantImages.milk;
      case StorageItems.vanilla: return ConstantImages.vanilla;
      case StorageItems.datePaste: return ConstantImages.datePaste;
      case StorageItems.mozzarella: return ConstantImages.mozzarella;
      case StorageItems.milkPowder: return ConstantImages.milkPowder;
      case StorageItems.whippingCream: return ConstantImages.whippingCream;
      case StorageItems.condensedMilk: return ConstantImages.condensedMilk;
      case StorageItems.malban: return ConstantImages.malban;
      case StorageItems.custard: return ConstantImages.custard;
      case StorageItems.cocoa: return ConstantImages.cocoaPowder;
      case StorageItems.coconutPowder: return ConstantImages.coconutPowder;
      default: return ConstantImages.powder;
    }
  }

  static bool isWheat(String itemName) {
    return itemName == StorageItems.fineWheat ||
        itemName == StorageItems.wholeWheat;
  }
}