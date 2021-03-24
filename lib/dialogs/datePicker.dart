import 'package:flutter/material.dart';
import 'package:omega/style/theme.dart' as Style;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class DatePickerDialog extends StatefulWidget {
  const DatePickerDialog({Key key}) : super(key: key);
  @override
  _DatePickerDialogState createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<DatePickerDialog> {
  DateRangePickerSelectionChangedArgs args =
      DateRangePickerSelectionChangedArgs(DateTime.now());
  Map<String, String> rangeMap = {};
  bool isLoading = false;
  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is PickerDateRange) {
        rangeMap['start'] =
            DateFormat('yyyy-MM-dd').format(args.value.startDate).toString();
        rangeMap['end'] = DateFormat('yyyy-MM-dd')
            .format(args.value.endDate ?? args.value.startDate)
            .toString();
        //print(rangeMap);
      } else if (args.value is DateTime) {
        return args.value;
      } else if (args.value is List<DateTime>) {
        return args.value.length.toString();
      } else {
        return args.value.length.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.antiAlias,
      backgroundColor: Style.Colors.secondColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SfDateRangePicker(
              onSelectionChanged: _onSelectionChanged,
              selectionMode: DateRangePickerSelectionMode.range,
              initialSelectedRange: PickerDateRange(
                DateTime.now(),
                DateTime.now(),
              ),
              headerStyle: DateRangePickerHeaderStyle(
                textStyle: GoogleFonts.sourceSansPro(
                    textStyle: TextStyle(color: Style.Colors.titleColor),
                    fontSize: 25,
                    fontWeight: FontWeight.w600),
              ),
              monthCellStyle: DateRangePickerMonthCellStyle(
                textStyle: GoogleFonts.sourceSansPro(
                    textStyle: TextStyle(color: Style.Colors.textColor),
                    fontWeight: FontWeight.w600),
                todayTextStyle: GoogleFonts.sourceSansPro(
                    textStyle: TextStyle(color: Color(0xff6ecdb7)),
                    fontWeight: FontWeight.w600),
              ),
              rangeTextStyle: GoogleFonts.sourceSansPro(
                  textStyle: TextStyle(color: Style.Colors.textColor),
                  fontWeight: FontWeight.w600),
              selectionTextStyle: GoogleFonts.sourceSansPro(
                  textStyle: TextStyle(color: Style.Colors.titleColor),
                  fontWeight: FontWeight.w600),
              selectionColor: Style.Colors.mainColor,
              rangeSelectionColor: Color(0xff6ecdb7).withOpacity(0.3),
              startRangeSelectionColor: Color(0xff6ecdb7),
              endRangeSelectionColor: Color(0xff6ecdb7),
              todayHighlightColor: Color(0xff6ecdb7),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 10, bottom: 10),
                child: ElevatedButton(
                  onPressed: () {
                    //print(rangeMap);
                    rangeMap.isEmpty
                        ? DoNothingAction()
                        : setState(() {
                            isLoading = true;
                            Navigator.pop(context, rangeMap);
                          });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: rangeMap.isEmpty
                        ? Style.Colors.textColor
                        : Color(0xff6ecdb7),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Style.Colors.titleColor))
                      : Text(
                          "Done",
                          style: GoogleFonts.sourceSansPro(
                              textStyle:
                                  TextStyle(color: Style.Colors.titleColor),
                              fontSize: 17,
                              fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
