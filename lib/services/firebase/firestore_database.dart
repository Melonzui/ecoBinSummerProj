import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  final CollectionReference userCollection = FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection = FirebaseFirestore.instance.collection("groups");
  final CollectionReference postCollection = FirebaseFirestore.instance.collection("posts");

  // 계정 생성 시 데이터베이스에 저장
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

  Future<void> updateUserPoints(int points) async {
    if (uid == null) {
      throw Exception("User ID is null. Cannot update points.");
    }

    try {
      DocumentSnapshot snapshot = await userCollection.doc(uid).get();
      if (snapshot.exists && snapshot.data() != null) {
        var data = snapshot.data() as Map<String, dynamic>;
        int currentPoints = data['environPoint'] ?? 0;
        await userCollection.doc(uid).update({
          'environPoint': currentPoints + points,
        });
      } else {
        // 처음으로 포인트를 추가할 때
        await userCollection.doc(uid).set({
          'environPoint': points,
        });
      }
    } catch (e) {
      print('Error updating points: $e');
      throw Exception("Failed to update user points");
    }
  }

  Future<int> getPoint() async {
    if (uid == null) {
      throw Exception("User ID is null. Cannot get points.");
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User is not authenticated.");
    }

    try {
      DocumentSnapshot snapshot = await userCollection.doc(user.uid).get();
      if (snapshot.exists && snapshot.data() != null) {
        var data = snapshot.data() as Map<String, dynamic>;
        var userEnvironPoint = data['environPoint'] ?? 0;
        return userEnvironPoint;
      } else {
        // 문서가 존재하지 않는 경우 0 포인트 반환
        print("Document does not exist for uid: ${user.uid}");
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
    final docRef = firestore.collection('admin').doc('adminText');

    final docSnapshot = await docRef.get();
    if (docSnapshot.exists && docSnapshot.data() != null) {
      String adminText = docSnapshot.data()!['adminText'];
      return adminText;
    }
    return '';
  }

  Future<QuerySnapshot> gettingUserData() async {
    return await userCollection.where("uid", isEqualTo: this.uid).get();
  }
}
