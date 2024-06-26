import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/models/ball.dart';
import 'package:scorecard/models/cricket_match.dart';
import 'package:scorecard/models/innings.dart';
import 'package:scorecard/screens/match/innings_play_screen/recent_balls.dart';
import 'package:scorecard/screens/match/match_tile.dart';
import 'package:scorecard/screens/templates/titled_page.dart';
import 'package:scorecard/screens/widgets/generic_item_tile.dart';
import 'package:scorecard/services/cricket_match_service.dart';
import 'package:scorecard/styles/color_styles.dart';
import 'package:scorecard/screens/widgets/elements.dart';
import 'package:scorecard/util/strings.dart';
import 'package:scorecard/util/utils.dart';

class Scorecard extends StatelessWidget {
  final CricketMatch match;
  const Scorecard({Key? key, required this.match}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title = Strings.getCricketMatchTitle(match);

    return TitledPage(
      appBarActions: [
        IconButton(
          onPressed: () {
            context.read<CricketMatchService>().share(match);
          },
          icon: const Icon(Icons.share),
        )
      ],
      title: title,
      child: SingleChildScrollView(
        child: _ScorecardMatchPanel(match: match),
      ),
    );
  }
}

class _ScorecardMatchPanel extends StatelessWidget {
  final CricketMatch match;
  const _ScorecardMatchPanel({required this.match});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MatchTile(match: match, showSummaryLine: true),
        const SizedBox(height: 8),
        for (int i = 0; i < match.inningsList.length; i++)
          _InningsPanel(match.inningsList[i], i + 1)
      ],
    );
  }
}

class _InningsPanel extends StatelessWidget {
  final Innings innings;
  final int inningsIndex;
  const _InningsPanel(this.innings, this.inningsIndex);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      surfaceTintColor: Color(innings.battingTeam.team.color),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                const SizedBox(width: 4),
                Text(
                  Strings.getInningsHeaderForIndex(inningsIndex),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                TeamChip(team: innings.battingTeam.team),
                const SizedBox(width: 4),
              ],
            ),
            _BattingInningsPanel(innings),
            _YetToBatPanel(innings),
            _FallOfWicketsPanel(innings),
            _BowlingInningsPanel(innings),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.query_stats),
                  label: const Text("Stats"),
                  onPressed: () {
                    showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (context) => _PartnershipTable(innings));
                  },
                ),
                const Spacer(),
                _wViewTimelineButton(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _wViewTimelineButton(BuildContext context) => ElevatedButton.icon(
        onPressed: () =>
            Utils.goToPage(InningsTimelineScreen(innings: innings), context),
        icon: const Icon(Icons.timeline),
        label: const Text(Strings.goToTimeline),
      );
}

class _BattingInningsPanel extends StatelessWidget {
  final Innings innings;
  const _BattingInningsPanel(this.innings);

