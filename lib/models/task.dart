import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final int color;
  final String description;
  final String name;
  final int time;

  Task({this.color, this.description, this.name, this.time});

  Task.fromSnapshot(QueryDocumentSnapshot snapshot)
      : id = snapshot["id"],
        name = snapshot["name"];
}
