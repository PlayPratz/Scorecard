import 'package:scorecard/modules/venue/models/venue_model.dart';
import 'package:scorecard/repositories/sql/db/venues_table.dart';
import 'package:scorecard/repositories/sql/entity_mappers.dart';

class VenueRepository {
  final VenuesTable venuesTable;

  VenueRepository({required this.venuesTable});

  Future<void> save(Venue venue, {bool update = true}) async {
    final entity = EntityMappers.repackVenue(venue);
    await venuesTable.create(entity);
  }

  Future<Venue> fetchById(String id) async {
    final entity = await venuesTable.read(id);
    if (entity == null) {
      throw StateError("Venue not found in DB! (id: $id)");
    }
    final venue = EntityMappers.unpackVenue(entity);
    return venue;
  }

  Future<Iterable<Venue>> fetchAll() async {
    final entities = await venuesTable.readAll();
    final venues = entities.map((e) => EntityMappers.unpackVenue(e));
    return venues;
  }
}
