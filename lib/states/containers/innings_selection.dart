import 'package:scorecard/models/ball.dart';
import 'package:scorecard/models/wicket.dart';

class InningsSelections {
  int runs = 0;

  Wicket? wicket;
  BowlingExtra? bowlingExtra;
  BattingExtra? battingExtra;

  bool isEvent = false;
}
