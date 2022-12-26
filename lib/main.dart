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
        theme: ThemeData.dark().copyWith(
          // brightness: Brightness.dark,
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
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
