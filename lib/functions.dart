import 'package:flutter/widgets.dart';

import 'models/task.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalculationFunctions {
  Future<List<dynamic>> calculateTotalTime(List<Task> chartData) async {
    int totalTime = 0;
    for (int i = 0; i < chartData.length; i++) {
      totalTime = chartData[i].time + totalTime;
    }
    if (totalTime < 60) {
      return [
        (totalTime.toString() + 'mins'),
        totalTime,
      ];
    } else {
      return [
        ((totalTime ~/ 60).toString() +
            ' h ' +
            (totalTime % 60).toString() +
            ' min'),
        totalTime,
      ];
    }
  }

  int getTotalWorkMinutes(Map<String, String> dateRange) {
    return getDifferenceWithoutWeekends(dateRange) * 480;
  }

  int getDifferenceWithoutWeekends(Map<String, String> dateRange) {
    int nbDays = 0;
    DateTime currentDay = DateFormat('yyyy-MM-dd').parse(dateRange['start']);
    //print(currentDay);
    while (
        currentDay.isBefore(DateFormat('yyyy-MM-dd').parse(dateRange['end'])) ||
            currentDay.isAtSameMomentAs(
                DateFormat('yyyy-MM-dd').parse(dateRange['end']))) {
      currentDay = currentDay.add(Duration(days: 1));
      if (currentDay.weekday != DateTime.saturday &&
          currentDay.weekday != DateTime.sunday) {
        nbDays += 1;
      }
    }
    return nbDays;
  }

  List<Task> getDaysInBeteween(Map<String, String> dateRange) {
    List<Task> daysList = [];
    DateTime startDate = DateFormat('yyyy-MM-dd').parse(dateRange['start']);
    DateTime endDate = DateFormat('yyyy-MM-dd').parse(dateRange['end']);
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      daysList.add(Task.fromMap({
        'name': null,
        'date': DateTime(startDate.year, startDate.month, startDate.day + i)
            .toString()
            .substring(0, 10),
        'time': null,
      }));
    }
    return daysList;
  }

  List<List<Task>> fillListsWithDays(
      List<List<Task>> splineList, Map<String, String> dateRange) {
    DateTime startDate = DateFormat('yyyy-MM-dd').parse(dateRange['start']);
    DateTime endDate = DateFormat('yyyy-MM-dd').parse(dateRange['end']);
    splineList.forEach(
      (element) {
        for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
          String date =
              DateTime(startDate.year, startDate.month, startDate.day + i)
                  .toString()
                  .substring(0, 10);
          element.firstWhere((el) => el.date == date, orElse: () => null) ==
                  null
              ? element.add(
                  Task.fromMap(
                    {
                      'name': element[0].name,
                      'date': DateTime(startDate.year, startDate.month,
                              startDate.day + i)
                          .toString()
                          .substring(0, 10),
                      'time': null,
                    },
                  ),
                )
              : DoNothingAction();
        }
        element.sort((a, b) {
          return DateFormat('yyyy-MM-dd')
              .parse(a.date)
              .compareTo(DateFormat('yyyy-MM-dd').parse(b.date));
        });
      },
    );
    return splineList;
  }

  Future<Map<String, dynamic>> prepareChartData(
      List<QueryDocumentSnapshot> documentsList,
      Map<String, String> dateRange) async {
    int startDate = int.parse(dateRange['start'].replaceAll(RegExp('-'), ''));
    int endDate = int.parse(dateRange['end'].replaceAll(RegExp('-'), ''));
    List<Task> splineList = [];
    List<String> namesList = [];
    Map<String, Map<String, dynamic>> overviewMap = {};
    List<Task> tasksList = [];
    List<List<Task>> splineChartData = [];
    Map<String, dynamic> returnMap = {};
    documentsList.forEach((element) async {
      int documentDate = int.parse(element.id.replaceAll(RegExp('-'), ''));
      // filter loop of calendar days
      if (documentDate >= startDate && documentDate <= endDate) {
        // loop of one day tasks
        for (int i = 0; i < element.data().values.length; i++) {
          overviewMap[element.data().values.elementAt(i)['name']] = {
            'time':
                overviewMap[element.data().values.elementAt(i)['name']] == null
                    ? element.data().values.elementAt(i)['time']
                    : overviewMap[element.data().values.elementAt(i)['name']]
                            ['time'] +
                        element.data().values.elementAt(i)['time'],
            'name': element.data().values.elementAt(i)['name'],
            'date': element.id,
          };
          namesList.contains(element.data().values.elementAt(i)['name'])
              ? DoNothingAction()
              : namesList.add(element.data().values.elementAt(i)['name']);
          splineList.add(Task.fromMap({
            'name': element.data().values.elementAt(i)['name'],
            'date': element.id,
            'time': element.data().values.elementAt(i)['time'],
          }));
        }
      } else {}
    });

    if (overviewMap.isNotEmpty) {
      overviewMap.forEach((key, value) {
        tasksList.add(Task.fromMap(value));
      });

      returnMap['barChartData'] = tasksList;
    } else {
      returnMap['barChartData'] = [
        Task(name: 'No Data', time: 1),
      ];
    }
    if (splineList.isNotEmpty) {
      //splineChartData.add(getDaysInBeteween(dateRange));
      namesList.forEach((name) {
        splineChartData
            .add(splineList.where((item) => item.name == name).toList());
      });
      returnMap['splineChartData'] =
          fillListsWithDays(splineChartData, dateRange);
    } else {
      returnMap['splineChartData'] = splineChartData;
    }
    return returnMap;
  }
}
