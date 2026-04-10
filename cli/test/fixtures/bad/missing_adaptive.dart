// Fixture: should trigger platform/missing-adaptive rule.
// ignore_for_file: unused_element

import 'package:flutter/material.dart';

Widget bad(bool on, void Function(bool) f) {
  return Switch(value: on, onChanged: f);
}

Widget good(bool on, void Function(bool) f) {
  return Switch.adaptive(value: on, onChanged: f);
}
