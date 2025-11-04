import 'package:flutter/material.dart';
import 'package:flutter_app/constants/app_constant.dart';
import 'package:flutter_app/utils/app_util.dart';
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart' show PackageInfo;

class AboutUsScreen extends StatefulWidget {
  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  String _version = '...'; // 2. 创建一个变量来存储版本号，并设置初始值

  @override
  void initState() {
    super.initState();
    _initPackageInfo(); // 3. 在 initState 中调用方法获取版本信息
  }

  // 异步方法来获取版本信息并更新状态
  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _version = info.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.aboutTitle,
          key: ValueKey(AboutUsKeys.TITLE_ABOUT),
        ),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: <Widget>[
              Card(
                child: Column(
                  children: <Widget>[
                    ListTile(
                        leading: Icon(Icons.bug_report, color: Colors.black),
                        title: Text(
                          AppLocalizations.of(context)!.reportIssueTitle,
                          key: ValueKey(AboutUsKeys.TITLE_REPORT),
                        ),
                        subtitle: Text(
                          AppLocalizations.of(context)!.reportIssueSubtitle,
                          key: ValueKey(AboutUsKeys.SUBTITLE_REPORT),
                        ),
                        onTap: () => launchURL(ISSUE_URL)),
                    ListTile(
                      leading: Icon(Icons.update, color: Colors.black),
                      title: Text(AppLocalizations.of(context)!.versionTitle),
                      subtitle: Text(
                        _version,
                        key: ValueKey(AboutUsKeys.VERSION_NUMBER),
                      ),
                    )
                  ],
                ),
              ),
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, left: 16.0),
                      child: Text(
                          AppLocalizations.of(context)!.authorSectionTitle,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: FONT_MEDIUM)),
                    ),
                    ListTile(
                      leading: Icon(Icons.perm_identity, color: Colors.black),
                      title: Text(
                        AppLocalizations.of(context)!.authorName,
                        key: ValueKey(AboutUsKeys.AUTHOR_NAME),
                      ),
                      subtitle: Text(
                        AppLocalizations.of(context)!.authorUsername,
                        key: ValueKey(AboutUsKeys.AUTHOR_USERNAME),
                      ),
                      onTap: () => launchURL(GITHUB_URL),
                    ),
                    ListTile(
                      leading: Icon(Icons.perm_contact_calendar_outlined, color: Colors.black),
                      title: Text(
                        "CrossEvol",
                        key: ValueKey(AboutUsKeys.CURRENT_AUTHOR),
                      ),
                      subtitle: Text(
                        "github.com/CrossEvol/what_todo",
                        key: ValueKey(AboutUsKeys.CURRENT_REPO),
                      ),
                      onTap: () => launchURL(CE_GITHUB_URL),
                    ),
                    ListTile(
                        leading: Icon(Icons.bug_report, color: Colors.black),
                        title: Text(AppLocalizations.of(context)!.forkGithub),
                        onTap: () => launchURL(PROJECT_URL)),
                    ListTile(
                        leading: Icon(Icons.email, color: Colors.black),
                        title: Text(AppLocalizations.of(context)!.sendEmail),
                        subtitle: Text(
                          "burhanrashid5253@gmail.com",
                          key: ValueKey(AboutUsKeys.AUTHOR_EMAIL),
                        ),
                        onTap: () => launchURL(EMAIL_URL)),
                  ],
                ),
              ),
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, left: 16.0),
                      child: Text(AppLocalizations.of(context)!.askQuestion,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: FONT_MEDIUM)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: IconButton(
                              icon: Image.asset(
                                "assets/twitter_logo.png",
                                scale: 8.75,
                              ),
                              onPressed: () => launchURL(TWITTER_URL),
                            ),
                          ),
                          Expanded(
                            child: IconButton(
                              icon: Image.asset("assets/facebook_logo.png"),
                              onPressed: () => launchURL(FACEBOOK_URL),
                            ),
                          ),
                          Expanded(
                            child: IconButton(
                              icon: Image.asset("assets/stack_overflow.png"),
                              onPressed: () => launchURL(STACK_OVERFLOW_URL),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, left: 16.0),
                      child: Text(AppLocalizations.of(context)!.apacheLicense,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: FONT_MEDIUM)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListTile(
                        subtitle:
                            Text(AppLocalizations.of(context)!.licenseText),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
