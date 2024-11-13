import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_app/bloc/label/label_bloc.dart';
import 'package:flutter_app/constants/color_constant.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks/fake-database.mocks.dart';

void main() {
  late MockLabelDB mockLabelDB;
  late LabelBloc labelBloc;

  setUp(() {
    mockLabelDB = MockLabelDB();
    labelBloc = LabelBloc(mockLabelDB);
  });

  tearDown(() {
    labelBloc.close();
  });

  group('LabelBloc', () {
    final testLabels = [
      Label.create('Test Label 1', 0xFF000000, 'Black'),
      Label.create('Test Label 2', 0xFFFFFFFF, 'White'),
    ];

    test('initial state should be LabelInitial', () {
      expect(labelBloc.state, isA<LabelInitial>());
    });

    blocTest<LabelBloc, LabelState>(
      'emits [LabelLoading, LabelsLoaded] when LoadLabelsEvent is added successfully',
      build: () {
        when(mockLabelDB.getLabels()).thenAnswer((_) async => testLabels);
        return labelBloc;
      },
      act: (bloc) => bloc.add(LoadLabelsEvent()),
      expect: () => [
        isA<LabelLoading>(),
        isA<LabelsLoaded>().having(
          (state) => state.labels,
          'labels',
          equals(testLabels),
        ),
      ],
    );

    blocTest<LabelBloc, LabelState>(
      'emits [LabelLoading, LabelError] when LoadLabelsEvent fails',
      build: () {
        when(mockLabelDB.getLabels()).thenThrow(Exception('Database error'));
        return labelBloc;
      },
      act: (bloc) => bloc.add(LoadLabelsEvent()),
      expect: () => [
        isA<LabelLoading>(),
        isA<LabelError>().having(
          (state) => state.message,
          'error message',
          equals('Failed to load labels'),
        ),
      ],
    );

    blocTest<LabelBloc, LabelState>(
      'emits [LabelExistenceChecked] when CreateLabelEvent is added',
      build: () {
        final testLabel = Label.create('Test Label', 0xFF000000, 'Black');
        when(mockLabelDB.isLabelExits(testLabel)).thenAnswer((_) async => true);
        return labelBloc;
      },
      act: (bloc) => bloc.add(CreateLabelEvent(
        Label.create('Test Label', 0xFF000000, 'Black'),
      )),
      expect: () => [
        isA<LabelExistenceChecked>().having(
          (state) => state.exists,
          'exists',
          equals(true),
        ),
      ],
    );

    blocTest<LabelBloc, LabelState>(
      'emits [ColorSelectionUpdated] when UpdateColorSelectionEvent is added',
      build: () => labelBloc,
      act: (bloc) => bloc.add(UpdateColorSelectionEvent(colorsPalettes[0])),
      expect: () => [
        isA<ColorSelectionUpdated>().having(
          (state) => state.colorPalette,
          'colorPalette',
          equals(colorsPalettes[0]),
        ),
      ],
    );
  });
}
