// Fixture: triggers all 4 seed rules in one file.
// ignore_for_file: unused_element, empty_catches, avoid_print

import 'package:flutter/material.dart';

class BadScreen extends StatelessWidget {
  const BadScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(color: Colors.purple),
          Switch(value: true, onChanged: (v) {}),
        ],
      ),
    );
  }
}

void bad() {
  try {
    throw Exception('x');
  } catch (_) {}
}
