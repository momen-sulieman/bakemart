import 'dart:io';

import 'package:bakemart/core/network/response_result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_image_state.dart';

class SupabaseImageCubit extends Cubit<SupabaseImageState> {
  final SupabaseClient _supabase;
  final String filePath;
  final String? fileName;

  static final Map<String, String> _urlCache = {};

  static String _cacheKey(String filePath, String fileName) =>
      "$filePath/$fileName";

  SupabaseImageCubit(
      this.filePath,
      this.fileName, {
        bool skipInitialFetch = false,
        SupabaseClient? supabase,
      }) : _supabase = supabase ?? Supabase.instance.client,
        super(
        fileName == null
            ? ImageEmpty()
            : (skipInitialFetch ? ImageEmpty() :
        //Todo replace
        // ImageEmpty()
        ImageLoading()
        ),
      ) {
    if (fileName != null && !skipInitialFetch) loadImage();
  }

  Future<void> loadImage({bool bustCache = false}) async {
    if (fileName == null) {
      emit(ImageEmpty());
      return;
    }
    final key = _cacheKey(filePath, fileName!);

    if (!bustCache && _urlCache.containsKey(key)) {
      emit(ImageLoaded(_urlCache[key]!));
      return;
    }

    try {
      final baseUrl =
      _supabase.storage.from(filePath).getPublicUrl("$fileName.jpg");
      final url = bustCache
          ? "$baseUrl?t=${DateTime.now().millisecondsSinceEpoch}"
          : baseUrl;
      _urlCache[key] = url;
      emit(ImageLoaded(url));
    } catch (error) {
      emit(ImageFailure(error.toString()));
    }
  }
  void showLoading() {
    emit(ImageLoading());
  }

  void clear() {
    if (fileName != null) invalidate(filePath, fileName!);
    emit(ImageEmpty());
  }

  Future<bool> pickImage(bool source) async {
    try {
      final image = ImagePicker();
      final pickedImage = source
          ? await image.pickImage(source: ImageSource.camera)
          : await image.pickImage(source: ImageSource.gallery);
      if (pickedImage == null) return false;
      final imageToUpload = File(pickedImage.path);
      if (fileName != null) {
        emit(ImageLoading());
        final uploadResponse = await uploadImage(imageToUpload);
        if (uploadResponse is SuccessResponse<bool>) {
          loadImage(bustCache: true);
          return true;
        } else {
          emit(ImageFailure("Upload failed!"));
          return false;
        }
      } else {
        emit(ImagePicked(imageToUpload));
        return false;
      }
    } catch (error) {
      emit(ImageFailure(error.toString()));
      return false;
    }
  }

  static void invalidate(String filePath, String fileName) {
    _urlCache.remove(_cacheKey(filePath, fileName));
  }

  Future<ResponseResult<bool>> uploadImage(File image, {String? id}) async {
    final targetId = id ?? fileName;
    if (targetId == null) return FailureResponse("No id provided!");
    try {
      await _supabase.storage
          .from(filePath)
          .upload(
            "$targetId.jpg",
            image,
            fileOptions: const FileOptions(upsert: true),
          );
      return SuccessResponse(true);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }
}
