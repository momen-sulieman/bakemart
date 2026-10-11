import '../../utils/enums/storages_table_columns.dart';

class StorageModel {
  final String bakeryId;
  final int? fineWheat;
  final int? wholeWheat;
  final int? corn;
  final int? oats;
  final int? barley;
  final int? semolina;
  final int? phyllo;
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
  final int? conditioner;
  final int? vanilla;
  final int? milk;
  final int? milkPowder;
  final int? whippingCream;
  final int? condensedMilk;
  final int? chocolate;
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

  StorageModel({
    required this.bakeryId,
    this.fineWheat,
    this.wholeWheat,
    this.corn,
    this.oats,
    this.barley,
    this.semolina,
    this.phyllo,
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
    this.conditioner,
    this.vanilla,
    this.milk,
    this.milkPowder,
    this.whippingCream,
    this.condensedMilk,
    this.chocolate,
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

  StorageModel copyWith({
    String? bakeryId,
    int? fineWheat,
    int? wholeWheat,
    int? corn,
    int? oats,
    int? barley,
    int? semolina,
    int? phyllo,
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
    int? conditioner,
    int? vanilla,
    int? milk,
    int? milkPowder,
    int? whippingCream,
    int? condensedMilk,
    int? chocolate,
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
    return StorageModel(
      bakeryId: bakeryId ?? this.bakeryId,
      fineWheat: fineWheat ?? this.fineWheat,
      wholeWheat: wholeWheat ?? this.wholeWheat,
      corn: corn ?? this.corn,
      oats: oats ?? this.oats,
      barley: barley ?? this.barley,
      semolina: semolina ?? this.semolina,
      phyllo: phyllo ?? this.phyllo,
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
      conditioner: conditioner ?? this.conditioner,
      vanilla: vanilla ?? this.vanilla,
      milk: milk ?? this.milk,
      milkPowder: milkPowder ?? this.milkPowder,
      whippingCream: whippingCream ?? this.whippingCream,
      condensedMilk: condensedMilk ?? this.condensedMilk,
      chocolate: chocolate ?? this.chocolate,
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

  Map<String, dynamic> toJson() {
    return {
      StoragesTableColumns.bakeryId: bakeryId,
      StoragesTableColumns.fineWheat: fineWheat,
      StoragesTableColumns.wholeWheat: wholeWheat,
      StoragesTableColumns.corn: corn,
      StoragesTableColumns.oats: oats,
      StoragesTableColumns.barley: barley,
      StoragesTableColumns.semolina: semolina,
      StoragesTableColumns.phyllo: phyllo,
      StoragesTableColumns.yeast: yeast,
      StoragesTableColumns.salt: salt,
      StoragesTableColumns.sugar: sugar,
      StoragesTableColumns.eggs: eggs,
      StoragesTableColumns.ghee: ghee,
      StoragesTableColumns.oil: oil,
      StoragesTableColumns.butter: butter,
      StoragesTableColumns.sesame: sesame,
      StoragesTableColumns.blackSeeds: blackSeeds,
      StoragesTableColumns.fennel: fennel,
      StoragesTableColumns.anise: anise,
      StoragesTableColumns.mahlab: mahlab,
      StoragesTableColumns.cinnamon: cinnamon,
      StoragesTableColumns.bakingPowder: bakingPowder,
      StoragesTableColumns.bakingSoda: bakingSoda,
      StoragesTableColumns.conditioner: conditioner,
      StoragesTableColumns.vanilla: vanilla,
      StoragesTableColumns.milk: milk,
      StoragesTableColumns.milkPowder: milkPowder,
      StoragesTableColumns.whippingCream: whippingCream,
      StoragesTableColumns.condensedMilk: condensedMilk,
      StoragesTableColumns.chocolate: chocolate,
      StoragesTableColumns.datePaste: datePaste,
      StoragesTableColumns.malban: malban,
      StoragesTableColumns.custard: custard,
      StoragesTableColumns.cocoa: cocoa,
      StoragesTableColumns.coconutPowder: coconutPowder,
      StoragesTableColumns.blackMolasses: blackMolasses,
      StoragesTableColumns.whiteCheese: whiteCheese,
      StoragesTableColumns.roumyCheese: roumyCheese,
      StoragesTableColumns.istanbouliCheese: istanbouliCheese,
      StoragesTableColumns.mozzarella: mozzarella,
      StoragesTableColumns.olives: olives,
      StoragesTableColumns.peanut: peanut,
      StoragesTableColumns.cashew: cashew,
      StoragesTableColumns.almond: almond,
      StoragesTableColumns.pistachio: pistachio,
    };
  }

  factory StorageModel.fromJson(Map<String, dynamic> json) {
    return StorageModel(
      bakeryId: json[StoragesTableColumns.bakeryId] as String? ?? "",
      fineWheat: (json[StoragesTableColumns.fineWheat] as num?)?.toInt(),
      wholeWheat: (json[StoragesTableColumns.wholeWheat] as num?)?.toInt(),
      corn: (json[StoragesTableColumns.corn] as num?)?.toInt(),
      oats: (json[StoragesTableColumns.oats] as num?)?.toInt(),
      barley: (json[StoragesTableColumns.barley] as num?)?.toInt(),
      semolina: (json[StoragesTableColumns.semolina] as num?)?.toInt(),
      phyllo: (json[StoragesTableColumns.phyllo] as num?)?.toInt(),
      yeast: (json[StoragesTableColumns.yeast] as num?)?.toInt(),
      salt: (json[StoragesTableColumns.salt] as num?)?.toInt(),
      sugar: (json[StoragesTableColumns.sugar] as num?)?.toInt(),
      eggs: (json[StoragesTableColumns.eggs] as num?)?.toInt(),
      ghee: (json[StoragesTableColumns.ghee] as num?)?.toInt(),
      oil: (json[StoragesTableColumns.oil] as num?)?.toInt(),
      butter: (json[StoragesTableColumns.butter] as num?)?.toInt(),
      sesame: (json[StoragesTableColumns.sesame] as num?)?.toInt(),
      blackSeeds: (json[StoragesTableColumns.blackSeeds] as num?)?.toInt(),
      fennel: (json[StoragesTableColumns.fennel] as num?)?.toInt(),
      anise: (json[StoragesTableColumns.anise] as num?)?.toInt(),
      mahlab: (json[StoragesTableColumns.mahlab] as num?)?.toInt(),
      cinnamon: (json[StoragesTableColumns.cinnamon] as num?)?.toInt(),
      bakingPowder: (json[StoragesTableColumns.bakingPowder] as num?)?.toInt(),
      bakingSoda: (json[StoragesTableColumns.bakingSoda] as num?)?.toInt(),
      conditioner: (json[StoragesTableColumns.conditioner] as num?)?.toInt(),
      vanilla: (json[StoragesTableColumns.vanilla] as num?)?.toInt(),
      milk: (json[StoragesTableColumns.milk] as num?)?.toInt(),
      milkPowder: (json[StoragesTableColumns.milkPowder] as num?)?.toInt(),
      whippingCream: (json[StoragesTableColumns.whippingCream] as num?)?.toInt(),
      condensedMilk: (json[StoragesTableColumns.condensedMilk] as num?)?.toInt(),
      chocolate: (json[StoragesTableColumns.chocolate] as num?)?.toInt(),
      datePaste: (json[StoragesTableColumns.datePaste] as num?)?.toInt(),
      malban: (json[StoragesTableColumns.malban] as num?)?.toInt(),
      custard: (json[StoragesTableColumns.custard] as num?)?.toInt(),
      cocoa: (json[StoragesTableColumns.cocoa] as num?)?.toInt(),
      coconutPowder: (json[StoragesTableColumns.coconutPowder] as num?)?.toInt(),
      blackMolasses: (json[StoragesTableColumns.blackMolasses] as num?)?.toInt(),
      whiteCheese: (json[StoragesTableColumns.whiteCheese] as num?)?.toInt(),
      roumyCheese: (json[StoragesTableColumns.roumyCheese] as num?)?.toInt(),
      istanbouliCheese: (json[StoragesTableColumns.istanbouliCheese] as num?)?.toInt(),
      mozzarella: (json[StoragesTableColumns.mozzarella] as num?)?.toInt(),
      olives: (json[StoragesTableColumns.olives] as num?)?.toInt(),
      peanut: (json[StoragesTableColumns.peanut] as num?)?.toInt(),
      cashew: (json[StoragesTableColumns.cashew] as num?)?.toInt(),
      almond: (json[StoragesTableColumns.almond] as num?)?.toInt(),
      pistachio: (json[StoragesTableColumns.pistachio] as num?)?.toInt(),
    );
  }
}