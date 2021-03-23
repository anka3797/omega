class Task {
  final String name;
  final int time;
  final String timeUI;
  final String date;

  Task({this.name, this.time, this.timeUI, this.date});
  Task.fromMap(Map<String, dynamic> map)
      : name = map['name'],
        time = map['time'],
        timeUI = map['time'] == null ? null : minutesToHours(map['time']),
        date = map['date'];

  static String minutesToHours(int _minutes) {
    if (_minutes < 60) {
      return (_minutes.toString() + ' min');
    } else {
      String kk = ((_minutes ~/ 60).toString() +
          ':' +
          (_minutes % 60).toString() +
          ' h');
      return kk;
    }
  }
}
