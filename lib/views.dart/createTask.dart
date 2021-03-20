import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omega/services/firebaseServices.dart';
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
  TextEditingController descriptionController = TextEditingController();
  int _minutes = 15;
  FirebaseServices firebaseServices = FirebaseServices();

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

  Widget timeSwiper() {
    return Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackShape: RectangularSliderTrackShape(),
          trackHeight: 3.0,
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 11.0),
        ),
        child: Expanded(
          child: Slider(
            value: _minutes.toDouble(),
            min: 0,
            max: 55,
            divisions: 11,
            activeColor: Colors.grey,
            label: _minutes.toString(),
            onChanged: (double values) {
              setState(() {
                _minutes = values.round();
              });
            },
          ),
        ),
      ),
      Text(
        "$_minutes min",
        style: GoogleFonts.sourceSansPro(
            textStyle: TextStyle(color: Colors.grey),
            fontWeight: FontWeight.w600),
      ),
    ]);
  }

  Widget descriptionField() {
    return TextField(
      controller: descriptionController,
      onChanged: (text) {
        setState(() {});
      },
      style: GoogleFonts.sourceSansPro(
          textStyle: TextStyle(color: Colors.grey),
          fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: "Describe your activity",
        hintStyle: GoogleFonts.sourceSansPro(
            textStyle: TextStyle(color: Colors.grey),
            fontWeight: FontWeight.w500),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1.0, color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 2.0, color: Colors.grey),
        ),
      ),
    );
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
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
                SizedBox(height: 20),
                Text(
                  "Time",
                  style: GoogleFonts.sourceSansPro(
                      textStyle: TextStyle(color: Colors.grey),
                      fontSize: 20,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 30),
                timeSwiper(),
                SizedBox(height: 20),
                Text(
                  "Description",
                  style: GoogleFonts.sourceSansPro(
                      textStyle: TextStyle(color: Colors.grey),
                      fontSize: 20,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 30),
                descriptionField(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
