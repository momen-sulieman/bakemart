class StorageItems {
  StorageItems._();
// Flours & Grains
  static const String fineWheat = 'fineWheat';
  static const String wholeWheat = 'wholeWheat';
  static const String corn = 'corn';
  static const String oats = 'oats';
  static const String barley = 'barley';
  static const String semolina = 'semolina';
  static const String phyllo = 'phyllo';

// Basic Ingredients
  static const String yeast = 'yeast';
  static const String salt = 'salt';
  static const String sugar = 'sugar';
  static const String eggs = 'eggs';

// Fats & Oils
  static const String ghee = 'ghee';
  static const String oil = 'oil';
  static const String butter = 'butter';

// Seeds & Spices
  static const String sesame = 'sesame';
  static const String blackSeeds = 'blackSeeds';
  static const String fennel = 'fennel';
  static const String anise = 'anise';
  static const String mahlab = 'mahlab';
  static const String cinnamon = 'cinnamon';

// Leavening & Additives
  static const String bakingPowder = 'bakingPowder';
  static const String bakingSoda = 'bakingSoda';
  static const String conditioner = 'conditioner';
  static const String vanilla = 'vanilla';

// Dairy & Liquids
  static const String milk = 'milk';
  static const String milkPowder = 'milkPowder';
  static const String whippingCream = 'whippingCream';
  static const String condensedMilk = 'condensedMilk';

// Fillings & Sweets
  static const String chocolate = 'chocolate';
  static const String datePaste = 'datePaste';
  static const String malban = 'malban';
  static const String custard = 'custard';
  static const String cocoa = 'cocoa';
  static const String coconutPowder = 'coconutPowder';
  static const String blackMolasses = 'blackMolasses';

// Cheeses & Savories
  static const String whiteCheese = 'whiteCheese';
  static const String roumyCheese = 'roumyCheese';
  static const String istanbouliCheese = 'istanbouliCheese';
  static const String mozzarella = 'mozzarella';
  static const String olives = 'olives';

// Nuts
  static const String peanut = 'peanut';
  static const String cashew = 'cashew';
  static const String almond = 'almond';
  static const String pistachio = 'pistachio';
}
const List<String> kFlourTypes = [
  StorageItems.wholeWheat,
  StorageItems.fineWheat,
  StorageItems.semolina,
  StorageItems.phyllo,
  StorageItems.barley,
  StorageItems.corn,
  StorageItems.oats,
];
const int kDefaultFlourIndex = 1; // fine wheat