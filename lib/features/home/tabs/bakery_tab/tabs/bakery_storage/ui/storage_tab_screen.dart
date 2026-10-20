import 'package:bakemart/core/shared/widgets/branch_pager/branch_pager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:wheel_picker/wheel_picker.dart';

import '../../../../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../../../../core/shared/models/storage_helper.dart';
import '../../../../../../../core/theming/theming_colors.dart';
import '../../../../../../../core/utils/constants/constant_images.dart';
import '../../../../../../../core/utils/extensions/context_extensions.dart';
import '../../../logic/bakery_tab_cubit/bakery_tab_cubit.dart';
import '../logic/storage_cubit/storage_cubit.dart';
import '../logic/unit_cubit/unit_cubit.dart';
import 'widgets/storage_item_card.dart';

class StorageTabScreen extends StatelessWidget {
  const StorageTabScreen({super.key});

  String _unitLabelFor(double unitFactor) {
    if (unitFactor == 1) return "storageGramUnit".tr();
    if (unitFactor == 453.59237) return "storagePoundsUnit".tr();
    return "storageKilogramUnit".tr();
  }

  int _unitIndexFor(double unitFactor) {
    if (unitFactor == 1) return 0;
    if (unitFactor == 453.59237) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final List<String> units = [
      "storageGram".tr(),
      "storageKilogram".tr(),
      "storagePounds".tr(),
    ];

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => DependencyInjection.getIt<UnitCubit>()),
        BlocProvider(create: (_) => DependencyInjection.getIt<StorageCubit>()),
      ],
      child: BlocBuilder<UnitCubit, double>(
        builder: (context, unitFactor) {
          final unitCubit = context.read<UnitCubit>();
          final unit = _unitLabelFor(unitFactor);
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: context.isDark
                  ? ThemingColors.black.withAlpha((0.7 * 255).toInt())
                  : ThemingColors.white.withAlpha((0.8 * 255).toInt()),
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(20),
                child: Container(
                  height: 70,
                  width: .infinity,
                  padding: .only(bottom: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: ThemingColors.primaryColor.withAlpha(
                          (0.15 * 255).toInt(),
                        ),
                        width: 5,
                      ),
                    ),
                    borderRadius: .only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_right,
                        size: 20,
                        color: ThemingColors.primaryColor,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: context.isDark
                              ? ThemingColors.black
                              : ThemingColors.white,
                          border: .all(
                            width: 0.4,
                            color: ThemingColors.primaryColor,
                          ),
                        ),
                        child: SizedBox(
                          height: 55,
                          width: 75,
                          child: WheelPicker(
                            looping: false,
                            controller: WheelPickerController(
                              itemCount: 3,
                              initialIndex: _unitIndexFor(unitFactor),
                            ),
                            style: WheelPickerStyle(
                              itemExtent: 19,
                              surroundingOpacity: context.isDark ? 0.5 : 0.3,
                              diameterRatio: 20,
                            ),
                            onIndexChanged: (index, _) {
                              if (index == 1) {
                                unitCubit.kilo();
                              } else if (index == 0) {
                                unitCubit.gram();
                              } else {
                                unitCubit.pound();
                              }
                            },
                            builder: (context, index) => Center(
                              child: Text(
                                units[index],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: .bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_left,
                        size: 20,
                        color: ThemingColors.primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: Container(
              height: screenHeight + 100,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    context.isDark
                        ? ConstantImages.darkBackground
                        : ConstantImages.lightBackground,
                  ),
                  fit: BoxFit.cover,
                  opacity: context.isDark ? 0.35 : 0.25,
                ),
              ),
              child: BlocBuilder<StorageCubit, StorageState>(
                builder: (context, storageState) {
                  if (storageState is StorageLoading) {
                    return Center(
                      child: LoadingAnimationWidget.staggeredDotsWave(
                        color: ThemingColors.primaryColor,
                        size: 25,
                      ),
                    );
                  } else if (storageState is StorageSucces) {
                    final storageCubit = context.read<StorageCubit>();
                    return RefreshIndicator(
                      edgeOffset: 190,
                      strokeWidth: 2,
                      displacement: 0,
                      elevation: 0,
                      color: ThemingColors.primaryColor,
                      backgroundColor: Colors.transparent,
                      onRefresh: () async {
                        await context.read<BakeryTabCubit>().loadAll();
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: .only(
                          bottom: 130,
                          top: 210,
                          left: 15,
                          right: 15,
                        ),
                        child: BranchPager(
                          branches: storageCubit.branches,
                          storage: true,
                          selectedBranchId: storageCubit.storageViewedBranch,
                          onBranchChanged: storageCubit.storageBranchChanged,
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 20,
                              childAspectRatio: 0.8,
                            ),
                            itemCount: StorageHelper.allItems.length,
                            itemBuilder: (context, index) {
                              final itemName = StorageHelper.allItems[index];
                              return StorageItemCard(
                                storage: storageState.storage,
                                itemName: itemName,
                                itemUnit: unit,
                                itemUnitFactor: unitFactor,
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  } else if (storageState is StorageFailure) {
                    return Center(child: Text("Error"));
                  }
                  return SizedBox.shrink();
                },
              ),
            ),
          );
        },
      ),
    );
  }
}