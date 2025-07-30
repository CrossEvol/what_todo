import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/admin/admin_bloc.dart';
import 'package:flutter_app/constants/color_constant.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  late AdminBloc adminBloc;

  setUp(() {
    adminBloc = AdminBloc();
  });

  tearDown(() {
    adminBloc.close();
  });

  group('AdminBloc', () {
    test('initial state is AdminInitialState', () {
      expect(adminBloc.state, isA<AdminInitialState>());
    });

    blocTest<AdminBloc, AdminState>(
      'updates color selection when AdminUpdateColorSelectionEvent is added',
      build: () => adminBloc,
      act: (bloc) => bloc.add(AdminUpdateColorSelectionEvent(
          colorPalette: ColorPalette("Red", Colors.red.value))),
      expect: () => [
        isA<AdminState>().having((state) => state.colorPalette.colorName,
            'colorPalette name', "Red"),
      ],
    );
  });
}
