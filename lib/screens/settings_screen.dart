import 'package:flutter/material.dart';
import 'package:scorecard/cache/settings_cache.dart';
import 'package:url_launcher/url_launcher_string.dart';

const version = "0.90.4beta";
const buildDate = "2025-08-07";
const repository = "https://github.com/PlayPratz/Scorecard.git";

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
            title: const Text("Show Player and Match IDs"),
            subtitle: const Text("Useful for debugging"),
            leading: const Icon(Icons.bug_report),
            trailing: Switch(
                value: SettingsCache().showIds,
                onChanged: (_) => toggleShowIds()),
            onTap: () => toggleShowIds(),
          ),
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

  void toggleShowIds() {
    setState(() {
      SettingsCache().showIds = !SettingsCache().showIds;
    });
  }
}
