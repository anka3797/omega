import 'package:flutter/material.dart';
import 'package:omega/dialogs/datePicker.dart';
import 'package:omega/functions.dart';
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
  List<List<Task>> splineChartData = [];
  List<Task> chartData = [
    Task(name: 'No Data', time: 1),
  ];
  CalculationFunctions functions = CalculationFunctions();

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
          future: functions.calculateTotalTime(chartData),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircularPercentIndicator(
                    radius: 60.0,
                    lineWidth: 10.0,
                    animation: true,
                    percent: snapshot.data[1] /
                                functions.getTotalWorkMinutes(dateRange) >
                            1.0
                        ? 1.0
                        : snapshot.data[1] /
                            functions.getTotalWorkMinutes(dateRange),
                    center: new Text(
                      (snapshot.data[1] /
                                  functions.getTotalWorkMinutes(dateRange) *
                                  100)
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

  Widget splineChart() {
    return SfCartesianChart(
        tooltipBehavior: TooltipBehavior(
            enable: true, activationMode: ActivationMode.longPress),
        /*trackballBehavior: TrackballBehavior(
            enable: true,
            activationMode: ActivationMode.singleTap,
            lineType: TrackballLineType.vertical,
            lineColor: Color(0xff6ecdb7)),*/
        primaryXAxis: CategoryAxis(),
        series: splineChartSeries());
  }

  List<ChartSeries> splineChartSeries() {
    List<StackedLineSeries<Task, String>> seriesList = [];
    splineChartData.forEach((group) {
      seriesList.add(
        StackedLineSeries<Task, String>(
            isVisible: true,
            markerSettings: MarkerSettings(isVisible: true),
            enableTooltip: true,
            dataSource: group,
            // Type of spline
            xValueMapper: (Task sales, _) => sales.date,
            yValueMapper: (Task sales, _) => sales.time,
            //dataLabelMapper: (Task data, _) => data.timeUI,
            name: group[0].name,
            emptyPointSettings: EmptyPointSettings(
                // Mode of empty point
                mode: EmptyPointMode.drop)),
      );
    });
    return seriesList;
  }

  void initTimeSheet() {
    DateTime dateTime = DateTime.now();
    dateRange['end'] = DateFormat('yyyy-MM-dd')
        .format(dateTime.subtract(Duration(days: dateTime.weekday - 1)))
        .toString();
    dateRange['start'] = DateFormat('yyyy-MM-dd')
        .format(dateTime
            .subtract(Duration(days: DateTime.daysPerWeek - dateTime.weekday)))
        .toString();
    splineChartData.clear();
    chartData = [
      Task(name: 'No Data', time: 1),
    ];

    functions.prepareChartData(widget.documentsList, dateRange).then((map) {
      splineChartData = map['splineChartData'];
      chartData = map['barChartData'];
      print(chartData);
      setState(() {});
    });
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
                  splineChartData.clear();
                  chartData = [
                    Task(name: 'No Data', time: 1),
                  ];
                  functions
                      .prepareChartData(widget.documentsList, dateRange)
                      .then((map) {
                    splineChartData = map['splineChartData'];
                    chartData = map['barChartData'];
                    print(chartData);
                    setState(() {});
                  });
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
            splineChart(),
          ],
        ),
      ),
    );
  }
}
