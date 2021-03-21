import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omega/dialogs/createTask.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:omega/models/project.dart';
import 'package:omega/services/firebaseServices.dart';
import 'package:omega/style/theme.dart' as Style;

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  DatePickerController _controller = DatePickerController();
  int years = DateTime.now().year;
  List<QueryDocumentSnapshot> projects = [];
  FirebaseServices firebaseServices = FirebaseServices();
  List<Project> projectList = [];
  DateTime _selectedDate = DateTime.now();
  Stream tasksStream;
  String selectedDate;

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
              initialSelectedDate: _selectedDate,
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
              onDateChange: (date) {
                _selectedDate = date;
                selectedDate = DateTime(date.year, date.month, date.day)
                    .toString()
                    .substring(0, 10);
                setState(() {});
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget tasksList() {
    return StreamBuilder(
        stream: tasksStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            //snp.indexWhere((id) => id == selectedDate);
            //print(Map.from(snapshot.data.docs[1].data()));
            /* var mp = snapshot.data.docs
                .asMap()
                .map((k, v) => MapEntry(k, v))
                .values
                .toList();*/
            List<QueryDocumentSnapshot> documentByDate = snapshot.data.docs
                .where((doc) => doc.id == selectedDate)
                .toList();
            print(documentByDate[0].data());
            return Expanded(
              child: ListView.builder(
                itemCount: documentByDate[0].data().entries.length,
                itemBuilder: (context, index) {
                  //return Text(documentByDate[0].data().values.elementAt(index));
                  return taskCard(
                      documentByDate[0].data().values.elementAt(index));
                },
              ),
            );
          } else {
            return Container();
          }
        });
  }

  Widget taskCard(Map<String, dynamic> task) {
    return Container(
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Color(int.parse(task['color'])).withOpacity(0.7),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              task['name'].toString(),
              style: GoogleFonts.sourceSansPro(
                  textStyle: TextStyle(color: Style.Colors.titleColor),
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            Text(
              task['description'].toString(),
              style: GoogleFonts.sourceSansPro(
                  textStyle: TextStyle(color: Style.Colors.textColor),
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            ),
            Container(
              margin: EdgeInsets.only(top: 25, bottom: 10),
              height: 5,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child: LinearProgressIndicator(
                  value: task['time'] / 480,
                  valueColor: new AlwaysStoppedAnimation<Color>(
                      Color(int.parse(task['color']))),
                  backgroundColor: Style.Colors.secondColor,
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Text(
                  task['time'].toString(),
                  style: GoogleFonts.sourceSansPro(
                      textStyle: TextStyle(color: Style.Colors.titleColor),
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(width: 5),
                Text(
                  "min",
                  style: GoogleFonts.sourceSansPro(
                    textStyle: TextStyle(
                        color: Style.Colors.textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  @override
  void initState() {
    tasksStream = FirebaseFirestore.instance
        .collection("users")
        .doc("7RpEK7p8otPduIqzP89H")
        .collection("dates")
        .snapshots();
    selectedDate =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)
            .toString()
            .substring(0, 10);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            String date = DateTime(
                    _selectedDate.year, _selectedDate.month, _selectedDate.day)
                .toString()
                .substring(0, 10);
            print(date);
            if (projectList.isEmpty) {
              firebaseServices.getProjects().then((list) {
                projectList = list;
                showDialog(
                    context: context,
                    builder: (_) {
                      return CreateTaskDialog(
                        projectList: list,
                        date: date,
                      );
                    });
              });
            } else {
              showDialog(
                  context: context,
                  builder: (_) {
                    return CreateTaskDialog(
                      projectList: projectList,
                      date: date,
                    );
                  });
            }
          },
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: <Widget>[
              datePickerWidget(),
              tasksList(),
            ],
          ),
        ));
  }
}
