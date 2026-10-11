import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreenCubit extends Cubit<int> {
  HomeScreenCubit() : super(1);

  void changeTab(int index) => emit(index);
}
