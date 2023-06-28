![scorecard](assets/icon/github.png)

# Scorecard

Score your **Cricket** Matches as you play them and track the statistics!

Scorecard is a mobile application that helps you record matches on a ball-by-ball basis for easier score-keeping and tracking of statistics, all while enjoying the sport with your friends and family.

---

## 🗂️ Contents

- [Building the App](#build-app)
- [Core Concepts](#core-concepts)
- [Using the App](#how-to-use)
- [Colour Lookup](#colour-lookup)
- [Future Scope](#future-scope)
- [Authors](#authors)

---

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

A Cricket Match is represented by the falling constructs or concepts:

1. [Cricket Match](#cricket-match)
2. [Innings](#innings)
3. [Ball](#ball)
4. [Player](#player)
5. [Statistics](#statistics)

### 🏏 Cricket Match <a name = "cricket-match"/>

It's a match played between two teams. What more can I say? Maybe a lot more; will expand on this later on.

### 🏏 Innings <a name = "innings"/>

An innings is one division of a cricket match where one team bats while the other team bowls and fields. Throughout this app, an "innings" refers only to a team's innings; _batter innings_ and _bowler innings_ are mentioned as such.

Technically speaking, an innings is essentially a list of balls played; all other information can be derived from that. (Note: It could also be a list of _overs_ but it was simpler to skip that layer). This information includes (but not limited to):

1. Runs scored by the batting team
2. Wickets fallen of the batting team
3. [Batter innings](#batter-innings), i.e., scores of all batsmen
4. [Bowler innings](#bowler-innings), i.e., bowling figures of all bowlers

Batter innings and bowler innings form the building blocks for all player-centric statistics in the sport.

An innings comes to an end when any one of the following happens:

1. The quota of overs is completed (in case of limited overs)
2. The batting team loses all wickets
3. The batting team has scored the required runs (while chasing)
4. The batting team declares

To support dynamic teams (the most common form when cricket is played recreationally), the app does not take into account the 2nd condition. To accommodate the same, the user may choose to declare the innings once all wickets have fallen. Once unlimited overs are supported, the process of declaring an innings will change

#### Batter Innings

A batter's innings, also called a **knock**, consists of a list of [balls](#-ball) played by that batter. Using this, we can derive the following data:

1. Runs scored
2. Number of balls faced

Using the above data, the following statistics can be calculated:

1. Strike rate `(runs scored)÷(number of balls faced)`

#### Bowler Innings

A bowler's innings, also called a **spell**, consists of a list of [balls](#-ball) played by that bowler. Using this, we can derive the following data:

1. Number of overs (or balls) bowled
2. Number of wickets taken
3. Runs conceded
4. Maidens bowled

Using the above data, the following statistics can be calculated:

1. Strike rate `(number of balls bowled)÷(number of wickets taken)`
2. Average `(runs conceded)÷(number of wickets taken)`
3. Economy `[(runs conceded) * (number of balls per over)]÷(number of balls bowled)`

### ⚾️ Ball <a name = "ball"/>

A ball is the most atomic unit for scoring a cricket match. It consists of the following data

1. Bowler
2. Batter
3. Runs scored
4. Wicket, if any
5. Extra, if any

Once this data is obtained for every ball of the match, the score as well as result (if the match is completed) can be derived.

### 🤾 Player <a name = "player"/>

A player is needed to play any sport. Players in cricket take up the role of a batter, bowler and fielder. Since players contribute in more than one ways, tying together their statistics provides a handy way of representing a player's career performance.

TODO: This section will be expanded.

### 📊 Statistics <a name = "statistics"/>

Once the above information is consolidated, statistics can be generated.

TODO: This section will be expanded

---

## 📱 Using the app <a name = "how-to-use"/>

### Home Screen

The Home Screen consists of the following tabs:

1. [Ongoing Matches](#ongoing-and-completed-matches)
2. [Completed Matches](#ongoing-and-completed-matches)
3. [Players](#players-page)
4. [Statistics](#statistics-page)

A new match can be created using the ⨁ button located at the center of the Bottom Navigation Bar.

### Ongoing and Completed Matches

This tab displays a list of all matches that are ongoing, i.e., have been created but not completed. It is a handy view of all matches that are being played at the moment. It might seem unnecessary for now, but once online syncing is added, a user will be able to see all the matches that are available to them.

Similarly, the next tab displays a list of matches that have been completed.

Every match is represented by a tile displaying the scores of both the teams participating in the match. Clicking a tile will open a new page depending on the status of the match. These pages correspond to the lifecycle of a match, which is as follows:

1. [Create a Match](#create-a-match)
2. [Toss](#toss)
3. [Initialize an Innings](#initialize-an-innings)
4. [Match Interface](#match-interface)
5. [Scorecard](#match-scorecard)

Needless to say, every match in the **Completed Matches** section will directly open its scorecard.

Long-pressing any match tile will bring up a menu where you can choose to:

1. Rematch — Quickly create a new match with the same teams. Note that this new match will be completely unrelated to the selected match.
2. Delete — Irreversibly delete the match from storage. Please understand the consequences of this action: ALL STATISTICS FROM THIS MATCH WILL BE DELETED FOREVER! Hence, it is highly recommended to never delete matches unless absolutely necessary.

#### Create a Match

A match is played between two teams. These teams are (conveniently) called _Home Team_ and _Away Team_.

Clicking on either the _Home Team_ or _Away Team_ tile will take you to the **Team Creation** page. On this page, you can choose your team's name, short name, captain and squad. On tapping the _Captain_ or _Add to Squad_ tile, you will be taken to a list of players. Here, tap the desired player or create one if needed.

For example, if I was creating _Mumbai Indians_, I would have the following data:

1. Name: Mumbai Indians
2. Short Name: MI
3. Blue
4. Captain: Rohit Sharma
5. Squad: Jasprit Bumrah, Suryakumar Yadav, Ishan Kishan, Cameron Green, Tim David etc.

(Note: The captain is always part of squad. No need to add them again.)

#### Toss

Every cricket match starts with a toss. A toss is a simple procedure where one captain wins and chooses to either _Bat_ or _Field (Bowl)_ in the first innings. While not necessarily crucial to statistics, the toss can play an important part in the result of the match, making it a valuable piece of information to store.

Select the winning team and their choice. It's as simple as that.

Traditionally, tosses have been conducted by flipping a coin, although recreational matches may feature "Odd or Even" or "Stone-Paper-Scissors" (also called "Rock-Paper-Scissors") between the captains. In the future, a _Conduct Toss_ feature might be added to the app, that will flip a virtual coin.

#### Initialize an Innings

To initialize an innings, select the opening pair from the batting team and the opening bowler from the bowling team. Don't worry if there's an error, these can be changed on the next screen.

---

#### Match Interface

This is where the magic happens.

On the top, you can see the **Score Summary** in the form of two tiles representing the _Home Team_ and _Away Team_. Depending on which innings is being played, the score `Runs/Wickets` is displayed for the batting team and the overs bowled `Over.Ball` is displayed for the bowling team. Tapping on the Score Summary will take you to the match's [scorecard](#match-scorecard).

###### Run Rate Pane

Next, we have the **Run Rate Pane**, which:

1. For the first innings shows the _Run Rate_ and the _Projected Score_
2. For the second innings shows the _Runs Required_, _Balls Left_ and the _Required Run Rate_. The _Required Run Rate_ may be omitted when very few balls are left.

###### Players in Action

Thirdly, we have the **Players In Action** pane, which represents the two batters on the pitch and the bowler who is currently bowling. The two batters are represented as tiles laid out vertically, directly below their team's tile as in the Score Summary header. Similarly, the bowler's tile is placed vertically below the fielding team's tile. In other words, players are of the _Home Team_ are always on the _left_ while players of the _Away Team_ are always on the right, regardless of which team is batting in the ongoing innings.

The Batter Tiles serve an important purpose — selecting the player who is on strike. Usually, this is handled automatically — strike is rotated for odd number of runs and at the end of an over. However, there are possibilities of rules being altered and a '1D' or 3D' being added, in which case the strike will have to be changed manually. The score of each batter is displayed on the tile. For more details on the score, you can always open the [Scorecard](#match-scorecard).

Each of these tiles Player Tiles can be long-pressed to replace the player. You will be taken to a list of players to choose a replacement from. This comes in handy if either a batter or the bowler (or all of them!) has to be replaced, like in the case of an injury. You must note that replacing a bowler will NOT skip or restart the over. Just like international matches, the over will continue to be bowled by a different bowler. If you want to restart the over, use the *Undo* button found in the [Submit Input](#submit-input) pane.

###### Recent Balls

Next in line is the **Recent Balls** list, where the latest balls bowled are displayed for convenience. The number of balls visible depends on the screen size of the device. Clicking on this list will take you to the [Innings Timeline](#innings-timeline). The Recent Balls list follows the same scheme as the Innings Timeline, so read that for more information.

To demarcate the beginning of an over, its first ball has its index in the bowling team's colour.

###### End Innings and Add Wicket

The next row consists of two mostly unrelated interactions:

1. The _End Innings_ button, which can also be called the _Declare_ button. Clicking this will, well, do nothing. You will see a small message pop-up which tells you exactly what you have to do — press and hold this button if you really want to end (or declare) the innings.
2. The _Wicket_ tile, which lets you add a wicket to the ball that is currently being entered. On tapping this tile, you will be taken to a pretty self-explanatory screen where you choose the kind of dismissal (bowled, LBW, run-out etc.) and the players involved in said dismissal. Once a wicket is selected, press and hold this tile to remove the wicket before the ball is entered.

###### Extra Selector

The first section toggles between **Batting Extras**: _Event_ and _Leg Bye_. _Event_ is a stand-in for _Bye_, which should be taking its place, but _Event_ serves a very crucial purpose — recording an event that takes place without a ball being bowled. A very common case is the run-out by the bowler at the non-striker before bowling the ball, as sensationalized by Ravichandran Ashwin when he dismissed Jos Buttler.

Admittedly, it's not possible to enter a _Bye_ for now. It will be added soon enough, but just note that _Event_ is here to stay as well.

For the uninitiated, a Bye is a run scored by the batting team without a batter getting their bat on ball. But if they manage to get their body on ball before scoring the runs, it's called a Leg Bye.

The second section deals with **Bowling Extras**, the infamous _No Balls_ and _Wides_. Do note that while entering this data you are NOT supposed to select the runs awarded to the batting team due to a Bowling Extra. If no runs are scored by the batting team on a No Ball or a Wide, choose 0 runs on the [Run Chooser](#run-selector)

###### Run Selector

It's a list of number from 0 to 6 that represent the number of runs scored on the ball that is being entered. Numbers '4' and '6' are treated specially, since they represent the ever-so-famous boundaries loved by fans of cricket. As it stands, there is no distinction between scoring a four or actually running four runs.

As mentioned earlier, DO NOT select the runs awarded due to a Bowling Extra such as a wide or no ball. Those penalty runs are added automatically.

###### Submit Input

These two buttons do exactly opposite actions
The first one, _Undo_, as the name suggests, will undo the previous ball, i.e., make it as if it was never played. It is removed completely. Discarded. Shredded. Destroyed. Obliterated. As such, you can't "Undo" an "Undo", so don't undo what you don't want to undo. Don't request for a "Redo" feature, just be more careful. (Or do request, maybe I am underestimating the requirement.)

The second button takes on various forms depending on the situation.

1. In most cases, it is a _Next_ button, that submits the data entered from [Run Selector](#run-selector), [Extra Selector](#extra-selector) and [Add a wicket](#end-innings-and-add-wicket). This will cause the [ball](#-ball) to be added into the [innings](#-innings). As result of this, the scores for both the teams and all the players involved will be updated.
2. When an over is completed, it is a _Select Bowler_ button. On clicking, you will be taken to the bowling squad to choose the next bowler.
3. When a wicket falls, it is a _Select Batter_ button. On clicking, you will be taken to the batting squad to choose the next batter.
4. When the quota of overs is completed, or when the _target_ for the second innings is achieved, it is an _End Innings_ button which will act the same as long-pressing the [End Innings button](#end-innings-and-add-wicket).

--- 

### Match Scorecard

The Scorecard screen starts with a simple view of the overall scores of both the teams across all innings played all the way at the top.

If the match is completed, you will see the result of the match right below. This is skipped for [Ongoing Matches](#ongoing-and-completed-matches).

Next, for each team's innings, a list of [batter innings](#batter-innings) and [bowler innings](#bowler-innings) is displayed.

1. For each batter innings, you will see two numbers towards the far right: The runs scored on the top and the balls faced at the bottom. Additionally, the wicket status of the batter is specified directly below their name.
2. For each bowler innings, you will see the short bowling figures towards the far right in the format of `(Wickets Taken)/(Runs Scored)`. Right below that is the bowling average of the bowler. Additionally, the number of overs bowled and the economy is displayed directly below the bowler's name.

Finally, a _View Timeline_ button takes you to the [Innings Timeline](#innings-timeline)

---

#### Innings Timeline <a name = "innings-timeline"/>

This screen displays a vertical, chronological timeline of balls bowled in the innings, with the last ball at the bottom and the first ball at the top.

The timeline is segmented into overs.

Each over's segment starts with the Over's ordinal index. Each row represents a [ball](#-ball) displaying the following data from left to right:

1. The timestamp (in local time) at which the ball was bowled
2. The [Ball Symbol](#ball-symbol)
3. The Bowler and the Batter
4. Wicket, if any

###### Ball Symbol <a name = "ball-symbol"/>

I really couldn't come up with a better name, but it's the shorthand representation of the ball with the following data

1. The runs scored, denoted by a number in a circle
2. The `Over.Ball` index of the ball, displayed directly below the run's circle

The circle's colour and the border of this circle gives a quick look at what transpired using the same colours as seen in [Colour Lookup](#-colour-lookup).

The circle's colour represents the boundary or wicket that transpired on the ball.
The border represents a Bowling Extra and is absent if the ball is a legal delivery.

---

### Players Page

A simple management page where you can create and edit players.

Creating a player is simple: Tap the _Add a Player_ tile and fill in the form with basic details such as Name, Batting arm, Bowling arm and style. You can also add a picture if you like (recommended!).

Note: Currently, deleting players is not an option because. Why? Here's a detailed explanation: Deleting a player that has played a match will cause disastrous consequences like a non-existent player bowling a ball or hitting a six. That's a nightmare. To avoid this, for now, players can't be deleted once created.

### Statistics Page

This is where you will see the statistics of all your players.

Right now, it is quite basic with all players from all teams that have played any match thrown onto your screen. Batters are sorted by their runs scored while bowlers are sorted by wickets taken.

In the future, filters and other parameters such as strike rates and averages will be added to make this screen useful. Another statistics screen for each player will also be added, where you will see all the statistics of that player.

---

### 🎨 Colour Lookup <a name = "colour-lookup"/>

With respect to a [Ball](#-ball):

- ![indigo](https://placehold.co/15x15/536DFE/536DFE) Indigo for a Four
- ![ruby](https://placehold.co/15x15/E91E63/E91E63) Ruby for a Six
- ![red](https://placehold.co/15x15/F44336/F44336) Red for a Wicket
- ![yellow](https://placehold.co/15x15/FFFF00/FFFF00) Yellow for a No Ball
- ![white](https://placehold.co/15x15/FFFFFF/FFFFFF) White for a Wide

The colours available for assigning to a Team:

- ![blue](https://placehold.co/15x15/2196F3/2196F3) Blue
- ![orange](https://placehold.co/15x15/FF5722/FF5722) Orange
- ![grey](https://placehold.co/15x15/616161/616161) Grey
- ![green](https://placehold.co/15x15/4CAF50/4CAF50) Green
- ![cyan](https://placehold.co/15x15/00BCD4/00BCD4) Cyan
- ![brown](https://placehold.co/15x15/795548/795548) Brown
- ![yellow](https://placehold.co/15x15/CDDC39/CDDC39) Yellow
- ![violet](https://placehold.co/15x15/673AB7/673AB7) Violet

---

## 🔮 In the Future... <a name = "future-scope"/>

- Add screenshots to README.md
- Add online syncing
- Add filters to statistics
- Add Settings and Customizations
- Add support for Test Matches (Unlimited Overs)
- Add **Tournaments** and **Series**
- Fielding statistics
- Track multiple sports

---

## ✍️ Authors <a name = "authors"/>

- [@PlayPratz](https://github.com/PlayPratz) - Ideation, Documentation and App Development
