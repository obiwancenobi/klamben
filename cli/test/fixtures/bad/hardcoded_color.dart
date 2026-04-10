// Fixture: should trigger visual/hardcoded-color rule.
// ignore_for_file: unused_element, unused_import

import 'package:flutter/material.dart';

Widget badPurple() {
  return Container(color: Colors.purple);
}

Widget badHex() {
  return Container(color: const Color(0xFFAABBCC));
}

Widget okTransparent() {
  return Container(color: Colors.transparent);
}
