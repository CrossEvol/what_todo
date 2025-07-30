part of 'admin_bloc.dart';

sealed class AdminState extends Equatable {
  final ColorPalette colorPalette;

  const AdminState({
    required this.colorPalette,
  });

  @override
  List<Object> get props => [colorPalette];

  AdminLoadedState copyWith({ColorPalette? colorPalette}) {
    return AdminLoadedState(
      colorPalette: colorPalette ?? this.colorPalette,
    );
  }
}

final class AdminInitialState extends AdminState {
  AdminInitialState({required super.colorPalette});
}

final class AdminLoadedState extends AdminState {
  AdminLoadedState({required super.colorPalette});
}
