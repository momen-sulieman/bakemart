// import 'package:bakemart/core/theming/theming_colors.dart';
// import 'package:bakemart/core/utils/extensions/context_extensions.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';
// import '../../../../dependency_injection/dependency_injection.dart';
// import '../logic/supabase_image_cubit/supabase_image_cubit.dart';
//
// class SupabaseImage extends StatelessWidget {
//   final bool showPlaceholderIcon, person;
//   final double iconSize,addIconSize,loadingIconSize, iconLightOpacity, iconDarkOpacity;
//   final int? cacheWidth, cacheHeight;
//
//   const SupabaseImage({
//     super.key,
//     this.showPlaceholderIcon = true,
//     this.person = false,
//     this.iconSize = 24,
//     this.addIconSize = 14,
//     this.loadingIconSize = 24,
//     this.iconLightOpacity = 0.25,
//     this.iconDarkOpacity = 0.3,
//     this.cacheWidth,
//     this.cacheHeight,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<SupabaseImageCubit, SupabaseImageState>(
//       builder: (context, state) {
//         if (state is ImageLoading) {
//           if (!showPlaceholderIcon) return const SizedBox.shrink();
//           return Center(
//             child: LoadingAnimationWidget.threeArchedCircle(
//               color: ThemingColors.primaryColor,
//               size: 24,
//             ),
//           );
//         }
//         if (state is ImageEmpty) {
//           if (!showPlaceholderIcon) return const SizedBox.shrink();
//           return Icon(
//             Icons.add_a_photo_outlined,
//             size: addIconSize,
//             color: ThemingColors.primaryColor.withAlpha((0.5 * 255).toInt()),
//           );
//         }
//         if (state is ImageLoaded) {
//           return SizedBox.expand(
//             child: Image.network(
//               state.imageUrl,
//               fit: BoxFit.cover,
//               cacheWidth: cacheWidth,
//               cacheHeight: cacheHeight,
//               loadingBuilder: (context, child, progress) {
//                 if (progress == null) return child;
//                 if (!showPlaceholderIcon) return const SizedBox.shrink();
//                 return Center(
//                   child: LoadingAnimationWidget.threeArchedCircle(
//                     color: ThemingColors.primaryColor,
//                     size: loadingIconSize,
//                   ),
//                 );
//               },
//               errorBuilder: (_, _, _) => showPlaceholderIcon
//                   ? Icon(
//                 person ? Icons.person : Icons.camera_alt,
//                 size: iconSize,
//                 color: context.isDark
//                     ? ThemingColors.white.withAlpha(
//                   (iconDarkOpacity * 255).toInt(),
//                 )
//                     : ThemingColors.black.withAlpha(
//                   (iconLightOpacity * 255).toInt(),
//                 ),
//               )
//                   : const SizedBox.shrink(),
//             ),
//           );
//         }
//         if (state is ImageFailure) {
//           if (!showPlaceholderIcon) return const SizedBox.shrink();
//           return Icon(
//             person ? Icons.person : Icons.camera_alt,
//             size: iconSize,
//             color: context.isDark
//                 ? ThemingColors.white.withAlpha((iconDarkOpacity * 255).toInt())
//                 : ThemingColors.black.withAlpha(
//               (iconLightOpacity * 255).toInt(),
//             ),
//           );
//         }
//         if (state is ImagePicked) {
//           return SizedBox.expand(
//             child: Image.file(
//               state.imageFile,
//               fit: BoxFit.cover,
//               cacheWidth: cacheWidth,
//               cacheHeight: cacheHeight,
//             ),
//           );
//         }
//         return const SizedBox.shrink();
//       },
//     );
//   }
// }
//
// class SupabaseImageProvider extends StatelessWidget {
//   final String filePath;
//   final String? fileName;
//   final bool showPlaceholderIcon, person;
//   final double iconSize,addIconSize, iconLightOpacity, iconDarkOpacity,loadingIconSize;
//   final int? cacheWidth, cacheHeight;
//
//   const SupabaseImageProvider({
//     super.key,
//     required this.filePath,
//     this.fileName,
//     this.showPlaceholderIcon = true,
//     this.person = false,
//     this.iconSize = 24,
//     this.addIconSize = 14,
//     this.loadingIconSize = 24,
//     this.iconLightOpacity = 0.25,
//     this.iconDarkOpacity = 0.3,
//     this.cacheWidth,
//     this.cacheHeight,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => DependencyInjection.getIt<SupabaseImageCubit>(
//         param1: filePath,
//         param2: fileName,
//       ),
//       child: SupabaseImage(
//         showPlaceholderIcon: showPlaceholderIcon,
//         iconSize: iconSize,
//         person: person,
//         iconLightOpacity: iconLightOpacity,
//         iconDarkOpacity: iconDarkOpacity,
//         loadingIconSize: loadingIconSize,
//         addIconSize: addIconSize,
//         cacheWidth: cacheWidth,
//         cacheHeight: cacheHeight,
//       ),
//     );
//   }
// }
import 'package:bakemart/core/theming/theming_colors.dart';
import 'package:bakemart/core/utils/extensions/context_extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../../dependency_injection/dependency_injection.dart';
import '../logic/supabase_image_cubit/supabase_image_cubit.dart';

