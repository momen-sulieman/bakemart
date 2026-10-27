// import 'dart:io';
//
// import 'package:bakemart/core/shared/models/product_model.dart';
// import 'package:bakemart/core/shared/widgets/dialogs/add_product_dialog/logic/add_product_cubit/add_product_cubit.dart';
// import 'package:bakemart/core/shared/widgets/dialogs/add_product_dialog/ui/add_product_dialog.dart';
// import 'package:bakemart/core/utils/enums/storage_items.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_test/flutter_test.dart';
//
// import '../../helpers/di_overrides.dart';
// import '../../helpers/test_setup.dart';
// import '../../helpers/widget_test_helpers.dart';
//
// final Finder dialogFields = find.descendant(
//   of: find.byType(AlertDialog),
//   matching: find.byType(TextFormField),
// );
// final Finder doneButton = find.descendant(
//   of: find.byType(AlertDialog),
//   matching: find.byIcon(Icons.done),
// );
// final Finder backButton = find.descendant(
//   of: find.byType(AlertDialog),
//   matching: find.byIcon(Icons.arrow_back),
// );
//
// void main() {
//   final List<ProductModel> savedProducts = [];
//   final List<File?> savedImages = [];
//
//   setUpAll(() async {
//     await setupTestEnvironment();
//   });
//
//   setUp(() {
//     ensureImageCubitFactory();
//     savedProducts.clear();
//     savedImages.clear();
//   });
//
//   void onSave(ProductModel product, File? image) {
//     savedProducts.add(product);
//     savedImages.add(image);
//   }
//
//   Future<void> openDialog(
//       WidgetTester tester, {
//         List<String>? flourTypes,
//         int initialFlourIndex = 1,
//       }) async {
//     useTallSurface(tester, size: const Size(900, 3000));
//     await pumpLocalizedWidget(
//       tester,
//       Builder(
//         builder: (context) => Scaffold(
//           body: Center(
//             child: ElevatedButton(
//               onPressed: () => showDialog(
//                 context: context,
//                 barrierColor: Colors.transparent,
//                 builder: (_) => flourTypes == null
//                     ? AddProductDialog(
//                   bakeryId: 'b1',
//                   onSave: onSave,
//                   initialFlourIndex: initialFlourIndex,
//                 )
//                     : AddProductDialog(
//                   bakeryId: 'b1',
//                   onSave: onSave,
//                   flourTypes: flourTypes,
//                   initialFlourIndex: initialFlourIndex,
//                 ),
//               ),
//               child: const Text('open'),
//             ),
//           ),
//         ),
//       ),
//     );
//     await tester.tap(find.text('open'));
//     await tester.pumpAndSettle();
//   }
//
//   Future<void> fillValid(
//       WidgetTester tester, {
//         String name = 'baguette',
//         String price = '2.5',
//         String weight = '200',
//         String quantity = '10',
//         String yeast = '50',
//       }) async {
//     await tester.enterText(dialogFields.at(0), name);
//     await tester.enterText(dialogFields.at(1), price);
//     await tester.enterText(dialogFields.at(2), weight);
//     await tester.enterText(dialogFields.at(3), quantity);
//     await tester.enterText(dialogFields.at(4), yeast);
//     await tester.pumpAndSettle();
//   }
//
//   testWidgets('renders the core fields plus one field per recipe item',
//           (tester) async {
//         await openDialog(tester);
//
//         final cubit = BlocProvider.of<AddProductCubit>(
//           tester.element(find.byType(AlertDialog)),
//         );
//         expect(dialogFields, findsNWidgets(4 + cubit.recipeFields.length));
//       });
//
//   testWidgets('only the back arrow shows until the form is valid',
//           (tester) async {
//         await openDialog(tester);
//
//         expect(backButton, findsOneWidget);
//         expect(doneButton, findsNothing);
//       });
//
//   testWidgets('core fields alone do not make the form valid', (tester) async {
//     await openDialog(tester);
//
//     await tester.enterText(dialogFields.at(0), 'baguette');
//     await tester.enterText(dialogFields.at(1), '2.5');
//     await tester.enterText(dialogFields.at(2), '200');
//     await tester.enterText(dialogFields.at(3), '10');
//     await tester.pumpAndSettle();
//
//     expect(doneButton, findsNothing);
//   });
//
//   testWidgets('core fields plus one recipe item make the form valid',
//           (tester) async {
//         await openDialog(tester);
//
//         await fillValid(tester);
//
//         expect(doneButton, findsOneWidget);
//       });
//
//   testWidgets('clearing a core field invalidates the form again',
//           (tester) async {
//         await openDialog(tester);
//         await fillValid(tester);
//
//         await tester.enterText(dialogFields.at(0), '');
//         await tester.pumpAndSettle();
//
//         expect(doneButton, findsNothing);
//       });
//
//   testWidgets('clearing the only recipe item invalidates the form again',
//           (tester) async {
//         await openDialog(tester);
//         await fillValid(tester);
//
//         await tester.enterText(dialogFields.at(4), '');
//         await tester.pumpAndSettle();
//
//         expect(doneButton, findsNothing);
//       });
//
//   testWidgets('saving builds the product and recipe and closes the dialog',
//           (tester) async {
//         await openDialog(tester);
//         await fillValid(tester);
//
//         await tester.tap(doneButton);
//         await tester.pumpAndSettle();
//
//         expect(find.byType(AlertDialog), findsNothing);
//         expect(savedProducts, hasLength(1));
//         final product = savedProducts.single;
//         expect(product.productName, 'Baguette');
//         expect(product.productPrice, 2.5);
//         expect(product.productWeight, 200);
//         expect(product.quantityPerBatch, 10);
//         expect(product.bakeryId, 'b1');
//         expect(product.productId, isNotEmpty);
//         expect(product.productRecipe.productId, product.productId);
//         expect(product.productRecipe.bakeryId, 'b1');
//         expect(product.productRecipe.yeast, 50);
//         expect(product.productRecipe.flourType, StorageItems.fineWheat);
//         expect(savedImages.single, isNull);
//       });
//
//   testWidgets('arabic-indic digits are converted before saving',
//           (tester) async {
//         await openDialog(tester);
//         await fillValid(
//           tester,
//           weight: '٢٠٠',
//           quantity: '١٠',
//           yeast: '٥٠',
//         );
//
//         await tester.tap(doneButton);
//         await tester.pumpAndSettle();
//
//         final product = savedProducts.single;
//         expect(product.productWeight, 200);
//         expect(product.quantityPerBatch, 10);
//         expect(product.productRecipe.yeast, 50);
//       });
//
//   testWidgets('the initial flour index decides the saved flour type',
//           (tester) async {
//         await openDialog(
//           tester,
//           flourTypes: const ['a', 'b', 'c'],
//           initialFlourIndex: 2,
//         );
//         await fillValid(tester);
//
//         await tester.tap(doneButton);
//         await tester.pumpAndSettle();
//
//         expect(savedProducts.single.productRecipe.flourType, 'c');
//       });
//
//   testWidgets('the back arrow closes the dialog without saving',
//           (tester) async {
//         await openDialog(tester);
//         await fillValid(tester);
//
//         await tester.tap(backButton);
//         await tester.pumpAndSettle();
//
//         expect(find.byType(AlertDialog), findsNothing);
//         expect(savedProducts, isEmpty);
//       });
// }