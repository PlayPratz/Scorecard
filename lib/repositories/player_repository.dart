import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/repositories/sql/db/players_table.dart';

class PlayerRepository {
  final PlayersTable playersTable;

  PlayerRepository({required this.playersTable});

  Future<void> save(Player player) async {}

  Future<Player> fetchById(String id) async {
    final result = await playersTable.read(id);
  }

  Future<Iterable<Player>> fetchAll() async {}
}
