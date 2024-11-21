import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/repositories/generic_repository.dart';

class IPlayerRepository extends IRepository<Player> {
  @override
  Future<void> create(Player object) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<Player?> read(String id) {
    // TODO: implement read
    throw UnimplementedError();
  }

  @override
  Future<Iterable<Player>> readAll() {
    // TODO: implement readAll
    throw UnimplementedError();
  }

  @override
  Future<Iterable<Player>> search(String query) {
    // TODO: implement search
    throw UnimplementedError();
  }

  @override
  Future<void> update(Player object) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
