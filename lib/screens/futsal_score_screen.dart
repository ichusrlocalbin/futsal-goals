import 'dart:math';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'yearly_score_screen.dart';
import 'screens.dart~';

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
  String selectedDateStr = DateFormat('yyyyMMdd').format(DateTime.now());

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
    });
  }

  void _updateFireStore(String date, dynamic score) async {
    if (currentUser == null) return;
    final DocumentSnapshot user =
        await firestore.collection('users').doc(currentUser!.uid).get();
    if (user.exists) {
      firestore
          .collection('users')
          .doc('${currentUser!.uid}/scores/$date')
          .update(score);
    } else {
      firestore
          .collection('users')
          .doc('${currentUser!.uid}/scores/$date')
          .set(score);
    }
  }

  void _incrementScore(Score score) {
    _inCrementOrDecrementScore(score, true);
  }

  void _decrementScore(Score score) {
    _inCrementOrDecrementScore(score, false);
  }

  void _inCrementOrDecrementScore(Score score, bool isIncrement) {
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
    _updateFireStore(selectedDateStr, {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FloatingActionButton(
              onPressed: () => _selectDate(context),
              tooltip: 'SelectDate',
              child: const Icon(Icons.calendar_month),
            ),
            const Icon(Icons.sports_soccer),
            Text(
              '$goals',
            ),
            FloatingActionButton(
              onPressed: () => _incrementScore(Score.goals),
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            ),
            FloatingActionButton(
              onPressed: () => _decrementScore(Score.goals),
              tooltip: 'Decrement',
              child: const Icon(Icons.exposure_minus_1),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Column(children: <Widget>[
                Text(
                  'o: $wins',
                ),
                FloatingActionButton(
                  onPressed: () => _incrementScore(Score.wins),
                  tooltip: 'Increment',
                  child: const Icon(Icons.add),
                ),
                FloatingActionButton(
                  onPressed: () => _decrementScore(Score.wins),
                  tooltip: 'Decrement',
                  child: const Icon(Icons.exposure_minus_1),
                ),
              ]),
              Column(children: <Widget>[
                Text(
                  '△: $draws',
                ),
                FloatingActionButton(
                  onPressed: () => _incrementScore(Score.draws),
                  tooltip: 'Increment',
                  child: const Icon(Icons.add),
                ),
                FloatingActionButton(
                  onPressed: () => _decrementScore(Score.draws),
                  tooltip: 'Decrement',
                  child: const Icon(Icons.exposure_minus_1),
                ),
              ]),
              Column(children: <Widget>[
                Text(
                  'x: $losses',
                ),
                FloatingActionButton(
                  onPressed: () => _incrementScore(Score.losses),
                  tooltip: 'Increment',
                  child: const Icon(Icons.add),
                ),
                FloatingActionButton(
                  onPressed: () => _decrementScore(Score.losses),
                  tooltip: 'Decrement',
                  child: const Icon(Icons.exposure_minus_1),
                ),
              ]),
            ]),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Screen.yearlyScore.name),
              child: const Text('年間情報'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _signOut,
        tooltip: 'SignOut',
        child: const Icon(Icons.logout),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
