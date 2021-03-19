import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:search_choices/search_choices.dart';

class CreateTask extends StatefulWidget {
  @override
  _CreateTaskState createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {
  String selectedProject;
  List<DropdownMenuItem<String>> items = [
    DropdownMenuItem(
      child: Text("one"),
    ),
    DropdownMenuItem(
      child: Text("two"),
    ),
  ];
  Widget projectSelector() {
    return SearchChoices.single(
      items: items,
      value: selectedProject,
      hint: Text(
        "Select one",
        style: GoogleFonts.sourceSansPro(
            textStyle: TextStyle(color: Colors.grey),
            fontWeight: FontWeight.w600),
      ),
      style: GoogleFonts.sourceSansPro(
          textStyle: TextStyle(color: Colors.grey),
          fontWeight: FontWeight.w600),
      searchHint: null,
      menuBackgroundColor: Color(0xff3A3A3A),
      searchInputDecoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1.0, color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 2.0, color: Colors.grey),
        ),
      ),
      onChanged: (value) {
        setState(() {
          selectedProject = value;
        });
      },
      dialogBox: false,
      isExpanded: true,
      menuConstraints: BoxConstraints.tight(Size.fromHeight(350)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Create task",
          style: GoogleFonts.sourceSansPro(
              textStyle: TextStyle(color: Colors.white),
              fontWeight: FontWeight.w600),
        ),
        brightness: Brightness.dark,
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Project",
                  style: GoogleFonts.sourceSansPro(
                      textStyle: TextStyle(color: Colors.grey),
                      fontSize: 20,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 30),
                projectSelector(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
