import 'dart:math';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'screens.dart';
import 'login_screen.dart';
import '../utils.dart';

class FutsalScorePage extends StatefulWidget {
  const FutsalScorePage({super.key, required this.title});

  final String title;

  @override
  State<FutsalScorePage> createState() => _FutsalScorePageState();
}

enum Score { goals, wins, draws, losses }

class _FutsalScorePageState extends State<FutsalScorePage> {
  int goals = 0;
  int wins = 0;
  int draws = 0;
  int losses = 0;
  bool ignoreInCalculation = false;
  String selectedDateStr = DateFormat('yyyyMMdd').format(DateTime.now());
  double runningDistance = 0.0;
  String memo = '';

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
    _loadScores();
  }

  void _loadScores() async {
    if (currentUser == null) return;
    DocumentSnapshot snapshot = await firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('scores')
        .doc(selectedDateStr)
        .get();
    if (snapshot.exists && snapshot.data() != null) {
      final data = snapshot.data()! as Map<String, dynamic>;
      setState(() {
        goals = data['goals'] ?? 0;
        wins = data['wins'] ?? 0;
        draws = data['draws'] ?? 0;
        losses = data['losses'] ?? 0;
        ignoreInCalculation = data['ignoreInCalculation'] ?? false;
        runningDistance = data['runningDistance'] ?? 0;
        memo = data['memo'] ?? '';
      });
    } else {
      _resetScores();
    }
  }

  void _resetScores() {
    setState(() {
      goals = 0;
      wins = 0;
      draws = 0;
      losses = 0;
      ignoreInCalculation = false;
      runningDistance = 0;
      memo = '';
    });
  }

  void _updateFirestore(String date, dynamic score) async {
    if (currentUser == null) return;
    final path = '${currentUser!.uid}/scores/$date';
    final DocumentSnapshot data =
        await firestore.collection('users').doc(path).get();
    if (data.exists) {
      firestore.collection('users').doc(path).update(score);
    } else {
      firestore.collection('users').doc(path).set(score);
    }
  }

  void _deleteFireStore(String date) async {
    if (currentUser == null) return;
    final path = '${currentUser!.uid}/scores/$date';
    final DocumentSnapshot data =
        await firestore.collection('users').doc(path).get();
    if (!data.exists) return;
    firestore.collection('users').doc(path).delete();
  }

  void _incrementScore(Score score) {
    _inCrementOrDecrementScore(score, true);
  }

  void _decrementScore(Score score) {
    _inCrementOrDecrementScore(score, false);
  }

  void _inCrementOrDecrementScore(Score score, bool isIncrement) {
    //debug
    // print(
    //     'screen size: (${MediaQuery.of(context).size.width} x ${MediaQuery.of(context).size.height})');
    if (currentUser == null) return;
    setState(() {
      switch (score) {
        case Score.goals:
          goals = isIncrement ? goals + 1 : max(goals - 1, 0);
        case Score.wins:
          wins = isIncrement ? wins + 1 : max(wins - 1, 0);
        case Score.draws:
          draws = isIncrement ? draws + 1 : max(draws - 1, 0);
        case Score.losses:
          losses = isIncrement ? losses + 1 : max(losses - 1, 0);
      }
    });
    _updateFirestore(selectedDateStr, {
      'goals': goals,
      'wins': wins,
      'draws': draws,
      'losses': losses,
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final selectedDate = DateTime.parse(selectedDateStr);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(selectedDateStr),
      firstDate: DateTime(selectedDate.year - 10),
      lastDate: DateTime(selectedDate.year + 10),
    );
    if (picked == null) return;
    final pickedDateStr = DateFormat('yyyyMMdd').format(picked);
    if (pickedDateStr != selectedDateStr) {
      setState(() {
        selectedDateStr = pickedDateStr;
        _loadScores();
      });
    }
  }

  Future<void> _signOut() async {
    if (currentUser == null) return;
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final goalBiggerButton = OverlapButtonProperties(
      onPressed: () => _incrementScore(Score.goals),
      size: 70,
      iconColor: Colors.white,
      backgroundColor: Colors.lightBlue.shade700,
      iconData: Icons.sports_soccer,
    );
    final goalSmallerButton = OverlapButtonProperties(
      onPressed: () => _decrementScore(Score.goals),
      size: 30,
      iconColor: Colors.white,
      backgroundColor: Colors.lightBlue,
      iconData: Icons.arrow_circle_down_outlined,
    );
    final winBiggerButton = OverlapButtonProperties(
      onPressed: () => _incrementScore(Score.wins),
      size: 70,
      iconColor: Colors.white,
      backgroundColor: Colors.green.shade700,
      iconData: Icons.circle_outlined,
    );
    final winSmallerButton = OverlapButtonProperties(
      onPressed: () => _decrementScore(Score.wins),
      size: 30,
      iconColor: Colors.white,
      backgroundColor: Colors.green,
      iconData: Icons.arrow_circle_down_outlined,
    );
    final drawBiggerButton = OverlapButtonProperties(
      onPressed: () => _incrementScore(Score.draws),
      size: 70,
      iconColor: Colors.white,
      backgroundColor: Colors.amber.shade700,
      iconData: Icons.change_history,
    );
    final drawSmallerButton = OverlapButtonProperties(
      onPressed: () => _decrementScore(Score.draws),
      size: 30,
      iconColor: Colors.white,
      backgroundColor: Colors.amber,
      iconData: Icons.arrow_circle_down_outlined,
    );
    final lossBiggerButton = OverlapButtonProperties(
      onPressed: () => _incrementScore(Score.losses),
      size: 70,
      iconColor: Colors.white,
      backgroundColor: Colors.red.shade700,
      iconData: Icons.clear_outlined,
    );
    final lossSmallerButton = OverlapButtonProperties(
      onPressed: () => _decrementScore(Score.losses),
      size: 30,
      iconColor: Colors.white,
      backgroundColor: Colors.red,
      iconData: Icons.arrow_circle_down_outlined,
    );

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          actions: <Widget>[
            IconButton(
                icon: const Icon(Icons.edit),
                tooltip: '${Utils.dateFormatString(selectedDateStr)}データ詳細編集',
                onPressed: () => _showDailyDetailData(context)),
            IconButton(
                icon: Icon(Icons.table_view_outlined,
                    color: Theme.of(context).colorScheme.secondary),
                tooltip: '年間情報画面',
                onPressed: () =>
                    Navigator.pushNamed(context, Screen.yearlyScore.name)),
          ]),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Text(
                Utils.dateFormatString(selectedDateStr),
                style: const TextStyle(fontSize: 36),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: IconButton.filledTonal(
                    onPressed: () => _selectDate(context),
                    tooltip: 'Select Date',
                    icon: const Icon(Icons.calendar_month),
                  )),
            ]),
            Text(
              '$goals',
              style: const TextStyle(fontSize: 80),
            ),
            SizedBox(
              height: 100,
              width: 100,
              child: OverlapCircleTwoButtons(
                  biggerButton: goalBiggerButton,
                  smallerButton: goalSmallerButton),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Column(children: <Widget>[
                Text(
                  wins.toString(),
                  style: const TextStyle(fontSize: 80),
                ),
                SizedBox(
                  height: 100,
                  width: 100,
                  child: OverlapCircleTwoButtons(
                      biggerButton: winBiggerButton,
                      smallerButton: winSmallerButton),
                ),
              ]),
              Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(children: <Widget>[
                    Text(
                      draws.toString(),
                      style: const TextStyle(fontSize: 80),
                    ),
                    SizedBox(
                      height: 100,
                      width: 100,
                      child: OverlapCircleTwoButtons(
                          biggerButton: drawBiggerButton,
                          smallerButton: drawSmallerButton),
                    ),
                  ])),
              Column(children: <Widget>[
                Text(
                  losses.toString(),
                  style: const TextStyle(fontSize: 80),
                ),
                SizedBox(
                  height: 100,
                  width: 100,
                  child: OverlapCircleTwoButtons(
                      biggerButton: lossBiggerButton,
                      smallerButton: lossSmallerButton),
                ),
              ]),
            ]),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _signOut,
      //   tooltip: 'SignOut',
      //   child: const Icon(Icons.logout),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
      drawer: _FutsalScoreDrawer(context, this),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('${Utils.dateFormatString(selectedDateStr)}データ削除'),
          content: const Text('本当に削除しますか？'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              // onPressed: () => Navigator.pop(context),
              onPressed: () {
                Navigator.pop(context); // AlertDialog
                Navigator.pop(context); // Drawer
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                _deleteFireStore(selectedDateStr);
                _resetScores();
                Navigator.pop(context); // AlertDialog
                Navigator.pop(context); // Drawer
              },
            ),
          ],
        );
      },
    );
  }

  void _showDailyDetailData(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              //  A bottom sheet uses a different context so calling setState does not work. cf. https://stackoverflow.com/a/52883373
              builder: (BuildContext context, StateSetter stateSetter) {
            return ListView(children: <Widget>[
              ListTile(
                title: const Text('走行距離(km)'),
                trailing: SizedBox(
                  width: 100,
                  child: TextFormField(
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    initialValue: (runningDistance == 0)
                        ? ''
                        : runningDistance.toString(),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^[0-9]+.?[0-9]*'))
                    ],
                    onChanged: (value) {
                      stateSetter(() {
                        runningDistance = value == '' ? 0 : double.parse(value);
                      });
                      _updateFirestore(selectedDateStr, {
                        'runningDistance': runningDistance,
                      });
                    },
                  ),
                ),
              ),
              ListTile(
                title: const Text('メモ'),
                trailing: SizedBox(
                  width: 400,
                  child: TextFormField(
                    initialValue: memo ?? '',
                    onChanged: (value) {
                      stateSetter(() {
                        memo = value;
                      });
                      _updateFirestore(selectedDateStr, {
                        'memo': memo,
                      });
                    },
                  ),
                ),
              ),
              ListTile(
                title: const Text('計算対象外'),
                trailing: Switch(
                  // thumbIcon: MaterialStateProperty.resolveWith<Icon?>(
                  //   (Set<MaterialState> states) {
                  //     if (states.contains(MaterialState.selected)) {
                  //       return const Icon(Icons.check);
                  //     }
                  //     return const Icon(Icons.close);
                  //   },
                  // ),
                  value: ignoreInCalculation,
                  onChanged: (value) {
                    stateSetter(() {
                      ignoreInCalculation = value;
                    });
                    _updateFirestore(selectedDateStr, {
                      'ignoreInCalculation': ignoreInCalculation,
                    });
                  },
                ),
              ),
              ListTile(
                  title: RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        text:
                            '${Utils.dateFormatString(selectedDateStr)}データ削除 '),
                    const WidgetSpan(
                      child: Icon(Icons.delete, color: Colors.redAccent),
                    ),
                  ])),
                  onTap: () {
                    _showDeleteDialog(context);
                  }),
            ]);
          });
        });
  }
}

