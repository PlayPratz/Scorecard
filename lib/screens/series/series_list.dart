import 'package:flutter/material.dart';
import 'package:scorecard/models/series.dart';
import 'package:scorecard/screens/series/create_series.dart';
import 'package:scorecard/screens/series/series_tile.dart';
import 'package:scorecard/screens/widgets/item_list.dart';

class SeriesList extends StatelessWidget {
  final List<Series> series;
  const SeriesList({super.key, required this.series});

  @override
  Widget build(BuildContext context) {
    return ItemList(
      itemList: series.map((series) => SeriesTile(series: series)).toList(),
      createItem: CreateItemEntry(
          page: const CreateSeries(),
          onCreateItem: (series) => {},
          string: "Create new series"),
    );
  }
}
