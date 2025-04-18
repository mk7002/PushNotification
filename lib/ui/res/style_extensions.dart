import 'package:flutter/material.dart';

extension IntToRadius on int {
  BorderRadius get br => BorderRadius.all(Radius.circular(toDouble()));
}
