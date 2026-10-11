
import 'package:flutter_bloc/flutter_bloc.dart';

class UnitCubit extends Cubit<double> {
  UnitCubit() : super(1000);
  void kilo(){
    emit(1000);
  }
  void gram(){
    emit(1);
  }
  void pound(){
    emit(453.59237);
  }
}
