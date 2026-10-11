

import 'package:flutter_bloc/flutter_bloc.dart';

class QuantityCounterCubit extends Cubit<int> {
  QuantityCounterCubit() : super(0);
  void plusOne(){
    emit(state+1);
  }
  void plusTen(){
    emit(state+10);
  }
  void plusHundred(){
    emit(state+100);
  }
  void minusOne(){
    if(state>0) emit(state-1);
  }
  void minusTen(){
    if(state>=10) emit(state-10);
  }
  void minusHundred(){
    if(state>=100) emit(state-100);
  }
}
