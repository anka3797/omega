import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omega/dialogs/createTask.dart';
import 'package:omega/views.dart/createTask.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  DatePickerController _controller = DatePickerController();
  int years = DateTime.now().year;

  Widget datePickerWidget() {
    return Stack(
      children: <Widget>[
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 170,
              decoration:
                  BoxDecoration(color: Colors.grey[500].withOpacity(0.5)),
            ),
          ),
        ),
        Column(
          children: <Widget>[
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ClipOval(
                  child: Material(
                    color: Colors.grey,
                    child: InkWell(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: Icon(
                          Icons.remove,
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          years--;
                        });
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    years.toString(),
                    style: GoogleFonts.sourceSansPro(
                        textStyle: TextStyle(color: Colors.white),
                        fontSize: 25,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                ClipOval(
                  child: Material(
                    color: Colors.grey,
                    child: InkWell(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          years++;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            DatePicker(
              DateTime.utc(years),
              controller: _controller,
              initialSelectedDate: DateTime.now(),
              height: 90,
              selectionColor: Colors.white30,
              selectedTextColor: Colors.black,
              dateTextStyle: GoogleFonts.sourceSansPro(
                  textStyle: TextStyle(color: Colors.white, fontSize: 20),
                  fontWeight: FontWeight.w600),
              dayTextStyle: GoogleFonts.sourceSansPro(
                  textStyle: TextStyle(color: Colors.grey),
                  fontWeight: FontWeight.w600),
              monthTextStyle: GoogleFonts.sourceSansPro(
                  textStyle: TextStyle(color: Colors.grey),
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (_) {
                  return CreateTaskDialog();
                });
          },
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: <Widget>[
              datePickerWidget(),
            ],
          ),
        ));
  }
}
