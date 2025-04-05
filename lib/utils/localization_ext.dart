import 'package:flutter/material.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

extension StringExtenstion on String {
  String localize(BuildContext context) {
    if (this == 'Today') {
      return AppLocalizations.of(context)!.today;
    } else if (this == 'Inbox') {
      return AppLocalizations.of(context)!.inbox;
    } else {
      return this;
    }
  }
}
