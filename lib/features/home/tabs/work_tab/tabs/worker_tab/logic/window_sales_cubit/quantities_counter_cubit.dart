
import 'package:flutter_bloc/flutter_bloc.dart';

class QuantitiesCounterCubit extends Cubit<List<int>> {
  QuantitiesCounterCubit() : super([0,0,0]);
  void soldPlusOne(){
    emit([state[0]+1,state[1],state[2]]);
  }
  void soldPlusTen(){
    emit([state[0]+10,state[1],state[2]]);
  }
  void soldPlusHundred(){
    emit([state[0]+100,state[1],state[2]]);
  }
  void soldMinusOne(){
    emit([state[0]-1,state[1],state[2]]);
  }
  void soldMinusTen(){
    emit([state[0]-10,state[1],state[2]]);
  }
  void soldMinusHundred(){
    emit([state[0]-100,state[1],state[2]]);
  }
  void notSoldPlusOne(){
    emit([state[0],state[1]+1,state[2]]);
  }
  void notSoldPlusTen(){
    emit([state[0],state[1]+10,state[2]]);
  }
  void notSoldPlusHundred(){
    emit([state[0],state[1]+100,state[2]]);
  }
  void notSoldMinusOne(){
    emit([state[0],state[1]-1,state[2]]);
  }
  void notSoldMinusTen(){
    emit([state[0],state[1]-10,state[2]]);
  }
  void notSoldMinusHundred(){
    emit([state[0],state[1]-100,state[2]]);
  }
  void mealPlusOne(){
    emit([state[0],state[1],state[2]+1]);
  }
  void mealPlusTen(){
    emit([state[0],state[1],state[2]+10]);
  }
  void mealPlusHundred(){
    emit([state[0],state[1],state[2]+100]);
  }
  void mealMinusOne(){
    emit([state[0],state[1],state[2]-1]);
  }
  void mealMinusTen(){
    emit([state[0],state[1],state[2]-10]);
  }
  void mealMinusHundred(){
    emit([state[0],state[1],state[2]-100]);
  }
}