class SupabaseImage extends StatelessWidget {
  final bool showPlaceholderIcon, person;
  final double iconSize,addIconSize,loadingIconSize, iconLightOpacity, iconDarkOpacity;
  final int? cacheWidth, cacheHeight;

  const SupabaseImage({
    super.key,
    this.showPlaceholderIcon = true,
    this.person = false,
    this.iconSize = 24,
    this.addIconSize = 14,
    this.loadingIconSize = 24,
    this.iconLightOpacity = 0.25,
    this.iconDarkOpacity = 0.3,
    this.cacheWidth,
    this.cacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SupabaseImageCubit, SupabaseImageState>(
      builder: (context, state) {
        if (state is ImageLoading) {
          if (!showPlaceholderIcon) return const SizedBox.shrink();
          return Center(
            child: LoadingAnimationWidget.threeArchedCircle(
              color: ThemingColors.primaryColor,
              size: 24,
            ),
          );
        }
        if (state is ImageEmpty) {
          if (!showPlaceholderIcon) return const SizedBox.shrink();
          return Icon(
            Icons.add_a_photo_outlined,
            size: addIconSize,
            color: ThemingColors.primaryColor.withAlpha((0.5 * 255).toInt()),
          );
        }
        if (state is ImageLoaded) {
          return SizedBox.expand(
            child: CachedNetworkImage(
              imageUrl: state.imageUrl,
              fit: BoxFit.cover,
              memCacheWidth: cacheWidth,
              memCacheHeight: cacheHeight,
              fadeInDuration: Duration.zero,
              fadeOutDuration: Duration.zero,
              placeholder: showPlaceholderIcon
                  ? (context, url) => Center(
                child: LoadingAnimationWidget.threeArchedCircle(
                  color: ThemingColors.primaryColor,
                  size: loadingIconSize,
                ),
              )
                  : (context, url) => const SizedBox.shrink(),
              errorWidget: (context, url, error) => showPlaceholderIcon
                  ? Icon(
                person ? Icons.person : Icons.camera_alt,
                size: iconSize,
                color: context.isDark
                    ? ThemingColors.white.withAlpha(
                  (iconDarkOpacity * 255).toInt(),
                )
                    : ThemingColors.black.withAlpha(
                  (iconLightOpacity * 255).toInt(),
                ),
              )
                  : const SizedBox.shrink(),
            ),
          );
        }
        if (state is ImageFailure) {
          if (!showPlaceholderIcon) return const SizedBox.shrink();
          return Icon(
            person ? Icons.person : Icons.camera_alt,
            size: iconSize,
            color: context.isDark
                ? ThemingColors.white.withAlpha((iconDarkOpacity * 255).toInt())
                : ThemingColors.black.withAlpha(
              (iconLightOpacity * 255).toInt(),
            ),
          );
        }
        if (state is ImagePicked) {
          return SizedBox.expand(
            child: Image.file(
              state.imageFile,
              fit: BoxFit.cover,
              cacheWidth: cacheWidth,
              cacheHeight: cacheHeight,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class SupabaseImageProvider extends StatelessWidget {
  final String filePath;
  final String? fileName;
  final bool showPlaceholderIcon, person;
  final double iconSize,addIconSize, iconLightOpacity, iconDarkOpacity,loadingIconSize;
  final int? cacheWidth, cacheHeight;

  const SupabaseImageProvider({
    super.key,
    required this.filePath,
    this.fileName,
    this.showPlaceholderIcon = true,
    this.person = false,
    this.iconSize = 24,
    this.addIconSize = 14,
    this.loadingIconSize = 24,
    this.iconLightOpacity = 0.25,
    this.iconDarkOpacity = 0.3,
    this.cacheWidth,
    this.cacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DependencyInjection.getIt<SupabaseImageCubit>(
        param1: filePath,
        param2: fileName,
      ),
      child: SupabaseImage(
        showPlaceholderIcon: showPlaceholderIcon,
        iconSize: iconSize,
        person: person,
        iconLightOpacity: iconLightOpacity,
        iconDarkOpacity: iconDarkOpacity,
        loadingIconSize: loadingIconSize,
        addIconSize: addIconSize,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
      ),
    );
  }
}