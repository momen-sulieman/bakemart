part of 'supabase_image_cubit.dart';

abstract class SupabaseImageState {}

final class ImageLoading extends SupabaseImageState {}
final class ImageEmpty extends SupabaseImageState {}
final class ImageFailure extends SupabaseImageState {
  String error;
  ImageFailure(this.error);
}
final class ImageLoaded extends SupabaseImageState {
  String imageUrl;
  ImageLoaded(this.imageUrl);
}
final class ImagePicked extends SupabaseImageState {
  File imageFile;
  ImagePicked(this.imageFile);
}