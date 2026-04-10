// Fixture: should trigger layout/missing-safearea rule.
// ignore_for_file: unused_element

import 'package:flutter/material.dart';

class BadNoSafeArea extends StatelessWidget {
  const BadNoSafeArea({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: const [Text('hello')]),
    );
  }
}

class OkWithAppBar extends StatelessWidget {
  const OkWithAppBar({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('t')),
      body: Column(children: const [Text('hello')]),
    );
  }
}

class OkWithSafeArea extends StatelessWidget {
  const OkWithSafeArea({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: const [Text('hello')]),
      ),
    );
  }
}
