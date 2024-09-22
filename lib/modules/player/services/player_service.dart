import 'package:scorecard/modules/player/player_model.dart';

abstract class PlayerService {
  Player createPlayer(String name);

  Iterable<Player> getAllPlayers(int page);

  Player getPlayerById(String id);

  Iterable<Player> searchPlayer(String query);

  Player savePlayer(Player player);

  void getPhotoOfPlayer(Player player);

  void deletePlayerById(String id);
}
