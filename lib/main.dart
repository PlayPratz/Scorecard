import 'package:flutter/material.dart';
import 'package:scorecard/services/storage_service.dart';

import 'screens/home.dart';
import 'styles/color_styles.dart';
import 'styles/text_styles.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  final Future _loadStorage = StorageService.init();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // brightness: Brightness.dark,
          colorScheme: const ColorScheme.dark().copyWith(
            secondary: ColorStyles.selected,
            background: ColorStyles.background,
            surface: ColorStyles.background,
          ),
          backgroundColor: ColorStyles.background,
          dividerTheme: const DividerThemeData(
            color: ColorStyles.highlight,
            thickness: 2,
            space: 2,
          ),
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
