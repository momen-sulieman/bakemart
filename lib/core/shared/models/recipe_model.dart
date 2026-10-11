import '../../utils/enums/recipes_table_columns.dart';

class RecipeModel {
  final String bakeryId;
  final String? productId;
  final String flourType;
  final int? yeast;
  final int? salt;
  final int? sugar;
  final int? eggs;
  final int? ghee;
  final int? oil;
  final int? butter;
  final int? sesame;
  final int? blackSeeds;
  final int? fennel;
  final int? anise;
  final int? mahlab;
  final int? cinnamon;
  final int? bakingPowder;
  final int? bakingSoda;
  final int? chocolate;
  final int? conditioner;
  final int? vanilla;
  final int? milk;
  final int? milkPowder;
  final int? whippingCream;
  final int? condensedMilk;
  final int? datePaste;
  final int? malban;
  final int? custard;
  final int? cocoa;
  final int? coconutPowder;
  final int? blackMolasses;
  final int? whiteCheese;
  final int? roumyCheese;
  final int? istanbouliCheese;
  final int? mozzarella;
  final int? olives;
  final int? peanut;
  final int? cashew;
  final int? almond;
  final int? pistachio;

  RecipeModel({
    required this.bakeryId,
    this.productId,
    required this.flourType,
    this.yeast,
    this.salt,
    this.sugar,
    this.eggs,
    this.ghee,
    this.oil,
    this.butter,
    this.sesame,
    this.blackSeeds,
    this.fennel,
    this.anise,
    this.mahlab,
    this.cinnamon,
    this.bakingPowder,
    this.bakingSoda,
    this.chocolate,
    this.conditioner,
    this.vanilla,
    this.milk,
    this.milkPowder,
    this.whippingCream,
    this.condensedMilk,
    this.datePaste,
    this.malban,
    this.custard,
    this.cocoa,
    this.coconutPowder,
    this.blackMolasses,
    this.whiteCheese,
    this.roumyCheese,
    this.istanbouliCheese,
    this.mozzarella,
    this.olives,
    this.peanut,
    this.cashew,
    this.almond,
    this.pistachio,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      bakeryId: json[RecipesTableColumns.bakeryId] as String? ?? '',
      productId: json[RecipesTableColumns.productId] as String?,
      flourType: json[RecipesTableColumns.flourType] as String? ?? '',
      yeast: (json[RecipesTableColumns.yeast] as num?)?.toInt(),
      salt: (json[RecipesTableColumns.salt] as num?)?.toInt(),
      sugar: (json[RecipesTableColumns.sugar] as num?)?.toInt(),
      eggs: (json[RecipesTableColumns.eggs] as num?)?.toInt(),
      ghee: (json[RecipesTableColumns.ghee] as num?)?.toInt(),
      oil: (json[RecipesTableColumns.oil] as num?)?.toInt(),
      butter: (json[RecipesTableColumns.butter] as num?)?.toInt(),
      sesame: (json[RecipesTableColumns.sesame] as num?)?.toInt(),
      blackSeeds: (json[RecipesTableColumns.blackSeeds] as num?)?.toInt(),
      fennel: (json[RecipesTableColumns.fennel] as num?)?.toInt(),
      anise: (json[RecipesTableColumns.anise] as num?)?.toInt(),
      mahlab: (json[RecipesTableColumns.mahlab] as num?)?.toInt(),
      cinnamon: (json[RecipesTableColumns.cinnamon] as num?)?.toInt(),
      bakingPowder: (json[RecipesTableColumns.bakingPowder] as num?)?.toInt(),
      bakingSoda: (json[RecipesTableColumns.bakingSoda] as num?)?.toInt(),
      chocolate: (json[RecipesTableColumns.chocolate] as num?)?.toInt(),
      conditioner: (json[RecipesTableColumns.conditioner] as num?)?.toInt(),
      vanilla: (json[RecipesTableColumns.vanilla] as num?)?.toInt(),
      milk: (json[RecipesTableColumns.milk] as num?)?.toInt(),
      milkPowder: (json[RecipesTableColumns.milkPowder] as num?)?.toInt(),
      whippingCream: (json[RecipesTableColumns.whippingCream] as num?)?.toInt(),
      condensedMilk: (json[RecipesTableColumns.condensedMilk] as num?)?.toInt(),
      datePaste: (json[RecipesTableColumns.datePaste] as num?)?.toInt(),
      malban: (json[RecipesTableColumns.malban] as num?)?.toInt(),
      custard: (json[RecipesTableColumns.custard] as num?)?.toInt(),
      cocoa: (json[RecipesTableColumns.cocoa] as num?)?.toInt(),
      coconutPowder: (json[RecipesTableColumns.coconutPowder] as num?)?.toInt(),
      blackMolasses: (json[RecipesTableColumns.blackMolasses] as num?)?.toInt(),
      whiteCheese: (json[RecipesTableColumns.whiteCheese] as num?)?.toInt(),
      roumyCheese: (json[RecipesTableColumns.roumyCheese] as num?)?.toInt(),
      istanbouliCheese: (json[RecipesTableColumns.istanbouliCheese] as num?)
          ?.toInt(),
      mozzarella: (json[RecipesTableColumns.mozzarella] as num?)?.toInt(),
      olives: (json[RecipesTableColumns.olives] as num?)?.toInt(),
      peanut: (json[RecipesTableColumns.peanut] as num?)?.toInt(),
      cashew: (json[RecipesTableColumns.cashew] as num?)?.toInt(),
      almond: (json[RecipesTableColumns.almond] as num?)?.toInt(),
      pistachio: (json[RecipesTableColumns.pistachio] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      RecipesTableColumns.bakeryId: bakeryId,
      if (productId != null && productId!.isNotEmpty)
        RecipesTableColumns.productId: productId,
      RecipesTableColumns.flourType: flourType,
      RecipesTableColumns.yeast: yeast,
      RecipesTableColumns.salt: salt,
      RecipesTableColumns.sugar: sugar,
      RecipesTableColumns.eggs: eggs,
      RecipesTableColumns.ghee: ghee,
      RecipesTableColumns.oil: oil,
      RecipesTableColumns.butter: butter,
      RecipesTableColumns.sesame: sesame,
      RecipesTableColumns.blackSeeds: blackSeeds,
      RecipesTableColumns.fennel: fennel,
      RecipesTableColumns.anise: anise,
      RecipesTableColumns.mahlab: mahlab,
      RecipesTableColumns.cinnamon: cinnamon,
      RecipesTableColumns.bakingPowder: bakingPowder,
      RecipesTableColumns.bakingSoda: bakingSoda,
      RecipesTableColumns.chocolate: chocolate,
      RecipesTableColumns.conditioner: conditioner,
      RecipesTableColumns.vanilla: vanilla,
      RecipesTableColumns.milk: milk,
      RecipesTableColumns.milkPowder: milkPowder,
      RecipesTableColumns.whippingCream: whippingCream,
      RecipesTableColumns.condensedMilk: condensedMilk,
      RecipesTableColumns.datePaste: datePaste,
      RecipesTableColumns.malban: malban,
      RecipesTableColumns.custard: custard,
      RecipesTableColumns.cocoa: cocoa,
      RecipesTableColumns.coconutPowder: coconutPowder,
      RecipesTableColumns.blackMolasses: blackMolasses,
      RecipesTableColumns.whiteCheese: whiteCheese,
      RecipesTableColumns.roumyCheese: roumyCheese,
      RecipesTableColumns.istanbouliCheese: istanbouliCheese,
      RecipesTableColumns.mozzarella: mozzarella,
      RecipesTableColumns.olives: olives,
      RecipesTableColumns.peanut: peanut,
      RecipesTableColumns.cashew: cashew,
      RecipesTableColumns.almond: almond,
      RecipesTableColumns.pistachio: pistachio,
    };
  }

  RecipeModel copyWith({
    String? bakeryId,
    String? productId,
    String? flourType,
    int? yeast,
    int? salt,
    int? sugar,
    int? eggs,
    int? ghee,
    int? oil,
    int? butter,
    int? sesame,
    int? blackSeeds,
    int? fennel,
    int? anise,
    int? mahlab,
    int? cinnamon,
    int? bakingPowder,
    int? bakingSoda,
    int? chocolate,
    int? conditioner,
    int? vanilla,
    int? milk,
    int? milkPowder,
    int? whippingCream,
    int? condensedMilk,
    int? datePaste,
    int? malban,
    int? custard,
    int? cocoa,
    int? coconutPowder,
    int? blackMolasses,
    int? whiteCheese,
    int? roumyCheese,
    int? istanbouliCheese,
    int? mozzarella,
    int? olives,
    int? peanut,
    int? cashew,
    int? almond,
    int? pistachio,
  }) {
    return RecipeModel(
      bakeryId: bakeryId ?? this.bakeryId,
      productId: productId ?? this.productId,
      flourType: flourType ?? this.flourType,
      yeast: yeast ?? this.yeast,
      salt: salt ?? this.salt,
      sugar: sugar ?? this.sugar,
      eggs: eggs ?? this.eggs,
      ghee: ghee ?? this.ghee,
      oil: oil ?? this.oil,
      butter: butter ?? this.butter,
      sesame: sesame ?? this.sesame,
      blackSeeds: blackSeeds ?? this.blackSeeds,
      fennel: fennel ?? this.fennel,
      anise: anise ?? this.anise,
      mahlab: mahlab ?? this.mahlab,
      cinnamon: cinnamon ?? this.cinnamon,
      bakingPowder: bakingPowder ?? this.bakingPowder,
      bakingSoda: bakingSoda ?? this.bakingSoda,
      chocolate: chocolate ?? this.chocolate,
      conditioner: conditioner ?? this.conditioner,
      vanilla: vanilla ?? this.vanilla,
      milk: milk ?? this.milk,
      milkPowder: milkPowder ?? this.milkPowder,
      whippingCream: whippingCream ?? this.whippingCream,
      condensedMilk: condensedMilk ?? this.condensedMilk,
      datePaste: datePaste ?? this.datePaste,
      malban: malban ?? this.malban,
      custard: custard ?? this.custard,
      cocoa: cocoa ?? this.cocoa,
      coconutPowder: coconutPowder ?? this.coconutPowder,
      blackMolasses: blackMolasses ?? this.blackMolasses,
      whiteCheese: whiteCheese ?? this.whiteCheese,
      roumyCheese: roumyCheese ?? this.roumyCheese,
      istanbouliCheese: istanbouliCheese ?? this.istanbouliCheese,
      mozzarella: mozzarella ?? this.mozzarella,
      olives: olives ?? this.olives,
      peanut: peanut ?? this.peanut,
      cashew: cashew ?? this.cashew,
      almond: almond ?? this.almond,
      pistachio: pistachio ?? this.pistachio,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecipeModel &&
        other.bakeryId == bakeryId &&
        other.productId == productId &&
        other.flourType == flourType &&
        other.yeast == yeast &&
        other.salt == salt &&
        other.sugar == sugar &&
        other.eggs == eggs &&
        other.ghee == ghee &&
        other.oil == oil &&
        other.butter == butter &&
        other.sesame == sesame &&
        other.blackSeeds == blackSeeds &&
        other.fennel == fennel &&
        other.anise == anise &&
        other.mahlab == mahlab &&
        other.cinnamon == cinnamon &&
        other.bakingPowder == bakingPowder &&
        other.bakingSoda == bakingSoda &&
        other.chocolate == chocolate &&
        other.conditioner == conditioner &&
        other.vanilla == vanilla &&
        other.milk == milk &&
        other.milkPowder == milkPowder &&
        other.whippingCream == whippingCream &&
        other.condensedMilk == condensedMilk &&
        other.datePaste == datePaste &&
        other.malban == malban &&
        other.custard == custard &&
        other.cocoa == cocoa &&
        other.coconutPowder == coconutPowder &&
        other.blackMolasses == blackMolasses &&
        other.whiteCheese == whiteCheese &&
        other.roumyCheese == roumyCheese &&
        other.istanbouliCheese == istanbouliCheese &&
        other.mozzarella == mozzarella &&
        other.olives == olives &&
        other.peanut == peanut &&
        other.cashew == cashew &&
        other.almond == almond &&
        other.pistachio == pistachio;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll([
      bakeryId,
      productId,
      flourType,
      yeast,
      salt,
      sugar,
      eggs,
      ghee,
      oil,
      butter,
      sesame,
      blackSeeds,
      fennel,
      anise,
      mahlab,
      cinnamon,
      bakingPowder,
      bakingSoda,
      chocolate,
      conditioner,
    ]),
    Object.hashAll([
      vanilla,
      milk,
      milkPowder,
      whippingCream,
      condensedMilk,
      datePaste,
      malban,
      custard,
      cocoa,
      coconutPowder,
      blackMolasses,
      whiteCheese,
      roumyCheese,
      istanbouliCheese,
      mozzarella,
      olives,
      peanut,
      cashew,
      almond,
      pistachio,
    ]),
  );
}
