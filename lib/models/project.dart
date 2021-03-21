import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String id;
  final String name;

  Project({this.id, this.name});

  Project.fromSnapshot(QueryDocumentSnapshot snapshot)
      : id = snapshot["id"],
        name = snapshot["name"];
}
