import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});
  final String currentUserUID = FirebaseAuth.instance.currentUser!.uid;
  final CollectionReference userCollection = FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection = FirebaseFirestore.instance.collection("groups");
  final CollectionReference postCollection = FirebaseFirestore.instance.collection("posts");

  //계정생성 시 생성되는 데이터베이스
  Future<void> savingUserData(String fullName) async {
    if (uid == null) {
      throw Exception("User ID is null. Cannot save user data.");
    }

    return await userCollection.doc(uid).set({
      "id": fullName,
      "uid": uid,
      "environPoint": 0,
    });
  }

  Future<int> getPoint() async {
    if (uid == null) {
      throw Exception("User ID is null. Cannot get points.");
    }

    try {
      DocumentSnapshot snapshot = await userCollection.doc(currentUserUID).get();
      if (snapshot.exists && snapshot.data() != null) {
        var data = snapshot.data() as Map<String, dynamic>;
        var userEnvironPoint = data['environPoint'] ?? 0;
        return userEnvironPoint;
      } else {
        // 문서가 존재하지 않는 경우 0 포인트 반환
        print("Document does not exist for uid: $uid");
        return 0;
      }
    } catch (e) {
      print('Error fetching points: $e');
      throw Exception("Failed to fetch user points");
    }
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
}
