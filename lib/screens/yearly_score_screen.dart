import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'futsal_score_screen.dart';
import 'screens.dart';

class YearlyScorePage extends StatefulWidget {
  @override
  _YearlyScorePageState createState() => _YearlyScorePageState();
}

class _YearlyScorePageState extends State<YearlyScorePage> {
  List<Map<String, dynamic>> dailyScores = [];
  int yearlyGoals = 0;
  int yearlyWins = 0;
  int yearlyDraws = 0;
  int yearlyLosses = 0;
  int totalPlayedDays = 0;
  double winRate = 0.0;
  double averageGoalsPerDay = 0.0;
  String selectedYearStr = DateFormat('yyyy').format(DateTime.now());

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
    _calculateYearlyScores();
  }

  void _calculateYearlyScores() async {
    if (currentUser != null) {
      String startOfYear = '${selectedYearStr}0101';
      String endOfYear = '${selectedYearStr}1231';

      QuerySnapshot yearlySnapshot = await firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('scores')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: startOfYear)
          .where(FieldPath.documentId, isLessThanOrEqualTo: endOfYear)
          .get();

      List<Map<String, dynamic>> tempScores = [];
      int totalGoals = 0;
      int totalWins = 0;
      int totalDraws = 0;
      int totalLosses = 0;

      for (var doc in yearlySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['date'] = doc.id;
        tempScores.add(data);
        totalGoals += data['goals'] as int? ?? 0;
        totalWins += data['wins'] as int? ?? 0;
        totalDraws += data['draws'] as int? ?? 0;
        totalLosses += data['losses'] as int? ?? 0;
      }

      totalPlayedDays = tempScores.length;
      num totalPlayed = totalWins + totalDraws + totalLosses;
      winRate = totalPlayed > 0 ? totalWins / totalPlayed : 0.0;
      averageGoalsPerDay =
          tempScores.isNotEmpty ? totalGoals / tempScores.length : 0.0;

      setState(() {
        dailyScores = tempScores;
        yearlyGoals = totalGoals;
        yearlyWins = totalWins;
        yearlyDraws = totalDraws;
        yearlyLosses = totalLosses;
        totalPlayedDays = tempScores.length;
      });
    }
  }

  Future<void> _selectYear(BuildContext context) async {
    var selectedYear = DateTime.parse('${selectedYearStr}0101');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Year'),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              initialDate: selectedYear,
              firstDate: DateTime(selectedYear.year - 10),
              lastDate: DateTime(selectedYear.year + 10),
              selectedDate: selectedYear,
              onChanged: (DateTime dateTime) {
                Navigator.pop(context);
                final pickerYearStr = DateFormat('yyyy').format(dateTime);
                if (pickerYearStr != selectedYearStr) {
                  setState(() {
                      selectedYearStr = pickerYearStr;
                      _calculateYearlyScores();
                  });
                }
            })
          )
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${selectedYearStr}年 年間情報'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 年間データ
            FloatingActionButton(
              onPressed: () => _selectYear(context),
              tooltip: 'Select Year',
              child: const Icon(Icons.calendar_month),
            ),
            DataTable(
              columns: const <DataColumn>[
                DataColumn(label: Text('ゴール')),
                DataColumn(label: Text('日数')),
                DataColumn(label: Text('勝')),
                DataColumn(label: Text('分')),
                DataColumn(label: Text('負')),
                DataColumn(label: Text('ゴール/日')),
                DataColumn(label: Text('勝率')),
              ],
              rows: [
                DataRow(
                  cells: <DataCell>[
                    DataCell(Text(yearlyGoals.toString())),
                    DataCell(Text(totalPlayedDays.toString())),
                    DataCell(Text(yearlyWins.toString())),
                    DataCell(Text(yearlyDraws.toString())),
                    DataCell(Text(yearlyLosses.toString())),
                    DataCell(Text(averageGoalsPerDay.toStringAsFixed(1))),
                    DataCell(Text((winRate * 100).toStringAsFixed(0) + '%')),
                  ],
                )
              ],
            ),
            // 各日のスコア表示部分
            DataTable(
              columns: const <DataColumn>[
                DataColumn(label: Text('日付')),
                DataColumn(label: Text('ゴール')),
                DataColumn(label: Text('勝ち')),
                DataColumn(label: Text('引き分け')),
                DataColumn(label: Text('負け')),
              ],
              rows: dailyScores.map<DataRow>((score) {
                return DataRow(
                  cells: <DataCell>[
                    DataCell(Text(
                        "${score['date'].substring(0, 4)}/${score['date'].substring(4, 6)}/${score['date'].substring(6, 8)}")),
                    DataCell(Text((score['goals'] ?? 0).toString())),
                    DataCell(Text((score['wins'] ?? 0).toString())),
                    DataCell(Text((score['draws'] ?? 0).toString())),
                    DataCell(Text((score['losses'] ?? 0).toString())),
                  ],
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Screen.futsalScore.name),
              child: const Text('得点記録'),
            ),
          ],
        ),
      ),
    );
  }
}
