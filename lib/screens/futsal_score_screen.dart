import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FutsalScorePage extends StatefulWidget {
  const FutsalScorePage({super.key, required this.title});

  final String title;

  @override
  State<FutsalScorePage> createState() => _FutsalScorePageState();
}

class _FutsalScorePageState extends State<FutsalScorePage> {
  int goals = 0;
  int wins = 0;
  int draws = 0;
  int losses = 0;

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
        .doc('today')
        .get();
    if (!snapshot.exists) {
      _createUserScores();
    }
    final data = snapshot.data()! as Map<String, dynamic>;
    setState(() {
      goals = data['goals'] ?? 0;
      wins = data['wins'] ?? 0;
      draws = data['draws'] ?? 0;
      losses = data['losses'] ?? 0;
    });
  }

  void _createUserScores() async {
    if (currentUser == null) return;
    await firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('scores')
        .doc('today')
        .set({});
  }

  void _incrementGoals() {
    if (currentUser == null) return;
    setState(() {
      goals++;
    });
    firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('scores')
        .doc('today')
        .update({
      'goals': goals,
    });
  }

  void _incrementResult(String result) {
    if (currentUser == null) return;
    setState(() {
      if (result == 'wins') {
        wins++;
      } else if (result == 'draws') {
        draws++;
      } else if (result == 'losses') {
        losses++;
      }
    });
    firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('scores')
        .doc('today')
        .update({
      'wins': wins,
      'draws': draws,
      'losses': losses,
    });
  }

  void _resetGoals() {
    if (currentUser == null) return;
    setState(() {
      goals = 0;
    });
    firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('scores')
        .doc('today')
        .update({
      'goals': 0,
    });
  }

  void _resetWins() {
    if (currentUser == null) return;
    setState(() {
      wins = 0;
    });
    firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('scores')
        .doc('today')
        .update({
      'wins': 0,
    });
  }

  void _resetDraws() {
    if (currentUser == null) return;
    setState(() {
      draws = 0;
    });
    firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('scores')
        .doc('today')
        .update({
      'draws': 0,
    });
  }

  void _resetLosses() {
    if (currentUser == null) return;
    setState(() {
      losses = 0;
    });
    firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('scores')
        .doc('today')
        .update({
      'losses': 0,
    });
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
            const Icon(Icons.sports_soccer),
            Text(
              '$goals',
            ),
            FloatingActionButton(
              onPressed: _incrementGoals,
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            ),
            ElevatedButton(
              onPressed: _resetGoals,
              child: const Icon(Icons.exposure_zero),
            ),
            Text(
              'o: $wins',
            ),
            FloatingActionButton(
              onPressed: () => _incrementResult('wins'),
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            ),
            ElevatedButton(
              onPressed: _resetWins,
              child: const Text('リセット'),
            ),
            Text(
              '△: $draws',
            ),
            FloatingActionButton(
              onPressed: () => _incrementResult('draws'),
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            ),
            ElevatedButton(
              onPressed: _resetDraws,
              child: const Text('リセット'),
            ),
            Text(
              'x: $losses',
            ),
            FloatingActionButton(
              onPressed: () => _incrementResult('losses'),
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            ),
            ElevatedButton(
              onPressed: _resetLosses,
              child: const Text('リセット'),
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
