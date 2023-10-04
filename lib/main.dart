import 'package:flutter/material.dart';
import 'package:scorecard/screens/home.dart';
import 'package:scorecard/services/storage_service.dart';
import 'package:scorecard/styles/text_styles.dart';

void main() {
  runApp(const ScorecardApp());
}

class ScorecardApp extends StatefulWidget {
  const ScorecardApp({Key? key}) : super(key: key);

  @override
  State<ScorecardApp> createState() => _ScorecardAppState();
}

class _ScorecardAppState extends State<ScorecardApp> {
  // This widget is the root of your application.

  final Future _loadStorage = StorageService.init();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Scorecard',
        theme: ThemeData(
          // brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.dark,
          ),
          // dividerTheme: const DividerThemeData(
          //   color: ColorStyles.highlight,
          //   thickness: 2,
          //   space: 2,
          // ),
          textTheme: TextStyles.theme,
          useMaterial3: true,
        ),
        home: FutureBuilder(
          future: _loadStorage,
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return const HomeTabView();
            } else {
              return const SafeArea(
                child: Center(child: CircularProgressIndicator()),
              );
            }
          }),
        ));
  }
}
