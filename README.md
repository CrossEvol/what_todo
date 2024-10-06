
# References:
[Origin WhatTodo](https://github.com/burhanrashid52/WhatTodo) <br/>
the project is not build on the [bloc](https://bloclibrary.dev/), I want to rebuild it to `flutter_bloc`

# Todo:
- ~~mobile can not update title properly, it will commit updateTask several times, and preserve the origin at the db level~~
- ~~the desktop can update title, but the mobile will flashback~~
- ~~after update the task, it will be freeze and I can not edit again. but after I create a new task , I can edit anyone .~~
- remove origin bloc logic which is coupled with add_task
- remove origin bloc logic which is coupled with edit_task
- remove origin bloc logic which is coupled with completed_tasks
- remove origin bloc logic which is coupled with uncompleted_tasks