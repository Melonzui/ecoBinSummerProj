import 'package:ecobinproj/services/firebase/firestore_database.dart';
import 'package:flutter/material.dart';
import 'package:ecobinproj/model/model_quiz.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  DatabaseService firebaseDatabase = DatabaseService();
  String adminAnnounceText = "";
  @override
  void initState() {
    super.initState();
    loadAdminAnnounceText();
  }

  Future<void> loadAdminAnnounceText() async {
    try {
      String text = await firebaseDatabase.getAdminText();

      setState(() {
        adminAnnounceText = text;
      });
    } catch (e) {
      print('Failed to load admin text: $e');
      setState(() {
        adminAnnounceText = 'Error loading admin announcement.';
      });
    }
  }

  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              '테스트 홈화면',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            Card(
                color: const Color(0xFF111111),
                child: Column(children: [
                  const SizedBox(
                    height: 5,
                  ),
                  const Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "안내사항",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5),
                    color: const Color(0xFF333333),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            adminAnnounceText,
                            style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ])),
            SizedBox(height: 20),
            Text(
              '홈 화면 내용 추가하기',
              style: TextStyle(fontSize: 16),
            ),
            ElevatedButton(
              onPressed: null,
              child: Text('기능 버튼'),
            ),
          ],
        ),
      ),
    );
  }
}
