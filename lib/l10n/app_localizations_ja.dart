// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get inbox => '受信トレイ';

  @override
  String get today => '今日';

  @override
  String get next7Days => '次の7日間';

  @override
  String get projectGrid => 'プロジェクトグリッド';

  @override
  String get labelGrid => 'ラベルグリッド';

  @override
  String get settings => '設定';

  @override
  String get orderTest => '順序テスト';

  @override
  String get unknown => '不明';

  @override
  String get unknownNotImplemented => '不明な機能は実装されていません。';

  @override
  String get aboutTitle => 'アプリについて';

  @override
  String get reportIssueTitle => '問題を報告';

  @override
  String get reportIssueSubtitle => '問題がありますか？ここで報告してください';

  @override
  String get versionTitle => 'バージョン';

  @override
  String get authorSectionTitle => '作者';

  @override
  String get authorName => 'Burhanuddin Rashid';

  @override
  String get authorUsername => 'burhanrashid52';

  @override
  String get forkGithub => 'GitHubでフォーク';

  @override
  String get sendEmail => 'メールを送信';

  @override
  String get askQuestion => '質問する？';

  @override
  String get apacheLicense => 'Apacheライセンス';

  @override
  String get licenseText => 'Copyright 2020 Burhanuddin Rashid\n\nApache License Version 2.0（以下「ライセンス」）に基づいてライセンスされています。あなたはライセンスに従う場合を除き、このファイルを使用することはできません。ライセンスのコピーは下記から入手できます。\n\nhttp://www.apache.org/licenses/LICENSE-2.0\n\n適用される法律で要求されるか、書面で合意されない限り、このライセンスの下で配布されるソフトウェアは、「現状のまま」で、明示または黙示を問わず、いかなる保証も条件もなしに提供されます。ライセンスの下での許可と制限を規定する特定の言語についてはライセンスを参照してください。';

  @override
  String get projects => 'プロジェクト';

  @override
  String get addProject => 'プロジェクトを追加';

  @override
  String get labels => 'ラベル';

  @override
  String get addLabel => 'ラベルを追加';

  @override
  String get failedToLoadProjects => 'プロジェクトの読み込みに失敗しました';

  @override
  String get failedToLoadLabels => 'ラベルの読み込みに失敗しました';

  @override
  String get addTask => 'タスクを追加';

  @override
  String get taskTitle => 'タイトル';

  @override
  String get titleCannotBeEmpty => 'タイトルを入力してください';

  @override
  String get project => 'プロジェクト';

  @override
  String get editTask => 'タスクを編集';

  @override
  String get dueDate => '期限';

  @override
  String get priority => '優先度';

  @override
  String get selectPriority => '優先度を選択';

  @override
  String get selectProject => 'プロジェクトを選択';

  @override
  String get selectLabels => 'ラベルを選択';

  @override
  String get comments => 'コメント';

  @override
  String get noComments => 'コメントなし';

  @override
  String get reminder => 'リマインダー';

  @override
  String get noReminder => 'リマインダーなし';

  @override
  String get comingSoon => '近日公開';

  @override
  String get noLabels => 'ラベルなし';

  @override
  String get labelName => 'ラベル名';

  @override
  String get labelCannotBeEmpty => 'ラベル名を入力してください';

  @override
  String get labelAlreadyExists => 'ラベルが既に存在します';

  @override
  String get projectName => 'プロジェクト名';

  @override
  String get projectNameCannotBeEmpty => 'プロジェクト名を入力してください';

  @override
  String get completedTasks => '完了した��ク';

  @override
  String get uncompletedTasks => '未完了のタスク';

  @override
  String get allToToday => 'すべて今日へ';

  @override
  String get postponeTasks => 'タスクを延期';

  @override
  String get exports => 'エクスポート';

  @override
  String get imports => 'インポート';

  @override
  String get profile => 'プロフィール';

  @override
  String get name => '名前';

  @override
  String get email => 'メールアドレス';

  @override
  String get avatarUrl => 'アバターURL';

  @override
  String get pickImage => '画像を選択';

  @override
  String get takePhoto => '写真を撮影';

  @override
  String get importFile => 'ファイルをインポート';

  @override
  String get filePath => 'ファイルパス';

  @override
  String get pickFile => 'ファイルを選択';

  @override
  String get cancel => 'キャンセル';

  @override
  String get confirm => '確認';

  @override
  String get noFileSelected => 'ファイルが選択されていません';

  @override
  String get noTaskAdded => 'タスクがありません';

  @override
  String get taskCompleted => 'タスクを完了しました';

  @override
  String get taskDeleted => 'タスクを削除しました';

  @override
  String get fieldCannotBeEmpty => 'フィールドは空にできません';

  @override
  String valueTooLong(int maxLength) {
    return '値は$maxLength文字を超えることはできません';
  }
}
