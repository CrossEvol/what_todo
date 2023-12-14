import 'package:flutter_app/pages/home/home_bloc.dart';
import 'package:flutter_app/pages/tasks/bloc/task_bloc.dart';
import 'package:test/test.dart';

void main() {
  group("Home Bloc Test", () {
    test("Updating title Test", () async {
      var homeBloc = HomeBloc();
      expect(
          homeBloc.title,
          emitsInOrder(
            [
              "My Title",
              "My New Title",
            ],
          ));

      homeBloc.updateTitle("My Title");
      homeBloc.updateTitle("My New Title");
    });

    test("Updating Filter Test", () async {
      var homeBloc = HomeBloc();
      expect(
          homeBloc.title,
          emitsInOrder(
            [
              "My Title",
              "My New Title",
              "My Title",
              "My New Title",
            ],
          ));

      expect(
          homeBloc.filter,
          emitsInOrder(
            [
              Filter.byToday(),
              Filter.byProject(1),
              Filter.byLabel("My Label"),
              Filter.byNextWeek(),
            ],
          ));

      homeBloc.applyFilter("My Title", Filter.byToday());
      homeBloc.applyFilter("My New Title", Filter.byProject(1));
      homeBloc.applyFilter("My Title", Filter.byLabel("My Label"));
      homeBloc.applyFilter("My New Title", Filter.byNextWeek());
    });

    test('Updating SCREEN Test', () async {
      var homeBloc = HomeBloc();
      expect(
          homeBloc.screens,
          emitsInOrder(
            [
              SCREEN.ABOUT,
              SCREEN.ADD_TASK,
              SCREEN.HOME,
              SCREEN.COMPLETED_TASK,
              SCREEN.ADD_LABEL,
              SCREEN.ADD_PROJECT,
            ],
          ));

      homeBloc.updateScreen(SCREEN.ABOUT);
      homeBloc.updateScreen(SCREEN.ADD_TASK);
      homeBloc.updateScreen(SCREEN.HOME);
      homeBloc.updateScreen(SCREEN.COMPLETED_TASK);
      homeBloc.updateScreen(SCREEN.ADD_LABEL);
      homeBloc.updateScreen(SCREEN.ADD_PROJECT);
    });
  });
}
