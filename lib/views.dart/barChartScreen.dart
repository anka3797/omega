import 'package:flutter/material.dart';
import 'package:omega/dialogs/datePicker.dart';
import 'package:omega/models/task.dart';
import 'package:omega/style/theme.dart' as Style;
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';

class BarChartScreen extends StatefulWidget {
  final List<QueryDocumentSnapshot> documentsList;

  const BarChartScreen({Key key, this.documentsList}) : super(key: key);
  @override
  _BarChartScreenState createState() => _BarChartScreenState();
}

class _BarChartScreenState extends State<BarChartScreen> {
  Map<String, String> dateRange = {};
  TooltipBehavior _tooltipBehavior;
  List<QueryDocumentSnapshot> documentsList;

  Widget selectDateWidget() {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Style.Colors.secondColor,
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Center(
              child: dateRange == null || dateRange.isEmpty
                  ? Text("No Date Selected")
                  : Text(
                      "${dateRange['start']} / ${dateRange['end']}",
                      style: GoogleFonts.sourceSansPro(
                          textStyle: TextStyle(color: Style.Colors.titleColor),
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  List<Task> chartData = [
    Task(name: 'No Data', time: 1),
  ];

  Widget tasksChart() {
    return SfCircularChart(
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        textStyle: GoogleFonts.sourceSansPro(
            textStyle: TextStyle(color: Style.Colors.titleColor),
            fontWeight: FontWeight.w500),
      ),
      tooltipBehavior: _tooltipBehavior,
      series: <CircularSeries>[
        PieSeries<Task, String>(
          enableTooltip: true,
          enableSmartLabels: true,

          dataSource: chartData,
          // pointColorMapper: (Task data, _) => data.color,
          xValueMapper: (Task data, _) => data.name,
          yValueMapper: (Task data, _) => data.time,
          dataLabelMapper: (Task data, _) => data.timeUI,
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.inside,
          ),
          radius: '100%',
          explode: true,
        )
      ],
    );
  }

  Widget progressBar() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
        child: FutureBuilder(
          future: calculateTotalTime(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              print("Work days: ${getDifferenceWithoutWeekends()}");
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircularPercentIndicator(
                    radius: 60.0,
                    lineWidth: 10.0,
                    animation: true,
                    percent: snapshot.data[1] / getTotalWorkMinutes() > 1.0
                        ? 1.0
                        : snapshot.data[1] / getTotalWorkMinutes(),
                    center: new Text(
                      (snapshot.data[1] / getTotalWorkMinutes() * 100)
                              .toStringAsFixed(1) +
                          '%',
                      style: GoogleFonts.sourceSansPro(
                          textStyle: TextStyle(color: Style.Colors.titleColor),
                          fontSize: 10,
                          fontWeight: FontWeight.w600),
                    ),
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor: Color(0xff6ecdb7),
                    backgroundColor: Style.Colors.secondColor,
                  ),
                  SizedBox(width: 20),
                  Text(
                    snapshot.data[0],
                    style: GoogleFonts.sourceSansPro(
                        textStyle: TextStyle(color: Style.Colors.titleColor),
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  )
                ],
              );
            } else {
              return Container();
            }
          },
        ));
  }

  Future<List<dynamic>> calculateTotalTime() async {
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

  int getTotalWorkMinutes() {
    return getDifferenceWithoutWeekends() * 480;
  }

  int getDifferenceWithoutWeekends() {
    int nbDays = 0;
    DateTime currentDay = DateFormat('yyyy-MM-dd').parse(dateRange['start']);
    print(currentDay);
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

  Future<List<Task>> prepareChartData() {
    int startDate = int.parse(dateRange['start'].replaceAll(RegExp('-'), ''));
    int endDate = int.parse(dateRange['end'].replaceAll(RegExp('-'), ''));
    Map<String, Map<String, dynamic>> overviewMap = {};
    List<Task> tasksList = [];
    widget.documentsList.forEach((element) {
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
          };
        }

        //print(element.data().values);
        //print(element.id.replaceAll(RegExp('-'), ''));
      } else {}
    });
    if (overviewMap.isNotEmpty) {
      overviewMap.forEach((key, value) {
        tasksList.add(Task.fromMap(value));
      });
      setState(() {
        chartData = tasksList;
      });
      print(tasksList);
    } else {
      print("Is empty");
    }
  }

  /* void initTimeSheet() {
    DateTime dateTime = DateTime.now();
    dateRange['end'] = DateFormat('yyyy-MM-dd')
        .format(dateTime.subtract(Duration(days: dateTime.weekday - 1)))
        .toString();
    dateRange['start'] = DateFormat('yyyy-MM-dd')
        .format(dateTime
            .subtract(Duration(days: DateTime.daysPerWeek - dateTime.weekday)))
        .toString();
    prepareChartData();
    print(dateRange);
  }*/

  void initTimeSheet() {
    DateTime dateTime = DateTime.now();
    dateRange['end'] = DateFormat('yyyy-MM-dd')
        .format(dateTime.subtract(Duration(days: dateTime.weekday - 1)))
        .toString();
    dateRange['start'] = DateFormat('yyyy-MM-dd')
        .format(dateTime
            .subtract(Duration(days: DateTime.daysPerWeek - dateTime.weekday)))
        .toString();
    prepareChartData();
    print(dateRange);
  }

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    initTimeSheet();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.Colors.mainColor,
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Style.Colors.mainColor,
        centerTitle: true,
        elevation: 0.0,
        title: Text(
          "Review",
          style: GoogleFonts.sourceSansPro(
              textStyle: TextStyle(color: Style.Colors.titleColor),
              fontSize: 25,
              fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (_) {
                    return DatePickerDialog();
                  }).then((date) {
                setState(() {
                  dateRange = date;
                  prepareChartData();
                });
              });
            },
            icon: Icon(Icons.date_range_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            selectDateWidget(),
            tasksChart(),
            progressBar(),
          ],
        ),
      ),
    );
  }
}
