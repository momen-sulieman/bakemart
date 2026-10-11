part of 'settings_update_cubit.dart';

enum SettingsUpdateAction { supervisor, deleteWorker, addWorker,other }

abstract class SettingsUpdateState {}

final class SettingsUpdateInitial extends SettingsUpdateState {}

final class SettingsUpdateLoading extends SettingsUpdateState {
  final String? targetId;
  final SettingsUpdateAction action;

  SettingsUpdateLoading({this.targetId, this.action = SettingsUpdateAction.other});
}