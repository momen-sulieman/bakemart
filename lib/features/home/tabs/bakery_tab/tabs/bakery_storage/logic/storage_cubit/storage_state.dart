part of 'storage_cubit.dart';

abstract class StorageState {}

final class StorageLoading extends StorageState {}
final class StorageSucces extends StorageState {
  StorageModel storage;
  bool inputValidity;
  StorageSucces(this.storage,{required this.inputValidity});
}
final class StorageFailure extends StorageState {
  String error;
  StorageFailure(this.error);
}
