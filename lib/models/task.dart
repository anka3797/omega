class Task {
  final String name;
  final int time;
  final String timeUI;

  Task({this.name, this.time, this.timeUI});
  Task.fromMap(Map<String, dynamic> map)
      : name = map['name'],
        time = map['time'],
        timeUI = minutesToHours(map['time']);

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
