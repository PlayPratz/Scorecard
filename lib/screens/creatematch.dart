import 'package:flutter/material.dart';
import 'package:scorecard/models/team.dart';
import 'package:scorecard/screens/titledpage.dart';
import 'package:scorecard/screens/widgets/teamtile.dart';
import 'package:scorecard/styles/colorstyles.dart';
import 'package:scorecard/styles/strings.dart';

class CreateMatchForm extends StatelessWidget {
  Team? _selectedHomeTeam;
  Team? _selectedAwayTeam;

  CreateMatchForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TitledPage(
        title: Strings.matchlistCreateNewMatch,
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              _selectedHomeTeam != null
                  ? TeamTile(team: _selectedHomeTeam!)
                  : getSelectTeamWidget("Select Home Team",
                      "The crowd cheers more for them", ColorStyles.homeTeam),
              _selectedAwayTeam != null
                  ? TeamTile(team: _selectedAwayTeam!)
                  : getSelectTeamWidget("Select Away Team",
                      "People always love the underdogs", ColorStyles.awayTeam),
              const Spacer(),
              OutlinedButton(onPressed: () {}, child: Text("Start Match")),
              SizedBox(height: 32)
            ],
          ),
        ));
  }

  Widget getSelectTeamWidget(
      String primaryHint, String secondaryHint, Color iconColor) {
    return InkWell(
      onTap: () {},
      child: ListTile(
        title: Text(primaryHint),
        subtitle: Text(secondaryHint),
        leading: Icon(Icons.people, color: iconColor),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
