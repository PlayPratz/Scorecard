import 'package:flutter/foundation.dart';
import 'package:scorecard/models/wicket.dart';
import 'package:scorecard/states/containers/innings_selection.dart';

class WicketDetailsState with ChangeNotifier {
  final InningsSelections selections;

  WicketDetailsState({required this.selections});

  void setWicket(Wicket? wicket) {
    selections.wicket = wicket;

    notifyListeners();
  }
}
