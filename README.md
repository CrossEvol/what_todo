# References:

[Origin WhatTodo](https://github.com/burhanrashid52/WhatTodo) <br/>
the project is not build on the [bloc](https://bloclibrary.dev/), I want to rebuild it
to `flutter_bloc`

# cautions

- add `--dart-define=IS_TEST=true` to control test database.
- `test/` can be run in `flutter test` directly, but the `integration_test` can not.

# Todo:

- ~~mobile can not update title properly, it will commit updateTask several times, and preserve the
  origin at the db level~~
- ~~the desktop can update title, but the mobile will flashback~~
- ~~after update the task, it will be freeze and I can not edit again. but after I create a new
  task , I can edit anyone .~~
- ~~remove origin bloc logic which is coupled with add_task~~
- ~~remove origin bloc logic which is coupled with edit_task~~
- ~~remove origin bloc logic which is coupled with completed_tasks~~
- ~~remove origin bloc logic which is coupled with uncompleted_tasks~~
- ~~apply PopScope as more as possible~~
- ~~migrate database properly. I do not want to delete data again. maybe I can export the data.~~
- ~~switch theme mode ~~
- ~~i18n~~
- send email
- ~~export data~~
- ~~import data~~
- ~~dateTime in db from int -> string~~
- tidy up tests 

# Update
## 2025/04/05
### flutter-generate-i10n-source
see [breaking-changes/flutter-generate-i10n-source](https://docs.flutter.dev/release/breaking-changes/flutter-generate-i10n-source)
besides the migrate guide, should use the flutter-intl tool to generate the code , this tool has been integrated into android studio 

### not rely on `.flutter-plugins` any more
see [flutter-plugins-configuration]https://docs.flutter.dev/release/breaking-changes/flutter-plugins-configuration