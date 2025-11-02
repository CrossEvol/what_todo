// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get inbox => '收件箱';

  @override
  String get today => '今天';

  @override
  String get next7Days => '未来7天';

  @override
  String get projectGrid => '项目网格';

  @override
  String get labelGrid => '标签网格';

  @override
  String get settings => '设置';

  @override
  String get orderTest => '排序测试';

  @override
  String get unknown => '未知';

  @override
  String get unknownNotImplemented => '未知功能尚未实现。';

  @override
  String get aboutTitle => '关于';

  @override
  String get reportIssueTitle => '报告问题';

  @override
  String get reportIssueSubtitle => '遇到问题？在这里报告';

  @override
  String get versionTitle => '版本';

  @override
  String get authorSectionTitle => '作者';

  @override
  String get authorName => 'Burhanuddin Rashid';

  @override
  String get authorUsername => 'burhanrashid52';

  @override
  String get forkGithub => '在GitHub上Fork';

  @override
  String get sendEmail => '发送邮件';

  @override
  String get askQuestion => '提问？';

  @override
  String get apacheLicense => 'Apache许可证';

  @override
  String get licenseText =>
      '版权所有 2020 Burhanuddin Rashid\n\n根据Apache许可证2.0版（\"许可证\"）获得许可；除非遵守许可证，否则您不得使用此文件。您可以在以下位置获取许可证副本：\n\nhttp://www.apache.org/licenses/LICENSE-2.0\n\n除非适用法律要求或书面同意，否则根据许可证分发的软件是基于\"按原样\"分发的，没有任何明示或暗示的保证或条件。有关许可证下特定语言的权限和限制，请参阅许可证。';

  @override
  String get projects => '项目';

  @override
  String get addProject => '添加项目';

  @override
  String get labels => '标签';

  @override
  String get addLabel => '添加标签';

  @override
  String get failedToLoadProjects => '加载项目失败';

  @override
  String get failedToLoadLabels => '加载标签失败';

  @override
  String get addTask => '添加任务';

  @override
  String get taskTitle => '标题';

  @override
  String get titleCannotBeEmpty => '标题不能为空';

  @override
  String get project => '项目';

  @override
  String get editTask => '编辑任务';

  @override
  String get dueDate => '截止日期';

  @override
  String get priority => '优先级';

  @override
  String get selectPriority => '选择优先级';

  @override
  String get selectProject => '选择项目';

  @override
  String get selectLabels => '选择标签';

  @override
  String get comments => '评论';

  @override
  String get noComments => '无评论';

  @override
  String get reminder => '提醒';

  @override
  String get noReminder => '无提醒';

  @override
  String get comingSoon => '即将推出';

  @override
  String get noLabels => '无标签';

  @override
  String get labelName => '标签名称';

  @override
  String get labelCannotBeEmpty => '标签名称不能为空';

  @override
  String get labelAlreadyExists => '标签已存在';

  @override
  String get projectName => '项目名称';

  @override
  String get projectNameCannotBeEmpty => '项目名称不能为空';

  @override
  String get projectAlreadyExists => '项目已存在';

  @override
  String get completedTasks => '已完成任务';

  @override
  String get uncompletedTasks => '未完成任务';

  @override
  String get done => '完成';

  @override
  String get undone => '未完成';

  @override
  String get allToToday => '全部移至今天';

  @override
  String get postponeTasks => '推迟任务';

  @override
  String get exports => '导出';

  @override
  String get imports => '导入';

  @override
  String get profile => '个人资料';

  @override
  String get name => '姓名';

  @override
  String get email => '邮箱';

  @override
  String get avatarUrl => '头像链接';

  @override
  String get pickImage => '选择图片';

  @override
  String get takePhoto => '拍照';

  @override
  String get importFile => '导入文件';

  @override
  String get filePath => '文件路径';

  @override
  String get pickFile => '选择文件';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确认';

  @override
  String get noFileSelected => '未选择文件';

  @override
  String get importSuccess => '导入成功';

  @override
  String get importError => '导入错误';

  @override
  String get chooseExportFormat => '选择导出格式';

  @override
  String get legacyFormat => '旧版格式';

  @override
  String get newFormat => '新版格式';

  @override
  String get export => '导出';

  @override
  String get tasks => '任务';

  @override
  String get delete => '删除';

  @override
  String get removeProject => '删除项目';

  @override
  String get removeLabel => '删除标签';

  @override
  String get chooseOption => '选择一个选项:';

  @override
  String get removeRelatedTasks => '删除相关任务';

  @override
  String get onlyRemoveProject => '仅删除项目';

  @override
  String get onlyRemoveLabel => '仅删除标签';

  @override
  String get exportFormat => '导出格式';

  @override
  String get legacyFormatV0 => '旧版格式 (v0)';

  @override
  String get newFormatV1 => '新版格式 (v1)';

  @override
  String exportSuccess(String path) {
    return '导出成功: $path';
  }

  @override
  String exportError(String error) {
    return '导出错误: $error';
  }

  @override
  String get storagePermissionRequired => '需要存储权限';

  @override
  String get count => '数量';

  @override
  String get noTaskAdded => '未添加任务';

  @override
  String get taskCompleted => '任务已完成';

  @override
  String get taskDeleted => '任务已删除';

  @override
  String get fieldCannotBeEmpty => '字段不能为空';

  @override
  String valueTooLong(int maxLength) {
    return '值不能超过$maxLength个字符';
  }

  @override
  String get import => '导入';

  @override
  String get importDescription => '从之前导出的JSON文件导入任务。';

  @override
  String get importing => '导入中...';

  @override
  String get importInformation => '导入信息';

  @override
  String get importInfoLegacySupport => '• 支持v0（旧版）和v1（新版）格式';

  @override
  String get importInfoAutoDetect => '• 导入将自动检测格式';

  @override
  String get importInfoTasksAdded => '• 所有导入的任务将添加到您的任务列表中';

  @override
  String get importInfoItemsCreated => '• 将根据需要创建项目和标签';

  @override
  String get importingData => '正在导入数据...';

  @override
  String get importingWait => '请等待数据导入完成。';

  @override
  String get fileNotFound => '文件未找到';

  @override
  String get cannotReadFile => '无法读取文件';

  @override
  String get invalidJsonFormat => '无效的JSON格式';

  @override
  String get goBack => '返回';

  @override
  String get controls => '控制項';

  @override
  String get taskGrid => '任务网格';

  @override
  String get manageResources => '管理资源';

  @override
  String get retry => '重试';

  @override
  String get noResourcesAttached => '未附加任何资源';

  @override
  String get tapAddToAttachImages => '点击“+”按钮以附加图片';

  @override
  String get addResource => '添加资源';

  @override
  String get resourceDeleted => '资源已删除';

  @override
  String get viewFullSize => '查看原图';

  @override
  String get confirmDelete => '确认删除';

  @override
  String get deleteResourceConfirmation => '确定要删除此资源吗？此操作无法撤销。';

  @override
  String get gallery => '相册';

  @override
  String get camera => '相机';
}
