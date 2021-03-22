import 'package:flutter/material.dart';
import 'package:omega/dialogs/datePicker.dart';
import 'package:omega/models/task.dart';
import 'package:omega/style/theme.dart' as Style;
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class BarChartScreen extends StatefulWidget {
  @override
  _BarChartScreenState createState() => _BarChartScreenState();
}

class _BarChartScreenState extends State<BarChartScreen> {
  Map<String, String> dateRange = {};
  ZoomPanBehavior _zoomPanBehavior;

  List<List<Task>> data = [
    [
      Task(date: "2021", time: 120, color: Colors.red, name: "Customer 1"),
      Task(date: "2020", time: 160, color: Colors.red, name: "Customer 1"),
    ],
    [
      Task(date: "2021", time: 80, color: Colors.blue, name: "Customer 2"),
      Task(date: "2020", time: 20, color: Colors.teal, name: "Customer 2"),
    ],
    [
      Task(date: "2021", time: 40, color: Colors.orange, name: "Customer 3"),
    ],
    [
      Task(date: "2022", time: 40, color: Colors.orange, name: "Customer 3"),
    ],
    [
      Task(date: "2024", time: 40, color: Colors.orange, name: "Customer 3"),
    ],
    [
      Task(date: "2026", time: 80, color: Colors.blue, name: "Customer 2"),
      Task(date: "2026", time: 20, color: Colors.teal, name: "Customer 2"),
    ],
    [
      Task(date: "2027", time: 40, color: Colors.orange, name: "Customer 3"),
    ],
    [
      Task(date: "2028", time: 40, color: Colors.orange, name: "Customer 3"),
    ],
    [
      Task(date: "2029", time: 40, color: Colors.orange, name: "Customer 3"),
    ],
  ];

  Widget selectDateWidget() {
    return Container(
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

  List keksas() {
    List<ChartSeries<Task, String>> list = [];
    for (int i = 0; i < data.length; i++) {
      list.add(StackedColumnSeries<Task, String>(
        dataSource: data[i],
        xValueMapper: (Task sales, _) => sales.date,
        yValueMapper: (Task sales, _) => sales.time,
        pointColorMapper: (Task sales, _) => sales.color,
        name: data[i][0].name,
        groupName: data[i][0].name,
        // Enable data label
        dataLabelSettings: DataLabelSettings(isVisible: true),
      ));
    }

    return list;
  }

  Widget tasksChart() {
    return SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        // Chart title
        title: ChartTitle(text: 'Half yearly sales analysis'),
        // Enable legend
        legend: Legend(isVisible: true),
        // Enable tooltip
        tooltipBehavior: TooltipBehavior(enable: true),
        zoomPanBehavior: _zoomPanBehavior,
        series: keksas());
  }

  @override
  void initState() {
    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      zoomMode: ZoomMode.xy,
      enablePanning: true,
    );
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
                });
              });
            },
            icon: Icon(Icons.date_range_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[selectDateWidget(), tasksChart()],
        ),
      ),
    );
  }
}
