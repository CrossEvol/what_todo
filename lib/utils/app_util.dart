import 'package:flutter/material.dart';
import 'package:flutter_app/constants/app_constant.dart';
import 'package:flutter_app/constants/keys.dart';
import 'package:url_launcher/url_launcher.dart';

showSnackbar(context, String message, {MaterialColor? materialColor}) {
  if (message.isEmpty) return;
  // Find the Scaffold in the Widget tree and use it to show a SnackBar
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: materialColor));
}

launchURL(String url) async {
  if (url.isEmpty) return;
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    // Use platformDefault mode for better handling across platforms/apps
    await launchUrl(
      uri,
      mode: LaunchMode.platformDefault,
    );
  } else {
    throw 'Could not launch $url';
  }
}

class MessageInCenterWidget extends StatelessWidget {
  final String _message;

  MessageInCenterWidget(this._message);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(_message,
          key: ValueKey(HomePageKeys.MESSAGE_IN_CENTER),
          style: TextStyle(fontSize: FONT_MEDIUM, color: Colors.black)),
    );
  }
}
