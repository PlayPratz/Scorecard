import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

const version = "0.90.2beta";
const buildDate = "2025-08-06";
const repository = "https://github.com/PlayPratz/Scorecard.git";

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        toolbarHeight: 256,
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Build Info"),
            titleTextStyle: Theme.of(context).textTheme.titleSmall,
          ),
          const ListTile(
            title: Text("Scorecard"),
            leading: Icon(Icons.sports_cricket),
            subtitle: Text("v$version"),
          ),
          const ListTile(
            title: Text("Build date"),
            leading: Icon(Icons.update),
            subtitle: Text(buildDate),
          ),
          ListTile(
            title: const Text("GitHub Repository"),
            leading: const Icon(Icons.flutter_dash),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => onOpenRepository(context),
          ),
        ],
      ),
    );
  }

  void onOpenRepository(BuildContext context) {
    launchUrlString(repository, mode: LaunchMode.externalApplication);
  }
}
