import 'package:flutter/material.dart';
import 'package:omega/dialogs/datePicker.dart';
import 'package:omega/style/theme.dart' as Style;
import 'package:google_fonts/google_fonts.dart';

class BarChartScreen extends StatefulWidget {
  @override
  _BarChartScreenState createState() => _BarChartScreenState();
}

class _BarChartScreenState extends State<BarChartScreen> {
  Map<String, String> dateRange = {};

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
          children: <Widget>[
            selectDateWidget(),
          ],
        ),
      ),
    );
  }
}