  @override
  Widget build(BuildContext context) {
    final extras = innings.balls
        .where((ball) => ball.isBowlingExtra || ball.isBattingExtra);
    final wides =
        extras.where((ball) => ball.bowlingExtra == BowlingExtra.wide);
    final noBalls =
        extras.where((ball) => ball.bowlingExtra == BowlingExtra.noBall);
    final byes = extras.where((ball) => ball.battingExtra == BattingExtra.bye);
    final legByes =
        extras.where((ball) => ball.battingExtra == BattingExtra.legBye);
    return _GenericInningsPanel(
      title: Strings.scorecardBatting.toUpperCase(),
      color: Color(innings.battingTeam.team.color),
      child: Column(
        children: [
          Table(
            columnWidths: const {
              0: FlexColumnWidth(3.5),
              3: FlexColumnWidth(0.6),
              4: FlexColumnWidth(0.6),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            // border: const TableBorder(
            //   verticalInside: BorderSide(color: Colors.black12),
            // ),
            children: [
              const TableRow(
                children: [
                  SizedBox(),
                  SizedBox(),
                  Center(child: Text("SR")),
                  Center(child: Text("4s")),
                  Center(child: Text("6s"))
                ],
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.black12))),
              ),
              for (final batterInnings in innings.batterInningsList)
                TableRow(children: [
                  ListTile(
                    leading: Elements.getPlayerIcon(
                        context, batterInnings.batter, 36),
                    title: Text(
                      batterInnings.batter.name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    subtitle: Text(
                      Strings.getWicketDescription(batterInnings.wicket),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          batterInnings.runs.toString(),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          batterInnings.ballsFaced.toString(),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.merge(const TextStyle(color: Colors.white70)),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Text(
                      batterInnings.strikeRate.toStringAsFixed(2),
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.merge(const TextStyle(color: Colors.white70)),
                    ),
                  ),
                  CircleAvatar(
                      backgroundColor: ColorStyles.ballFour.withOpacity(0.7),
                      foregroundColor: Colors.white,
                      radius: 15,
                      child: Text(
                        batterInnings.fours.toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      )),
                  CircleAvatar(
                      backgroundColor: ColorStyles.ballSix.withOpacity(0.7),
                      radius: 15,
                      foregroundColor: Colors.white,
                      child: Text(
                        batterInnings.sixes.toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      )),
                ])
            ],
          ),
          const Divider(color: Colors.black12, height: 0),
          GenericItemTile(
            primaryHint: Strings.extras,
            smallPrimary: true,
            secondaryHint: Strings.getExtrasForInnings(
                wides.length, noBalls.length, byes.length, legByes.length),
            contentPadding: const EdgeInsets.only(left: 24, right: 64),
            trailing: Text(
              extras.length.toString(),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const Divider(color: Colors.black12, height: 0),
          GenericItemTile(
            primaryHint: Strings.total,
            secondaryHint: Strings.getOverBowledText(innings, short: false),
            contentPadding: const EdgeInsets.only(left: 24, right: 64),
            trailing: Text(
              Strings.getInningsScore(innings),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class BatterInningsScore extends StatelessWidget {
  final BatterInnings batterInnings;
  const BatterInningsScore({super.key, required this.batterInnings});

  @override
  Widget build(BuildContext context) {
    final player = batterInnings.batter;
    final strikeRate = batterInnings.strikeRate;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Elements.getPlayerIcon(context, player, 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      Strings.getWicketDescription(batterInnings.wicket),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.merge(const TextStyle(color: Colors.white70)),
                    )),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                batterInnings.runs.toString(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(width: 4),
              Text(
                batterInnings.ballsFaced.toString(),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.merge(const TextStyle(color: Colors.white70)),
              ),
            ],
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  strikeRate.isNaN
                      ? Strings.empty
                      : batterInnings.strikeRate.toStringAsFixed(2),
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.merge(const TextStyle(color: Colors.white70)),
                ),
                const SizedBox(width: 6),
                CircleAvatar(
                    backgroundColor: ColorStyles.ballFour.withOpacity(0.7),
                    foregroundColor: Colors.white,
                    radius: 15,
                    child: Text(
                      batterInnings.fours.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    )),
                const SizedBox(width: 3),
                CircleAvatar(
                    backgroundColor: ColorStyles.ballSix.withOpacity(0.7),
                    radius: 15,
                    foregroundColor: Colors.white,
                    child: Text(batterInnings.sixes.toString(),
                        style: Theme.of(context).textTheme.bodyMedium)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _YetToBatPanel extends StatelessWidget {
  final Innings innings;

  const _YetToBatPanel(this.innings);

  @override
  Widget build(BuildContext context) {
    final playersThatDidNotBat = [...innings.battingTeam.squad];
    for (final batterInnings in innings.batterInningsList) {
      playersThatDidNotBat.remove(batterInnings.batter);
    }
    if (playersThatDidNotBat.isEmpty) {
      return const SizedBox();
    }

    return _GenericInningsPanel(
        title: Strings.scorecardYetToBat.toUpperCase(),
        color: Color(innings.battingTeam.team.color),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding:
                const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 12.0),
            child: Wrap(
              spacing: 6,
              children: [
                for (final player in playersThatDidNotBat) ...[
                  Text(player.name),
                  if (playersThatDidNotBat.last != player) const Text('·'),
                ]
              ],
            ),
          ),
        ));
  }
}

class _FallOfWicketsPanel extends StatelessWidget {
  final Innings innings;

  const _FallOfWicketsPanel(this.innings);

  @override
  Widget build(BuildContext context) {
    if (innings.fallOfWickets.isEmpty) {
      return const SizedBox();
    }
    return _GenericInningsPanel(
      title: Strings.scorecardFallOfWickets.toUpperCase(),
      color: Color(innings.battingTeam.team.color),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.titleMedium!,
          child: Table(
            columnWidths: const {
              1: FlexColumnWidth(1.25),
              2: FlexColumnWidth(3),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            border: const TableBorder(
              horizontalInside: BorderSide(color: Colors.black12),
              verticalInside: BorderSide(color: Colors.black12),
            ),
            children: [
              for (final fallOfWicket in innings.fallOfWickets)
                TableRow(
                  children: [
                    SizedBox(
                      height: 36, // To space the rows
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              Strings.getBallIndex(fallOfWicket.ball),
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                              "${fallOfWicket.runsAtWicket}/${fallOfWicket.wicketsAtWicket}"),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(fallOfWicket.outBatter.name),
                        ),
                      ),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}

class _BowlingInningsPanel extends StatelessWidget {
  final Innings innings;

  const _BowlingInningsPanel(this.innings);

  @override
  Widget build(BuildContext context) {
    return _GenericInningsPanel(
      title: Strings.scorecardBowling.toUpperCase(),
      color: Color(innings.bowlingTeam.team.color),
      // child: Column(
      //   children: [
      //     for (final bowlInn in innings.bowlerInningsList) ...[
      //       const Divider(color: Colors.black12, height: 0),
      //       BowlerInningsScore(bowlerInnings: bowlInn)
      //     ]
      //   ],
      // ),
      child: Table(
          columnWidths: const {
            0: FlexColumnWidth(4),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            const TableRow(
              children: [
                SizedBox(),
                Center(child: Text("O")),
                Center(child: Text("W")),
                Center(child: Text("R")),
                Center(child: Text("Econ"))
              ],
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black12))),
            ),
            for (final bowlerInnings in innings.bowlerInningsList)
              TableRow(children: [
                ListTile(
                  leading:
                      Elements.getPlayerIcon(context, bowlerInnings.bowler, 36),
                  title: Text(
                    bowlerInnings.bowler.name,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Center(
                  child: Text(
                    Strings.getBowlerOversBowled(bowlerInnings),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Center(
                  child: CircleAvatar(
                    backgroundColor: ColorStyles.wicket.withOpacity(0.7),
                    foregroundColor: Colors.white,
                    radius: 14,
                    child: Text(
                      bowlerInnings.wicketsTaken.toString(),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    bowlerInnings.runsConceded.toString(),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Center(
                  child: Text(bowlerInnings.economy.toStringAsFixed(2),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.merge(const TextStyle(color: Colors.white70))),
                ),
              ])
          ]),
    );
  }
}

class _GenericInningsPanel extends StatelessWidget {
  final String title;
  final Color color;
  final Widget child;

  final EdgeInsets margin;

  const _GenericInningsPanel(
      {required this.title,
      required this.color,
      required this.child,
      this.margin = const EdgeInsets.only(top: 16.0)});

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: color,
      color: color.withOpacity(0.4),
      elevation: 4,
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 16),
          child
        ],
      ),
    );
  }
}

class _PartnershipTable extends StatelessWidget {
  final Innings innings;

  const _PartnershipTable(this.innings);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.8,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 12.0),
        child: SingleChildScrollView(
          controller: scrollController,
          child: _GenericInningsPanel(
            title: "Partnerships",
            color: Color(innings.battingTeam.team.color),
            margin: const EdgeInsets.all(0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Table(
                columnWidths: const {
                  1: FlexColumnWidth(2),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                border: const TableBorder(
                  horizontalInside: BorderSide(color: Colors.black12),
                ),
                // border: TableBorder.all(color: Colors.yellow),
                children: [
                  for (final partnership in innings.partnerships)
                    TableRow(children: [
                      ListTile(
                        title: Text(
                          partnership.batter1.name,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        subtitle: Text(
                            "${partnership.batter1Contribution.runs} (${partnership.batter1Contribution.ballsFaced})"),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 4.0),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            Text(
                              "${partnership.runs} (${partnership.ballsFaced})",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              children: [
                                Expanded(
                                  flex: partnership.batter1Contribution.runs,
                                  child: const ClipRRect(
                                    borderRadius: BorderRadius.horizontal(
                                      left: Radius.circular(24),
                                    ),
                                    child: Divider(
                                      color: ColorStyles.online,
                                      thickness: 8,
                                      height: 8,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: partnership.batter2Contribution.runs,
                                  child: const ClipRRect(
                                    borderRadius: BorderRadius.horizontal(
                                      right: Radius.circular(24),
                                    ),
                                    child: Divider(
                                      color: ColorStyles.highlight,
                                      thickness: 8,
                                      height: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                          ],
                        ),
                      ),
                      ListTile(
                        title: Text(
                          partnership.batter2.name,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        subtitle: Text(
                            "${partnership.batter2Contribution.runs} (${partnership.batter2Contribution.ballsFaced})"),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 4.0),
                      ),
                    ])
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
