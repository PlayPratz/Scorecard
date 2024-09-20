import 'package:flutter/material.dart';

void main() {
  runApp(const ScorecardApp());
}

class ScorecardApp extends StatelessWidget {
  const ScorecardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scorecard',
      theme: ThemeData(
        useMaterial3: true,
      ),
      builder: (context, widget) => Container(),
    );
  }
}
