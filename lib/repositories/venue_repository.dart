import 'package:scorecard/modules/venue/models/venue_model.dart';
import 'package:scorecard/repositories/sql/db/venues_table.dart';
import 'package:scorecard/repositories/sql/entity_mappers.dart';

class VenueRepository {
  final VenuesTable venuesTable;

  VenueRepository({required this.venuesTable});

  Future<void> save(Venue venue, {bool update = true}) async {
    final entity = EntityMappers.venue(venue);
    await venuesTable.create(entity);
  }

  Future<Iterable<Venue>> fetchAll() async {
    final entities = await venuesTable.readAll();
  }
}
