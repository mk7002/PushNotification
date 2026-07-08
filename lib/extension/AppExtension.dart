import 'dart:convert';

import 'package:pushapp/data/DataHandler.dart';
import 'package:pushapp/provider/android_provider.dart';

import '../ui/res/strings.dart';

extension ResultExtension on Map<String, dynamic> {
  ResultType getType() {
    return this[Strings.TYPE] as ResultType;
  }

  String getMessage() {
    return this[Strings.MESSAGE] as String;
  }

  bool isInProgress() {
    return getType() == ResultType.inProgress;
  }

  String showResult() {
    switch (getType()) {
      case ResultType.neutral:
        return "Result Console";
      case ResultType.inProgress:
        return "Sending...";
      case ResultType.success:
        return getMessage();
      case ResultType.error:
        return getMessage();
    }
    return "";
  }
}

extension AppConfigExtension on Map<String, dynamic> {
  String getProjectId() {
    try {
      var id = this[AppConfigType.project_id.name];
      return id ?? "";
    } catch (e) {
      return "";
    }
  }

  bool isOldConfig() {
    return this["serviceAccountJson"] != null;
  }
}

extension PayLoadData on Map<String, dynamic> {
  String getUrl() {
    try {
      return this[Strings.URL] ?? "";
    } catch (e) {
      return "";
    }
  }

  String token() {
    try {
      return this[Strings.TOKEN] ?? "";
    } catch (e) {
      return "";
    }
  }

  String headers() {
    try {
      final h = this[Strings.HEADERS];
      if (h == null) return "{}";
      return jsonEncode(h);
    } catch (e) {
      return "{}";
    }
  }

  String body() {
    try {
      final b = this[Strings.BODY];
      if (b == null) return "";
      return jsonEncode(b);
    } catch (e) {
      return "";
    }
  }

  String apnServer() {
    try {
      return this[Strings.APN_SERVER] ?? Strings.LIST_APNS_SERVER[0];
    } catch (e) {
      return Strings.LIST_APNS_SERVER[0];
    }
  }

  String pushType() {
    try {
      return this[Strings.PUSH_TYPE] ?? Strings.LIST_PUSH_TYPE[0];
    } catch (e) {
      return Strings.LIST_PUSH_TYPE[0];
    }
  }
}
