import 'dart:convert';

import 'package:pushapp/data/DataHandler.dart';
import 'package:pushapp/provider/android_provider.dart';

extension ResultExtension on Map<String, dynamic> {
  ResultType getType() {
    return this[AndroidProvider.TYPE] as ResultType;
  }

  String getMessage() {
    return this[AndroidProvider.MESSAGE] as String;
  }

  bool isInProgress() {
    return getType() == ResultType.inProgress;
  }

  String showResult() {
    switch (getType()) {
      case ResultType.neutral:
        return "";
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
      return this[AndroidProvider.URL];
    } catch (e) {
      return "";
    }
  }

  String token() {
    try {
      return this[AndroidProvider.TOKEN];
    } catch (e) {
      return "";
    }
  }

  String headers() {
    try {
      return this[AndroidProvider.HEADERS] != null
          ? jsonEncode(this[AndroidProvider.HEADERS])
          : "";
    } catch (e) {
      return "$e";
    }
  }

  String body() {
    try {
      return this[AndroidProvider.BODY] != null
          ? jsonEncode(this[AndroidProvider.BODY])
          : "";
    } catch (e) {
      return "$e";
    }
  }
}
