

import 'package:flutter_bloc/flutter_bloc.dart';

class ObscurityCubit extends Cubit<bool> {
  ObscurityCubit() : super(true);
  void change(){
    emit(!state);
  }
}
