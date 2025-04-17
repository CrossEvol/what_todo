// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh';

  static String m0(error) => "导出错误: ${error}";

  static String m1(path) => "导出成功: ${path}";

  static String m2(maxLength) => "值不能超过${maxLength}个字符";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "aboutTitle": MessageLookupByLibrary.simpleMessage("关于"),
    "addLabel": MessageLookupByLibrary.simpleMessage("添加标签"),
    "addProject": MessageLookupByLibrary.simpleMessage("添加项目"),
    "addTask": MessageLookupByLibrary.simpleMessage("添加任务"),
    "allToToday": MessageLookupByLibrary.simpleMessage("全部移至今天"),
    "apacheLicense": MessageLookupByLibrary.simpleMessage("Apache许可证"),
    "askQuestion": MessageLookupByLibrary.simpleMessage("提问？"),
    "authorName": MessageLookupByLibrary.simpleMessage("Burhanuddin Rashid"),
    "authorSectionTitle": MessageLookupByLibrary.simpleMessage("作者"),
    "authorUsername": MessageLookupByLibrary.simpleMessage("burhanrashid52"),
    "avatarUrl": MessageLookupByLibrary.simpleMessage("头像链接"),
    "cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "cannotReadFile": MessageLookupByLibrary.simpleMessage("无法读取文件"),
    "chooseExportFormat": MessageLookupByLibrary.simpleMessage("选择导出格式"),
    "chooseOption": MessageLookupByLibrary.simpleMessage("选择一个选项:"),
    "comingSoon": MessageLookupByLibrary.simpleMessage("即将推出"),
    "comments": MessageLookupByLibrary.simpleMessage("评论"),
    "completedTasks": MessageLookupByLibrary.simpleMessage("已完成任务"),
    "confirm": MessageLookupByLibrary.simpleMessage("确认"),
    "count": MessageLookupByLibrary.simpleMessage("数量"),
    "delete": MessageLookupByLibrary.simpleMessage("删除"),
    "dueDate": MessageLookupByLibrary.simpleMessage("截止日期"),
    "editTask": MessageLookupByLibrary.simpleMessage("编辑任务"),
    "email": MessageLookupByLibrary.simpleMessage("邮箱"),
    "export": MessageLookupByLibrary.simpleMessage("导出"),
    "exportError": m0,
    "exportFormat": MessageLookupByLibrary.simpleMessage("导出格式"),
    "exportSuccess": m1,
    "exports": MessageLookupByLibrary.simpleMessage("导出"),
    "failedToLoadLabels": MessageLookupByLibrary.simpleMessage("加载标签失败"),
    "failedToLoadProjects": MessageLookupByLibrary.simpleMessage("加载项目失败"),
    "fieldCannotBeEmpty": MessageLookupByLibrary.simpleMessage("字段不能为空"),
    "fileNotFound": MessageLookupByLibrary.simpleMessage("文件未找到"),
    "filePath": MessageLookupByLibrary.simpleMessage("文件路径"),
    "forkGithub": MessageLookupByLibrary.simpleMessage("在GitHub上Fork"),
    "goBack": MessageLookupByLibrary.simpleMessage("返回"),
    "import": MessageLookupByLibrary.simpleMessage("导入"),
    "importDescription": MessageLookupByLibrary.simpleMessage(
      "从之前导出的JSON文件导入任务。",
    ),
    "importError": MessageLookupByLibrary.simpleMessage("导入错误"),
    "importFile": MessageLookupByLibrary.simpleMessage("导入文件"),
    "importInfoAutoDetect": MessageLookupByLibrary.simpleMessage("• 导入将自动检测格式"),
    "importInfoItemsCreated": MessageLookupByLibrary.simpleMessage(
      "• 将根据需要创建项目和标签",
    ),
    "importInfoLegacySupport": MessageLookupByLibrary.simpleMessage(
      "• 支持v0（旧版）和v1（新版）格式",
    ),
    "importInfoTasksAdded": MessageLookupByLibrary.simpleMessage(
      "• 所有导入的任务将添加到您的任务列表中",
    ),
    "importInformation": MessageLookupByLibrary.simpleMessage("导入信息"),
    "importSuccess": MessageLookupByLibrary.simpleMessage("导入成功"),
    "importing": MessageLookupByLibrary.simpleMessage("导入中..."),
    "importingData": MessageLookupByLibrary.simpleMessage("正在导入数据..."),
    "importingWait": MessageLookupByLibrary.simpleMessage("请等待数据导入完成。"),
    "imports": MessageLookupByLibrary.simpleMessage("导入"),
    "inbox": MessageLookupByLibrary.simpleMessage("收件箱"),
    "invalidJsonFormat": MessageLookupByLibrary.simpleMessage("无效的JSON格式"),
    "labelAlreadyExists": MessageLookupByLibrary.simpleMessage("标签已存在"),
    "labelCannotBeEmpty": MessageLookupByLibrary.simpleMessage("标签名称不能为空"),
    "labelGrid": MessageLookupByLibrary.simpleMessage("标签网格"),
    "labelName": MessageLookupByLibrary.simpleMessage("标签名称"),
    "labels": MessageLookupByLibrary.simpleMessage("标签"),
    "legacyFormat": MessageLookupByLibrary.simpleMessage("旧版格式"),
    "legacyFormatV0": MessageLookupByLibrary.simpleMessage("旧版格式 (v0)"),
    "licenseText": MessageLookupByLibrary.simpleMessage(
      "版权所有 2020 Burhanuddin Rashid\n\n根据Apache许可证2.0版（\"许可证\"）获得许可；除非遵守许可证，否则您不得使用此文件。您可以在以下位置获取许可证副本：\n\nhttp://www.apache.org/licenses/LICENSE-2.0\n\n除非适用法律要求或书面同意，否则根据许可证分发的软件是基于\"按原样\"分发的，没有任何明示或暗示的保证或条件。有关许可证下特定语言的权限和限制，请参阅许可证。",
    ),
    "name": MessageLookupByLibrary.simpleMessage("姓名"),
    "newFormat": MessageLookupByLibrary.simpleMessage("新版格式"),
    "newFormatV1": MessageLookupByLibrary.simpleMessage("新版格式 (v1)"),
    "next7Days": MessageLookupByLibrary.simpleMessage("未来7天"),
    "noComments": MessageLookupByLibrary.simpleMessage("无评论"),
    "noFileSelected": MessageLookupByLibrary.simpleMessage("未选择文件"),
    "noLabels": MessageLookupByLibrary.simpleMessage("无标签"),
    "noReminder": MessageLookupByLibrary.simpleMessage("无提醒"),
    "noTaskAdded": MessageLookupByLibrary.simpleMessage("未添加任务"),
    "onlyRemoveLabel": MessageLookupByLibrary.simpleMessage("仅删除标签"),
    "onlyRemoveProject": MessageLookupByLibrary.simpleMessage("仅删除项目"),
    "orderTest": MessageLookupByLibrary.simpleMessage("排序测试"),
    "pickFile": MessageLookupByLibrary.simpleMessage("选择文件"),
    "pickImage": MessageLookupByLibrary.simpleMessage("选择图片"),
    "postponeTasks": MessageLookupByLibrary.simpleMessage("推迟任务"),
    "priority": MessageLookupByLibrary.simpleMessage("优先级"),
    "profile": MessageLookupByLibrary.simpleMessage("个人资料"),
    "project": MessageLookupByLibrary.simpleMessage("项目"),
    "projectAlreadyExists": MessageLookupByLibrary.simpleMessage("项目已存在"),
    "projectGrid": MessageLookupByLibrary.simpleMessage("项目网格"),
    "projectName": MessageLookupByLibrary.simpleMessage("项目名称"),
    "projectNameCannotBeEmpty": MessageLookupByLibrary.simpleMessage(
      "项目名称不能为空",
    ),
    "projects": MessageLookupByLibrary.simpleMessage("项目"),
    "reminder": MessageLookupByLibrary.simpleMessage("提醒"),
    "removeLabel": MessageLookupByLibrary.simpleMessage("删除标签"),
    "removeProject": MessageLookupByLibrary.simpleMessage("删除项目"),
    "removeRelatedTasks": MessageLookupByLibrary.simpleMessage("删除相关任务"),
    "reportIssueSubtitle": MessageLookupByLibrary.simpleMessage("遇到问题？在这里报告"),
    "reportIssueTitle": MessageLookupByLibrary.simpleMessage("报告问题"),
    "selectLabels": MessageLookupByLibrary.simpleMessage("选择标签"),
    "selectPriority": MessageLookupByLibrary.simpleMessage("选择优先级"),
    "selectProject": MessageLookupByLibrary.simpleMessage("选择项目"),
    "sendEmail": MessageLookupByLibrary.simpleMessage("发送邮件"),
    "settings": MessageLookupByLibrary.simpleMessage("设置"),
    "storagePermissionRequired": MessageLookupByLibrary.simpleMessage("需要存储权限"),
    "takePhoto": MessageLookupByLibrary.simpleMessage("拍照"),
    "taskCompleted": MessageLookupByLibrary.simpleMessage("任务已完成"),
    "taskDeleted": MessageLookupByLibrary.simpleMessage("任务已删除"),
    "taskTitle": MessageLookupByLibrary.simpleMessage("标题"),
    "tasks": MessageLookupByLibrary.simpleMessage("任务"),
    "titleCannotBeEmpty": MessageLookupByLibrary.simpleMessage("标题不能为空"),
    "today": MessageLookupByLibrary.simpleMessage("今天"),
    "uncompletedTasks": MessageLookupByLibrary.simpleMessage("未完成任务"),
    "unknown": MessageLookupByLibrary.simpleMessage("未知"),
    "unknownNotImplemented": MessageLookupByLibrary.simpleMessage("未知功能尚未实现。"),
    "valueTooLong": m2,
    "versionTitle": MessageLookupByLibrary.simpleMessage("版本"),
  };
}
