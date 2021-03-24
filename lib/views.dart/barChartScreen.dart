import 'package:flutter/material.dart';
import 'package:omega/dialogs/datePicker.dart';
import 'package:omega/functions.dart';
import 'package:omega/models/project.dart';
import 'package:omega/models/task.dart';
import 'package:omega/style/theme.dart' as Style;
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:search_choices/search_choices.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';

class BarChartScreen extends StatefulWidget {
  final List<QueryDocumentSnapshot> documentsList;
  final List<Project> projectList;
  const BarChartScreen({Key key, this.documentsList, this.projectList})
      : super(key: key);
  @override
  _BarChartScreenState createState() => _BarChartScreenState();
}

class _BarChartScreenState extends State<BarChartScreen> {
  Map<String, String> dateRange = {};
  TooltipBehavior _tooltipBehavior;
  List<List<Task>> splineChartData = [];
  List<Task> chartData = [
    Task(name: 'No Data', time: 60),
  ];
  List<Project> projectList = [];
  List<DropdownMenuItem<String>> items = [];
  CalculationFunctions functions = CalculationFunctions();
  Project selectedProject = Project(id: '0', name: 'All Projects');

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
          xValueMapper: (Task data, _) => data.name,
          yValueMapper: (Task data, _) => data.time / 60,
          dataLabelMapper: (Task data, _) => data.timeUI,
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.inside,
            useSeriesColor: true,
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

  Widget projectSelector() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25.0),
        child: SearchChoices.single(
          items: items,
          value: selectedProject.name,
          padding: 0.0,
          hint: Text(
            "Project",
            style: GoogleFonts.sourceSansPro(
                textStyle:
                    TextStyle(color: Style.Colors.textColor, fontSize: 15),
                fontWeight: FontWeight.w500),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_outlined,
            color: Style.Colors.textColor,
          ),
          underline: Container(
            height: 1.0,
            color: Style.Colors.textColor,
          ),
          style: GoogleFonts.sourceSansPro(
              textStyle:
                  TextStyle(color: Style.Colors.titleColor, fontSize: 15),
              fontWeight: FontWeight.w500),
          searchHint: null,
          displayClearIcon: false,
          menuBackgroundColor: Style.Colors.secondColor,
          searchInputDecoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(width: 1.0, color: Style.Colors.textColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(width: 2.0, color: Style.Colors.styleColor),
            ),
          ),
          onChanged: (value) {
            setState(() {
              selectedProject =
                  projectList.firstWhere((element) => element.name == value);
            });
          },
          dialogBox: false,
          isExpanded: false,
          menuConstraints: BoxConstraints.tight(Size.fromHeight(350)),
        ),
      ),
    );
  }

  Widget splineChart() {
    return SfCartesianChart(
        margin: EdgeInsets.only(left: 20, right: 20, top: 20),
        zoomPanBehavior: ZoomPanBehavior(
          enablePinching: true,
          zoomMode: ZoomMode.xy,
          enablePanning: true,
        ),
        tooltipBehavior: TooltipBehavior(
            enable: true, activationMode: ActivationMode.singleTap),
        primaryXAxis: DateTimeAxis(enableAutoIntervalOnZooming: false),
        series: splineChartSeries());
  }

  List<ChartSeries> splineChartSeries() {
    List<StackedColumnSeries<Task, DateTime>> seriesList = [];
    if (selectedProject.id == '0') {
      splineChartData.forEach((group) {
        seriesList.add(
          StackedColumnSeries<Task, DateTime>(
              isVisible: true,
              enableTooltip: true,
              dataSource: group,
              xValueMapper: (Task data, _) =>
                  DateFormat('yyyy-MM-dd').parse(data.date),
              yValueMapper: (Task data, _) =>
                  data.time != null ? data.time / 60 : data.time,
              dataLabelMapper: (Task data, _) => data.timeUI,
              name: group[0].name,
              dataLabelSettings: DataLabelSettings(isVisible: true),
              emptyPointSettings:
                  EmptyPointSettings(mode: EmptyPointMode.drop)),
        );
      });
    } else {
      int index = splineChartData
          .indexWhere((group) => group[0].projectId == selectedProject.id);
      if (index == -1) {
        print("No records");
      } else {
        seriesList.add(
          StackedColumnSeries<Task, DateTime>(
              isVisible: true,
              enableTooltip: true,
              dataSource: splineChartData[index],
              xValueMapper: (Task data, _) =>
                  DateFormat('yyyy-MM-dd').parse(data.date),
              yValueMapper: (Task data, _) =>
                  data.time != null ? data.time / 60 : data.time,
              dataLabelMapper: (Task data, _) => data.timeUI,
              name: splineChartData[index][0].name,
              dataLabelSettings: DataLabelSettings(isVisible: true),
              emptyPointSettings:
                  EmptyPointSettings(mode: EmptyPointMode.drop)),
        );
      }
    }

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
      Task(name: 'No Data', time: 60),
    ];

    functions.prepareChartData(widget.documentsList, dateRange).then((map) {
      splineChartData = map['splineChartData'];
      chartData = map['barChartData'];
      setState(() {});
    });
  }

  void initDropDown() {
    Project allProjects = Project(id: '0', name: 'All Projects');
    projectList = List.from(widget.projectList);
    projectList.insert(0, allProjects);
    for (int i = 0; i < widget.projectList.length; i++) {
      items.add(
        DropdownMenuItem(
          child: Text(
            projectList[i].name,
            style: GoogleFonts.sourceSansPro(
                textStyle: TextStyle(color: Style.Colors.titleColor),
                fontWeight: FontWeight.w500),
          ),
          value: projectList[i].name,
        ),
      );
    }
  }

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    initTimeSheet();
    initDropDown();
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
                if (date == null) {
                  print("null");
                } else {
                  dateRange = date;
                  splineChartData.clear();
                  chartData = [
                    Task(name: 'No Data', time: 60),
                  ];
                  functions
                      .prepareChartData(widget.documentsList, dateRange)
                      .then((map) {
                    splineChartData = map['splineChartData'];
                    chartData = map['barChartData'];
                    setState(() {});
                  });
                }
              });
            },
            icon: Icon(Icons.date_range_rounded),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              selectDateWidget(),
              tasksChart(),
              progressBar(),
              projectSelector(),
              splineChart(),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
