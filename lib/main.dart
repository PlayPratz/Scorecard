import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:scorecard/modules/repository/service/repostiory_service.dart';
import 'package:scorecard/screens/home_screen.dart';

void main() {
  // TODO Improve

  GetIt.I.registerSingleton<IRepositoryService>(RAMRepositoryService());

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
        colorSchemeSeed: Colors.teal,
      ),
      home: const HomeScreen(),
    );
  }
}
