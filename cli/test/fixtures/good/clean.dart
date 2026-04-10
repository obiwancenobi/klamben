// Fixture: triggers zero findings — negative control.
// ignore_for_file: unused_element, avoid_print

import 'package:flutter/material.dart';

class CleanScreen extends StatelessWidget {
  const CleanScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(color: Theme.of(context).colorScheme.primary),
            Switch.adaptive(value: true, onChanged: (v) {}),
          ],
        ),
      ),
    );
  }
}

void ok() {
  try {
    throw Exception('x');
  } catch (e) {
    print('caught: $e');
  }
}