class _FutsalScoreDrawer extends Drawer {
  final _FutsalScorePageState state;

  _FutsalScoreDrawer(BuildContext context, this.state)
      : super(
          child: ListView(
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  '得点記録',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                title: RichText(
                    text: TextSpan(children: [
                  const TextSpan(text: 'ログアウト '),
                  WidgetSpan(
                    child: Icon(Icons.logout, color: Colors.grey.shade700),
                  ),
                ])),
                onTap: state._signOut,
              ),
            ],
          ),
        );
}

class OverlapButtonProperties {
  final void Function() onPressed;
  final double size;
  final Color iconColor;
  final Color backgroundColor;
  final IconData iconData;

  const OverlapButtonProperties({
    required this.onPressed,
    required this.size,
    required this.iconColor,
    required this.backgroundColor,
    required this.iconData,
  });
}

class OverlapCircleTwoButtons extends StatelessWidget {
  final OverlapButtonProperties biggerButton;
  final OverlapButtonProperties smallerButton;

  const OverlapCircleTwoButtons({
    super.key,
    required this.biggerButton,
    required this.smallerButton,
  });
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Positioned(
          child: ElevatedButton(
            onPressed: biggerButton.onPressed,
            child: Icon(biggerButton.iconData,
                color: biggerButton.iconColor, size: biggerButton.size),
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(15),
              backgroundColor: biggerButton.backgroundColor,
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(-50, 55),
          child: ElevatedButton(
            onPressed: smallerButton.onPressed,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(8.0),
              backgroundColor: smallerButton.backgroundColor,
              side: const BorderSide(width: 1.5, color: Colors.white),
            ),
            child: Icon(smallerButton.iconData,
                color: Colors.white, size: smallerButton.size),
          ),
        ),
      ],
    );
  }
}
