import 'dart:convert';

import 'package:pushapp/data/DataHandler.dart';
import 'package:pushapp/provider/AppProvider.dart';

extension ResultExtension on Map<String, dynamic> {
  ResultType getType() {
    return this[AppProvider.TYPE] as ResultType;
  }

  String getMessage() {
    return this[AppProvider.MESSAGE] as String;
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
      return this[AppConfigType.serviceAccountJson.name]
          [AppConfigType.project_id.name];
    } catch (e) {
      return "";
    }
  }
}

extension PayLoadData on Map<String, dynamic> {
  String getUrl() {
    try {
      return this[AppProvider.URL];
    } catch (e) {
      return "";
    }
  }

  String token() {
    try {
      return this[AppProvider.TOKEN];
    } catch (e) {
      return "";
    }
  }

  String headers() {
    try {
      return this[AppProvider.HEADERS] != null
          ? jsonEncode(this[AppProvider.HEADERS])
          : "";
    } catch (e) {
      return "$e";
    }
  }

  String body() {
    try {
      return this[AppProvider.BODY] != null
          ? jsonEncode(this[AppProvider.BODY])
          : "";
    } catch (e) {
      return "$e";
    }
  }
}
