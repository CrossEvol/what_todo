import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/custom_bloc_provider.dart';
import 'package:flutter_app/pages/home/my_home_bloc.dart';
import 'package:flutter_app/pages/home/screen_enum.dart';

extension NavigatorExt on BuildContext {
  void safePop() {
    if (Navigator.of(this).canPop()) {
      Navigator.pop(this, true);
    }
  }

  bool isWiderScreen() {
    return MediaQuery.of(this).size.width > 600;
  }

  adaptiveNavigate(SCREEN screen, Widget widget) async {
    final homeBloc = bloc<MyHomeBloc>();
    if (isWiderScreen()) {
      homeBloc.updateScreen(screen);
    } else {
      await Navigator.push(
        this,
        MaterialPageRoute<bool>(builder: (context) => widget),
      );
    }
  }
}

extension BlocExt on BuildContext {
  T bloc<T extends CustomBlocBase>() {
    return CustomBlocProvider.of(this);
  }
}
