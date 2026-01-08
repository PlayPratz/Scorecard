![scorecard](assets/icon/github.png)

# Scorecard

Score your **Cricket** Matches as you play them and track the statistics!

Scorecard is a mobile application that helps you record matches on a ball-by-ball basis for easier score-keeping and tracking of statistics, all while enjoying the sport with your friends and family.

---

## 🗂️ Contents

- [Building the App](#build-app)
- [Core Concepts](#core-concepts)
- [Using the App](#how-to-use)
- [Future Scope](#future-scope)
- [Authors](#authors)

## 🔧 Building the App <a name = "build-app"/>

As this application is programmed in Flutter, you can perform the common steps to build and run a flutter application.

1. If you don't have Flutter SDK installed, please visit official [Flutter](https://flutter.dev/) site.

2. Fetch latest source code from master branch.

```
git clone https://github.com/PlayPratz/Scorecard.git
```

3. Run the app with Android Studio or VS Code. Or the command line:

```
flutter pub get
flutter run
```

## ⚙️ Core Concepts <a name = "core-concepts"/>

A Cricket Match is represented by the following constructs or concepts:

1. [Quick Match](#cricket-match)
2. [Quick Innings](#innings)
3. [Ball (Post)](#ball)
4. [Player](#player)
5. [Statistics](#statistics)

### 🏏 Quick Match <a name = "cricket-match"/>

Tailored for turf/gully cricket enthusiasts, a cricket match is no more than its constituent innings. The concept of teams is gone -- this allows for flexibility when players switch teams mid-game, a common occurence when friends or family play for fun. Each match is governed by a set of rules that is followed closesly by its innings. 

Unlimited Over matches are no longer in the pipeline. This app is now fully focused on turf scoring.

### 🏏 Quick Innings <a name = "innings"/>

Technically speaking, an innings is essentially a list of balls played; all other information can be derived from that. (Note: It could also be a list of _overs_ but it was simpler to skip that layer). This derived information includes (but is not limited to):

1. Runs scored by the batting team
2. Wickets fallen of the batting team
3. [Batting Scores](#batting-score), i.e., scores of all batters
4. [Bowling Scores](#bowling-score), i.e., bowling figures of all bowlers

Batting Scores and Bowling Scores form the building blocks for all player-centric statistics in cricket.

An innings comes to an end when any one of the following happens:

1. The batting side loses all wickets
2. The quota of overs is completed
3. The batting side has scored the required runs
4. The batting side declares

Since this app has no concept of Teams, the first rule cannot apply (there aren't any lineups either!). As a result, the first condition is ignored automatically and will be, in the future, an option to select while ending an innings. For now, you can declare the innings to mark an all-out scenario.

#### Batting Score <a name="batting-score"/>

A batting score, also called a **knock**, consists of a list of [balls](#-ball) played by that batter. Using this, we can derive the following data:

1. Runs scored
2. Number of balls faced
3. Wicket, if any

Over multiple matches, the following statistics can be calculated:

1. Strike rate `(runs scored)÷(number of balls faced)`
2. Average `(runs scored)÷(number of outs)`

#### Bowling Score <a name="bowling-score"/>

A bowler's innings, also called a **spell**, consists of a list of [balls](#-ball) delivered by that bowler. Using this, we can derive the following data:

1. Number of overs (or balls) bowled
2. Number of wickets taken
3. Runs conceded
4. Maidens bowled

Over multiple matches, the following statistics can be calculated:

1. Strike rate `(number of balls bowled)÷(number of wickets taken)`
2. Average `(runs conceded)÷(number of wickets taken)`
3. Economy `[(runs conceded) * (number of balls per over)]÷(number of balls bowled)`

### ⚾️ Ball <a name = "ball"/>

A ball is the most atomic unit for scoring a cricket match. It consists of the following data:

1. Bowler
2. Batter
3. Non-striker
4. Runs scored
5. Wicket, if any
6. Extra, if any

Once this data is obtained for every ball of the match, the score can be derived.

On a more technical level, this app uses a concept named *POST*. There are 8 types of Posts:
1. Ball -- A ball bowled in an innings
2. Batter Retire -- A batter retires
3. Next Batter -- A new batter walks out to bat
4. Bowler Retire -- A bowler retires mid-over
5. Next Bowler -- A bowler is selected to bowl
6. Wicket Before Delivery - For example, run-out at the non-striker's end, or obstructing the field.
7. Penalty -- Awarded by the umpires in certain scenarios
8. Break -- Unused for now, but will signify Drinks Break, Interruption due to rain, etc.

Since this app is developed and designed with focus on a scorer who will operate the app, storing each input interaction as a Post allows an _Undo_ functionality. Whenever the scorer taps Undo, the last Post of the innings is deleted. This allows the innings to reach the same state as it was before that Post was added.

### 🤾 Player <a name = "player"/>

A player is needed to play any sport. Players in cricket take up the role of a batter, bowler and fielder. Since players contribute in more than one way, tying together their statistics provides a handy way of representing a player's career performance.

As it stands, you can create as many players as you like but deleting a player is not possible. This is because if a player has been part of even a single match, deleting that player is not possible, as the match cannot have a non-existent player.


### 📊 Statistics <a name = "statistics"/>

Since all Batting and Bowling Scores are stored in the Database, they can be easily parsed to generate per-player statistics. Currently, the statistics are rudimentary and not filterable, but that functionality will surely by added later.

As of now you can see:
1. Runs -- A list of all players sorted by runs scored (descending), then by balls faced (ascending)
2. Wickets -- A list of all player sorted by wickets taken (descending), then by runs concdeded (ascending), then by balls bowled (descending)

---

## 📱 How to use the app <a name = "how-to-use"/>

### Home Screen

The Home Screen consists of the following options:

1. [New Quick Match](#ongoing-and-completed-matches)
2. [Load Quick Match](#ongoing-and-completed-matches)
3. [Players](#player)
4. [Statistics](#statistics)
5. [Settings](#settings-screen)

A new match can be created using the ⨁ button located at the center of the Bottom Navigation Bar.

### Ongoing and Completed Matches

On creating a match, you will be asked to enter:
1. Number of Balls per Over -- usually 6, but some Aussies might like to set this to 8. Nevertheless, you can set any number you like (maybe 5 if you want to emulate the Hundred).
2. Number of Overs per Innings -- The total quota of overs for each innings.

Once you create a match you jump straight into action.

In the Load Quick match section, you will see a list of previously created matches -- incomplete as well as complete. Selecting a match from the list will take you to one of the following screens depending on its completion:
1. [Play Match Screen](#play-match-screen) if the match is incomplete
2. [Scorecard Screen](#scorecard-screen) if the match is complete

### Play Match Screen <a name="play-match-screen"/>

This is where the magic happens. Below is a breakdown of the screen from top to bottom.

#### Match Bar

Here, from left to right, you'll see:
1. An exit button -- takes you back to the main screen
2. Innings heading -- describes the innings you are playing (First Innings, Second Innings, Super Over 1A, etc.)
3. Declare button -- allows you to end the innings before the compeltion of overs

#### Score Pane

1. On the left is the score of the batting team in the format `runs/wickets`
2. On the right is the number of overs bowled in the format `overs bowled/total overs`

#### Run Rate Pane

1. For the first innings shows the _Current Run Rate (CRR)_ and the _Projected Score_
2. For the second innings shows the _Current Run Rate (CRR)_, _Required Run Rate (RRR)_, _Runs Required_ and _Balls Left_.

#### Recent Balls

Here, the latest balls bowled are displayed for convenience. The number of balls visible depends on the screen size of the device. Clicking on this list will take you to the [Innings Timeline](#innings-timeline-screen). The Recent Balls list follows the same scheme as the Innings Timeline, so read that for more information.

To demarcate the beginning of an over, its first ball has its index in another colour.

#### On Crease Players

Here you can see the two batters on the pitch and the bowler who is currently bowling.

The Batter Tiles serve an important purpose — selecting the player who is on strike. Usually, this is handled automatically — strike is rotated for odd number of runs and at the end of an over. However, there are possibilities of rules being altered and a '1D' or 3D' being added, in which case the strike will have to be changed manually. The score of each batter is displayed on the tile. For more details on the score, you can always open the [Scorecard](#scorecard-screen).

Long pressing a Bowler Tile will allow you to replace the bowler mid-over. Please note that replacing a bowler will NOT skip or restart the over. Just like international matches, the over will continue to be bowled by a different bowler. If you want to restart the over with another bowler, use the *Undo* button found in the [Submit Input](#submit-input) pane.

#### Record Ball Pane

1. Wicket Selector -- On tapping this button, you will be taken to a pretty self-explanatory screen where you choose the kind of dismissal (bowled, LBW, run out, etc.) and the players involved in said dismissal. To clear a wicket that has been selected, tap this tile before adding the ball.
2. Extra Selector -- On the left we have **Batting Extras**: _Bye_ and _Leg Bye_. For the uninitiated, a Bye is a run scored by the batting team without a batter getting their bat on ball. But if they manage to get their body on ball before scoring the runs, it's called a Leg Bye. Note that in either case, even though the runs scored are awarded to the batting team, they aren't awarded to the batter. On the right we have **Bowling Extras**, the infamous _No Balls_ and _Wides_. Do note that while entering this data you are NOT supposed to select the runs awarded to the batting team due to a Bowling Extra. If no runs are scored by the batting team on a No Ball or a Wide, choose 0 runs on the _Run Selector_.
3. Run Selector -- It's a list of number from 0 to 6 that represent the number of runs scored on the ball that is being entered. Numbers '4' and '6' are treated specially, since they represent the ever-so-famous boundaries loved by fans of cricket. As it stands, there is no distinction between scoring a four or actually running four runs; this will be added in the future.
4. Undo -- Allows the scorer to Undo any previously recorded interaction
5. Confirm -- This button takes on many forms. Depending on the state of the innings, the expected input from the user changes. For example, if a wicket has fallen, you will be forced to choose another batter instead of selecting runs and playing a ball.
    1. In most cases, it is a _Play Ball_ button, that submits the data entered from _Run Selector_,  _Extra Selector_ and _Wicket Selector_. This will cause the [ball](#ball) to be added into the [innings](#innings). As result of this, the scores for both the teams and all the players involved will be updated.
    2. When an over is completed, it is a _Select Bowler_ button. On clicking, you will be taken to the bowling squad to choose the next bowler.
    3. When a wicket falls, it is a _Select Batter_ button. On clicking, you will be taken to the batting squad to choose the next batter.
    4. When the quota of overs is completed, or when the _target_ for the second innings is achieved, it is a _Finishs_ button which will end the innings.

---

### Scorecard Screen <a name="scorecard-screen"/>

The Scorecard screen starts with a simple view of the overall scores of both the teams across all innings played all the way at the top.

For each innings, you will see the following:

#### Innings Heading
The descriptor of the innings doubles as a button that takes you to the [Innings Timeline Screen](#innings-timeline-screen)

#### Batting Scores

A list of [batting scores](#batting-score) is displayed. For each Batting Score, the following information is displayed from left to right:
1. The batter's photo, if any
2. The batter's name
3. Right below the batter's name, their wicket status
4. The batter's score - Runs, balls faced
5. The batter's strike rate
6. The number of fours and sixes hit, displayed inside circles of the respective colour

Next, we have a summary of the _Extras_ in this innings.

Finally, we have the total score of this innings.

#### Fall of Wickets

Every row of this table marks the index at which a wicket fell, the score at when that wicket fail, the batter who lost their wicket and their wicket's details.

#### Bowling Scores

Next, the list of [bowling scores](#bowling-score) is displayed. For each Bowling Score, the following information is displayed from left to right:
1. The bowler's photo, if any
2. The bowler's name
3. The number of overs bowled
4. The number of wickets taken, displayed inside a red circle
5. The number of runs conceded
6. The bowler's economy

---

### Innings Timeline Screen <a name = "innings-timeline-screen"/>

This screen displays a vertical, chronological timeline of balls bowled in the innings, with the last ball at the bottom and the first ball at the top. The timeline is segmented into overs.

The rightmost circle's background colour and border colour give a quick look at what transpired using the same colours as seen in [Colour Lookup](#colour-lookup).

#### 🎨 Colour Lookup <a name = "colour-lookup"/>

With respect to a [Ball](#ball):

- ![indigo](https://placehold.co/15x15/536DFE/536DFE) Indigo for a Four
- ![ruby](https://placehold.co/15x15/E91E63/E91E63) Ruby for a Six
- ![red](https://placehold.co/15x15/F44336/F44336) Red for a Wicket
- ![yellow](https://placehold.co/15x15/FFFF00/FFFF00) Yellow for a No Ball
- ![white](https://placehold.co/15x15/FFFFFF/FFFFFF) White for a Wide

---

## 🔮 In the Future... <a name = "future-scope"/>

- Add screenshots to README.md
- Add online syncing
- Add filtered statistics
- Add Settings and Customizations
- Add **Tournaments** and **Series**

---

## ✍️ Authors <a name = "authors"/>

- [@PlayPratz](https://github.com/PlayPratz) - Ideation, Documentation and App Development
