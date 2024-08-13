import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  final CollectionReference userCollection = FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection = FirebaseFirestore.instance.collection("groups");
  final CollectionReference postCollection = FirebaseFirestore.instance.collection("posts");

  //계정생성 시 생성되는 데이터베이스
  Future<void> savingUserData(String fullName) async {
    if (uid == null) {
      throw Exception("User ID is null. Cannot save user data.");
    }

    return await userCollection.doc(uid).set({
      "fullName": fullName,
      "rivals": [],
      "uid": uid,
    });
  }

  Future<void> addRival(String name, String friendUID) async {
    DocumentSnapshot userDoc = await userCollection.doc(uid).get();
    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      List<dynamic> rivals = userData['rivals'] ?? [];

      if (rivals.length < 15) {
        await userCollection.doc(uid).update({
          "rivals": FieldValue.arrayUnion([
            {"name": name, "uid": friendUID}
          ])
        });
      } else {
        Fluttertoast.showToast(
          msg: "라이벌 추가는 15명까지 가능합니다.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }

  Future<void> deleteRival(String name, String friendUID) async {
    return await userCollection.doc(uid).update({
      "rivals": FieldValue.arrayRemove([
        {"name": name, "uid": friendUID}
      ])
    });
  }

  Future<List<dynamic>> getRivals() async {
    DocumentSnapshot snapshot = await userCollection.doc(uid).get();
    List<dynamic> rivals = snapshot['rivals'];
    return rivals;
  }

  Future<void> saveBestScoresToFirestore(String userId, List<dynamic> bestScores) async {
    var documentReference = FirebaseFirestore.instance.collection('users').doc(userId);
    await documentReference.set(
      {
        'playDataPath': bestScores,
      },
    );
  }

  Future<String> getAdminText() async {
    final firestore = FirebaseFirestore.instance;
    final docRef = firestore.collection('admin').doc('adminAnnounce');

    final docSnapshot = await docRef.get();
    if (docSnapshot.exists && docSnapshot.data() != null) {
      String adminText = docSnapshot.data()!['announce'];
      return adminText;
    }
    return '';
  }

  Future<QuerySnapshot> gettingUserData() async {
    return await userCollection.where("uid", isEqualTo: this.uid).get();
  }

  Future<Map<String, List<dynamic>>> fetchRivalsData(String userId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.data() == null) {
      return {};
    }

    List<dynamic> rivals = (userDoc.data() as Map<String, dynamic>)['rivals'] ?? [];
    Map<String, List<dynamic>> rivalsData = {};

    for (var rival in rivals) {
      if (rival is! Map || !rival.containsKey('uid') || !rival.containsKey('name')) {
        continue;
      }

      String rivalUid = rival['uid'];
      String customName = rival['name'];
      DocumentSnapshot rivalDoc = await FirebaseFirestore.instance.collection('users').doc(rivalUid).get();
      if (rivalDoc.data() == null) {
        continue;
      }

      List<dynamic> bestScores = (rivalDoc.data() as Map<String, dynamic>)['bestScores'] ?? [];
      rivalsData[customName] = bestScores;
    }

    return rivalsData;
  }
}
