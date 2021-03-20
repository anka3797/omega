import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseServices {
  Future getProjects() async {
    QuerySnapshot simulations;
    simulations = await FirebaseFirestore.instance.collection("projects").get();
    return simulations.docs;
  }
}
