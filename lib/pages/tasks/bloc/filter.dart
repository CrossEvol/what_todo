import 'package:flutter_app/pages/tasks/models/task.dart';

enum FilterStatus { BY_TODAY, BY_WEEK, BY_PROJECT, BY_LABEL, BY_STATUS }

class Filter {
  String? labelName;
  int? projectId;
  FilterStatus? filterStatus;
  TaskStatus? status;

  Filter.byToday() {
    filterStatus = FilterStatus.BY_TODAY;
  }

  Filter.byNextWeek() {
    filterStatus = FilterStatus.BY_WEEK;
  }

  Filter.byProject(this.projectId) {
    filterStatus = FilterStatus.BY_PROJECT;
  }

  Filter.byLabel(this.labelName) {
    filterStatus = FilterStatus.BY_LABEL;
  }

  Filter.byStatus(this.status) {
    filterStatus = FilterStatus.BY_STATUS;
  }

  bool operator ==(o) =>
      o is Filter &&
          o.labelName == labelName &&
          o.projectId == projectId &&
          o.filterStatus == filterStatus &&
          o.status == status;
}