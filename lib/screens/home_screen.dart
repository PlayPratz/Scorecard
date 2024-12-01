import 'package:flutter/material.dart';
import 'package:scorecard/repositories/provider/repository_provider.dart';
import 'package:scorecard/screens/common/loading_future_builder.dart';
import 'package:scorecard/screens/cricket_match/create_cricket_match_screen.dart';
import 'package:scorecard/screens/cricket_match/cricket_match_list_screen.dart';
import 'package:scorecard/screens/player/player_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<void> _future;

  @override
  void initState() {
    super.initState();
    _future = _initializeApplication();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: LoadingFutureBuilder(
        future: _future,
        builder: (context, data) => ListView(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          children: [
            _HomeScreenTile(
              title: "New Match",
              onSelect: () => _goCreateMatch(context),
            ),
            _HomeScreenTile(
              title: "Load Match",
              onSelect: () => _goCricketMatchList(context),
            ),
            _HomeScreenTile(
              title: "Players",
              onSelect: () => _goPlayerList(context),
            ),
            // _HomeScreenTile(title: "Venues"),
          ],
        ),
      ),
      bottomNavigationBar: const BottomAppBar(
        child: Row(
          children: [
            Icon(Icons.hearing),
            Icon(Icons.favorite),
            Icon(Icons.sports),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
    );
  }

  void _goCreateMatch(BuildContext context) {
    final controller = CreateCricketMatchController();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CreateCricketMatchScreen(controller)),
    );
  }

  void _goCricketMatchList(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const CricketMatchListScreen()));
  }

  void _goPlayerList(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const AllPlayersScreen()));
  }

  Future<void> _initializeApplication() async {
    await RepositoryProvider().initialize();
  }
}

class _HomeScreenTile extends StatelessWidget {
  final String title;
  final void Function()? onSelect;

  const _HomeScreenTile({super.key, required this.title, this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: onSelect == null ? null : const Icon(Icons.chevron_right),
      onTap: onSelect,
    );
  }
}
