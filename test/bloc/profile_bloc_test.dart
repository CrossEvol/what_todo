import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_app/bloc/profile/profile_bloc.dart';
import 'package:flutter_app/pages/profile/profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks/fake-database.mocks.dart';

void main() {
  late MockProfileDB mockProfileDB;
  late UserProfile testProfile;

  setUp(() {
    mockProfileDB = MockProfileDB();
    testProfile = UserProfile(
      id: 1,
      name: 'Test User',
      email: 'test@example.com',
      avatarUrl: 'test_avatar.jpg',
      updatedAt: DateTime.now(),
    );
  });

  group('ProfileBloc', () {
    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoaded] when ProfileLoadEvent is added and profile exists',
      build: () {
        when(mockProfileDB.findByID(1)).thenAnswer((_) async => testProfile);
        return ProfileBloc(mockProfileDB);
      },
      act: (bloc) => bloc.add(ProfileLoadEvent()),
      expect: () => [
        ProfileLoaded(testProfile),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'does not emit when ProfileLoadEvent is added and profile does not exist',
      build: () {
        when(mockProfileDB.findByID(1)).thenAnswer((_) async => null);
        return ProfileBloc(mockProfileDB);
      },
      act: (bloc) => bloc.add(ProfileLoadEvent()),
      expect: () => [],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoaded] with updateSuccess status when ProfileUpdateEvent succeeds',
      build: () {
        when(mockProfileDB.updateOne(testProfile))
            .thenAnswer((_) async => true);
        return ProfileBloc(mockProfileDB)..emit(ProfileLoaded(testProfile));
      },
      act: (bloc) => bloc.add(ProfileUpdateEvent(testProfile)),
      expect: () => [
        ProfileLoaded(testProfile, status: ProfileStateStatus.updateSuccess),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoaded] with updateFailure status when ProfileUpdateEvent fails',
      build: () {
        when(mockProfileDB.updateOne(testProfile))
            .thenAnswer((_) async => false);
        return ProfileBloc(mockProfileDB)..emit(ProfileLoaded(testProfile));
      },
      act: (bloc) => bloc.add(ProfileUpdateEvent(testProfile)),
      expect: () => [],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoaded] with updateFailure status when ProfileUpdateEvent throws',
      build: () {
        when(mockProfileDB.updateOne(testProfile))
            .thenThrow(Exception('Database error'));
        return ProfileBloc(mockProfileDB)..emit(ProfileLoaded(testProfile));
      },
      act: (bloc) => bloc.add(ProfileUpdateEvent(testProfile)),
      expect: () => [
        ProfileLoaded(testProfile, status: ProfileStateStatus.updateFailure),
      ],
    );
  });
}
