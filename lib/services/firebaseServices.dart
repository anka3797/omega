import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:omega/models/project.dart';

class FirebaseServices {
  Future getProjects() async {
    List<Project> projectList = [];
    await FirebaseFirestore.instance
        .collection("projects")
        .get()
        .then((querySnapshot) {
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        projectList.add(Project.fromSnapshot(querySnapshot.docs[i]));
      }
    });
    return projectList;
  }

  Future registerTask(Project projectModel, String color, int time, String date,
      String description) async {
    bool exists = false;
    int index = 1;
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc("7RpEK7p8otPduIqzP89H")
          .collection("dates")
          .doc(date)
          .get()
          .then((onexist) {
        if (onexist.exists) {
          index = onexist.data().entries.length + 1;
          exists = true;
        } else {
          exists = false;
        }
      });
      if (exists) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc("7RpEK7p8otPduIqzP89H")
            .collection("dates")
            .doc(date)
            .update({
          "$index": {
            "name": projectModel.name,
            "projectId": projectModel.id,
            "time": time,
            "description": description,
            "color": color,
          }
        });
      } else {
        await FirebaseFirestore.instance
            .collection("users")
            .doc("7RpEK7p8otPduIqzP89H")
            .collection("dates")
            .doc(date)
            .set({
          "$index": {
            "name": projectModel.name,
            "projectId": projectModel.id,
            "time": time,
            "description": description,
            "color": color,
          }
        });
      }

      return 'success';
    } catch (e) {
      return e;
    }
  }
}
