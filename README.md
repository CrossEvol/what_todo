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

## 2025/04/17
fix a crash issue.
see the output of `git log`
```shell
$ git log 
commit 5243cfb0649215f96e81337b6703fd8b82b00677 (HEAD -> master, tag: v1.0.6, origin/master)
Author: 创圣大天使Evol <296662402@qq.com>
Date:   Thu Apr 17 09:45:43 2025 +0800

    optimize handle for Export and Import functionality
    - move Export and Import from PopMenuItem to SideDrawer
    - move export() and import() logic to corresponding pages ExportPage and ImportPage
    - supplement ExportBloc and ImportBloc
    - intl support
    - bump version to v1.0.6

commit 71a76f34714861776a2596bb4d39445166d9ee80
Author: 创圣大天使Evol <296662402@qq.com>
Date:   Thu Apr 17 08:59:48 2025 +0800

    NFC. rename LabelPage → LabelsExpansionTile, rename ProjectPage → ProjectsExpansionTile

commit 7d733e88063800cb703ee2a1e6e484b5f6b0f37b
Author: 创圣大天使Evol <296662402@qq.com>
:...skipping...
commit 5243cfb0649215f96e81337b6703fd8b82b00677 (HEAD -> master, tag: v1.0.6, origin/master)
Author: 创圣大天使Evol <296662402@qq.com>
Date:   Thu Apr 17 09:45:43 2025 +0800

    optimize handle for Export and Import functionality
    - move Export and Import from PopMenuItem to SideDrawer
    - move export() and import() logic to corresponding pages ExportPage and ImportPage
    - supplement ExportBloc and ImportBloc
    - intl support
    - bump version to v1.0.6

commit 71a76f34714861776a2596bb4d39445166d9ee80
Author: 创圣大天使Evol <296662402@qq.com>
Date:   Thu Apr 17 08:59:48 2025 +0800

    NFC. rename LabelPage → LabelsExpansionTile, rename ProjectPage → ProjectsExpansionTile

commit 7d733e88063800cb703ee2a1e6e484b5f6b0f37b
Author: 创圣大天使Evol <296662402@qq.com>
Date:   Thu Apr 17 08:53:44 2025 +0800

    when add project or label, handle the case that project or label has been existed

commit 66990adf7ccc90771e178602ae1bfc698adaa8b1
Author: 创圣大天使Evol <296662402@qq.com>
Date:   Sun Apr 13 20:31:17 2025 +0800

    fix the NavigatorPop error inside `add_label.dart` which has provided by AI previously


commit d5fa2975725fcbf23dc9f989f25a540cf9f27dc4
Author: 创圣大天使Evol <296662402@qq.com>
Date:   Sun Apr 13 20:08:45 2025 +0800

    update import and export methods to V1

commit 5e3a0601372880179f22fd47b24424df3db50268 (04_13_before_im_ex)
Author: 创圣大天使Evol <296662402@qq.com>
Date:   Sun Apr 13 15:38:09 2025 +0800

    change Scroll Restoration approach from RestorationMixin to ScrollController and scrollPosition from global state

commit 7788a86119f11fc946b81795724c4f2161147e57 (04_13_first)
Author: 创圣大天使Evol <296662402@qq.com>
Date:   Sun Apr 13 15:21:55 2025 +0800

    NFC. remove git trace for android/app/.cxx

commit 142fdd14acc31219bdd0cbbc96da28e653ad888d (04_12)
Author: 创圣大天使Evol <296662402@qq.com>
Date:   Sat Apr 12 21:06:26 2025 +0800

    use `with RestorationMixin` && `ScrollController` && `RestorableDouble` to impl remember scroll position for HomePage
```

from the start of commit in the time of `Apr 12`, the app only can run in the debug mode. the release app can bootstrap, but in windows, it only run in the background , in android, it only render the empty page and can not do any operations

the commit between `Apr 12` and `Apr 13` has two key changes, one is I ignore the `android/app/.cxx`, the other is I add the `logger.info()` in the main.dart

finally, I found that the reason why the app crash is that it can not setup Logger correctly 

for windows , in `main.dart`, convert `setupLogger();`  to `await setupLogger();` can solve the problem 

but in android , it is not enough, so I comment the `logger.info("TodoApp boostraping....");` in `main.dart`

it seems that it works.

## 2025/04/18
```dart
class BlocProvider<T extends StateStreamableSource<Object?>>
    extends SingleChildStatelessWidget {
  /// {@macro bloc_provider}
  const BlocProvider({
    required T Function(BuildContext context) create,
    Key? key,
    this.child,
    this.lazy = true,
  })  : _create = create,
        _value = null,
        super(key: key, child: child);
  // ...
}
```
Some BlocProvider should set lazy to false , 
```dart
BlocProvider(
    create: (_) =>
    SettingsBloc(SettingsDB.get())
    ..add(LoadSettingsEvent())..add(
    AddSetLocaleFunction(setLocale: setLocale)),
    lazy: false,
)
```
although it will load the settings state eagerly on windows 