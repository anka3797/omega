import 'package:flutter/material.dart';
import 'package:omega/models/project.dart';
import 'package:omega/services/firebaseServices.dart';
import 'package:omega/style/theme.dart' as Style;
import 'package:google_fonts/google_fonts.dart';
import 'package:search_choices/search_choices.dart';

class CreateTaskDialog extends StatefulWidget {
  final List<Project> projectList;
  final String date;

  const CreateTaskDialog({Key key, this.projectList, this.date})
      : super(key: key);
  @override
  _CreateTaskDialogState createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<CreateTaskDialog> {
  String selectedProject;
  List<DropdownMenuItem<String>> items = [];
  TextEditingController descriptionController = TextEditingController();
  int _minutes = 15;
  List<int> colors = [
    0xffe24930,
    0xffe78239,
    0xfff2c84a,
    0xff6ecdb7,
    0xff5cacf0,
    0xff6366f3,
  ];
  int selectedColor = 0xff6ecdb7;
  FirebaseServices firebaseServices = FirebaseServices();

  Widget projectSelector() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: SearchChoices.single(
        items: items,
        value: selectedProject,
        hint: Text(
          "Project",
          style: GoogleFonts.sourceSansPro(
              textStyle: TextStyle(color: Style.Colors.textColor, fontSize: 25),
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
            textStyle: TextStyle(color: Style.Colors.titleColor, fontSize: 25),
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
            borderSide: BorderSide(width: 2.0, color: Style.Colors.styleColor),
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
      ),
    );
  }

  Widget timeSwiper() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
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
              max: 480,
              divisions: 32,
              activeColor: Style.Colors.textColor,
              inactiveColor: Color(0xff313033),
              label: minutesToHours(),
              onChanged: (double values) {
                setState(() {
                  _minutes = values.round();
                });
              },
            ),
          ),
        ),
        Text(
          _minutes ~/ 60 != 0
              ? "${minutesToHours()} hrs"
              : "${minutesToHours()} min",
          style: GoogleFonts.sourceSansPro(
              textStyle: TextStyle(color: Colors.grey),
              fontWeight: FontWeight.w600),
        ),
      ]),
    );
  }

  Widget colorSelector() {
    return Container(
      height: 25,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: colors.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: ClipOval(
                child: Material(
                  color: Color(colors[index]),
                  child: InkWell(
                    child: SizedBox(
                      width: 25,
                      height: 25,
                      child: colors[index] == selectedColor
                          ? Icon(
                              Icons.check,
                              color: Colors.black,
                              size: 20,
                            )
                          : Container(),
                    ),
                    onTap: () {
                      setState(() {
                        selectedColor = colors[index];
                      });
                    },
                  ),
                ),
              ),
            );
          }),
    );
  }

  Widget descriptionField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: descriptionController,
        onChanged: (text) {
          setState(() {});
        },
        style: GoogleFonts.sourceSansPro(
            textStyle: TextStyle(color: Style.Colors.textColor),
            fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: "Describe your activity",
          hintStyle: GoogleFonts.sourceSansPro(
              textStyle: TextStyle(color: Style.Colors.textColor),
              fontWeight: FontWeight.w500),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 1.0, color: Style.Colors.textColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 2.0, color: Style.Colors.styleColor),
          ),
        ),
      ),
    );
  }

  Widget bottomSection() {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          width: MediaQuery.of(context).size.width,
          color: Color(0xff313033),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Style.Colors.secondColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  ),
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.sourceSansPro(
                        textStyle: TextStyle(color: Style.Colors.textColor),
                        fontSize: 17,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    selectedProject == null ||
                            descriptionController.text == '' ||
                            _minutes == 0
                        ? DoNothingAction()
                        : firebaseServices
                            .registerTask(
                                selectedProject,
                                selectedColor.toString(),
                                _minutes,
                                widget.date,
                                descriptionController.text)
                            .then((msg) {
                            if (msg == 'success') {
                              Navigator.of(context).pop();
                            } else {
                              print(msg);
                            }
                          });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: selectedProject == null ||
                            descriptionController.text == '' ||
                            _minutes == 0
                        ? Style.Colors.textColor
                        : Style.Colors.styleColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  ),
                  child: Text(
                    "Create",
                    style: GoogleFonts.sourceSansPro(
                        textStyle: TextStyle(color: Style.Colors.titleColor),
                        fontSize: 17,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  String minutesToHours() {
    if (_minutes < 60) {
      return _minutes.toString();
    } else {
      String kk =
          ((_minutes ~/ 60).toString() + ':' + (_minutes % 60).toString());
      return kk;
    }
  }

  @override
  void initState() {
    for (int i = 0; i < widget.projectList.length; i++) {
      items.add(
        DropdownMenuItem(
          child: Text(
            widget.projectList[i].name,
            style: GoogleFonts.sourceSansPro(
                textStyle: TextStyle(color: Style.Colors.titleColor),
                fontWeight: FontWeight.w500),
          ),
          value: widget.projectList[i].name,
        ),
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.antiAlias,
      backgroundColor: Style.Colors.secondColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
                child: Text(
                  "Register a Task",
                  style: GoogleFonts.sourceSansPro(
                      textStyle: TextStyle(color: Style.Colors.titleColor),
                      fontSize: 30,
                      fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(height: 30),
              projectSelector(),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Color",
                      style: GoogleFonts.sourceSansPro(
                          textStyle: TextStyle(color: Style.Colors.textColor),
                          fontSize: 17,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(width: 15),
                    Expanded(child: colorSelector()),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: Text(
                  "Time",
                  style: GoogleFonts.sourceSansPro(
                      textStyle: TextStyle(color: Style.Colors.textColor),
                      fontSize: 17,
                      fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(height: 10),
              timeSwiper(),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: Text(
                  "Description",
                  style: GoogleFonts.sourceSansPro(
                      textStyle: TextStyle(color: Style.Colors.textColor),
                      fontSize: 17,
                      fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(height: 10),
              descriptionField(),
              SizedBox(height: 30),
              bottomSection(),
            ],
          ),
        ),
      ),
    );
  }
}
