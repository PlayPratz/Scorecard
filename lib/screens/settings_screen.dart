import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/services/settings_service.dart';
import 'package:url_launcher/url_launcher_string.dart';

const version = "0.98.0beta";
const buildDate = "2026-01-06";
const repository = "https://github.com/PlayPratz/Scorecard.git";

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsService settingsService;

  @override
  void initState() {
    super.initState();
    settingsService = context.read<SettingsService>();
  }

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
            title: const Text("Dark Mode"),
            // subtitle: const Text("Easier on the eyes"),
            leading: const Icon(Icons.dark_mode),
            trailing: Switch(
                value: settingsService.getTheme() == ScorecardTheme.dark,
                onChanged: (_) => toggleTheme()),
            onTap: () => toggleTheme(),
          ),
          ListTile(
            title: const Text("Show Player and Match Handles"),
            subtitle: const Text("Useful for debugging"),
            leading: const Icon(Icons.bug_report),
            trailing: Switch(
                value: settingsService.getShowHandles(),
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
      settingsService.toggleShowIds();
    });
  }

  Future<void> toggleTheme() async {
    setState(() {
      settingsService.toggleTheme();
    });
  }
}
