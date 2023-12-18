import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'screens.dart';
import '../utils.dart';

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
  double lossRate = 0.0;
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
      int ignoreDays = 0;

      for (var doc in yearlySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['date'] = doc.id;
        tempScores.add(data);
        if (data['ignoreInCalculation'] != null &&
            data['ignoreInCalculation']!) {
          ignoreDays++;
        } else {
          totalGoals += data['goals'] as int? ?? 0;
          totalWins += data['wins'] as int? ?? 0;
          totalDraws += data['draws'] as int? ?? 0;
          totalLosses += data['losses'] as int? ?? 0;
        }
      }

      totalPlayedDays = tempScores.length;
      num totalPlayed = totalWins + totalDraws + totalLosses;
      winRate = totalPlayed > 0 ? totalWins / totalPlayed : 0.0;
      lossRate = totalPlayed > 0 ? totalLosses / totalPlayed : 0.0;
      averageGoalsPerDay =
          tempScores.isNotEmpty && (tempScores.length - ignoreDays) != 0
              ? totalGoals / (tempScores.length - ignoreDays)
              : 0.0;

      setState(() {
        dailyScores = tempScores;
        yearlyGoals = totalGoals;
        yearlyWins = totalWins;
        yearlyDraws = totalDraws;
        yearlyLosses = totalLosses;
        totalPlayedDays = tempScores.length - ignoreDays;
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
                        final pickerYearStr =
                            DateFormat('yyyy').format(dateTime);
                        if (pickerYearStr != selectedYearStr) {
                          setState(() {
                            selectedYearStr = pickerYearStr;
                            _calculateYearlyScores();
                          });
                        }
                      })));
        });
  }

  void generateAndDownloadCsv() {
    final dailyScoresList = dailyScores
        .map((score) => [
              Utils.dateFormatString(score['date']),
              (score['goals'] ?? 0).toString(),
              (score['wins'] ?? 0).toString(),
              (score['draws'] ?? 0).toString(),
              (score['losses'] ?? 0).toString(),
              (score['ignoreInCalculation'] ?? '').toString(),
              (score['runningDistance'] ?? '').toString(),
            ])
        .toList();
    dailyScoresList
        .insert(0, ["日付", "ゴール数", "勝ち", "引き分け", "負け", "対象外", "走行距離"]);
    String csvData = const ListToCsvConverter().convert(dailyScoresList);
    final bytes = utf8.encode(csvData);
    final blob = html.Blob([bytes], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', '${selectedYearStr}_scores.csv')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.white,
          title: Text('年間情報'),
          actions: <Widget>[
            IconButton(
                icon: const Icon(Icons.cloud_download_outlined),
                tooltip: '${selectedYearStr}年データダウンロード',
                onPressed: () => generateAndDownloadCsv()),
            IconButton(
                icon: Icon(Icons.edit_calendar_outlined,
                    color: Theme.of(context).colorScheme.inversePrimary),
                tooltip: '得点記録画面',
                onPressed: () =>
                    Navigator.pushNamed(context, Screen.futsalScore.name)),
          ]),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 年間データ
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Text(
                '${selectedYearStr}年',
                style: const TextStyle(fontSize: 36),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: IconButton.filledTonal(
                    onPressed: () => _selectYear(context),
                    tooltip: 'Select Year',
                    icon: const Icon(Icons.calendar_month),
                  )),
            ]),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: <DataColumn>[
                  const DataColumn(label: Icon(Icons.sports_soccer)),
                  const DataColumn(label: Text('日数')),
                  const DataColumn(label: Text('勝')),
                  const DataColumn(label: Text('分')),
                  const DataColumn(label: Text('負')),
                ],
                rows: [
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text(yearlyGoals.toString())),
                      DataCell(Text(totalPlayedDays.toString())),
                      DataCell(Text(yearlyWins.toString())),
                      DataCell(Text(yearlyDraws.toString())),
                      DataCell(Text(yearlyLosses.toString())),
                    ],
                  )
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: <DataColumn>[
                  DataColumn(
                      label: RichText(
                          text: const TextSpan(children: [
                    WidgetSpan(child: Icon(Icons.sports_soccer)),
                    TextSpan(text: '/日'),
                  ]))),
                  const DataColumn(label: Text('勝率')),
                  const DataColumn(label: Text('負け率')),
                ],
                rows: [
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text(averageGoalsPerDay.toStringAsFixed(1))),
                      DataCell(Text((winRate * 100).toStringAsFixed(0) + '%')),
                      DataCell(Text((lossRate * 100).toStringAsFixed(0) + '%')),
                    ],
                  )
                ],
              ),
            ),
            // 各日のスコア表示部分
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const <DataColumn>[
                  DataColumn(label: Text('日付')),
                  DataColumn(label: Icon(Icons.sports_soccer)),
                  DataColumn(label: Text('勝')),
                  DataColumn(label: Text('分')),
                  DataColumn(label: Text('負')),
                  DataColumn(label: Text('対象外')),
                  DataColumn(label: Text('km')),
                  DataColumn(label: Text('km/試合')),
                ],
                rows: dailyScores.map<DataRow>((score) {
                  int g = score['goals'] ?? 0;
                  int w = score['wins'] ?? 0;
                  int d = score['draws'] ?? 0;
                  int l = score['losses'] ?? 0;
                  double? r = score['runningDistance'];
                  return DataRow(
                    cells: <DataCell>[
                      DataCell(Text(Utils.dateFormatString(score['date']))),
                      DataCell(Text(g.toString())),
                      DataCell(Text(w.toString())),
                      DataCell(Text(d.toString())),
                      DataCell(Text(l.toString())),
                      DataCell((score['ignoreInCalculation'] ?? false)
                          ? Icon(Icons.check)
                          : Text('')),
                      DataCell(Text((r ?? '').toString())),
                      DataCell(Text(((r == null || w + d + l == 0)
                          ? ''
                          : (r / (w + d + l)).toStringAsFixed(1)))),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
