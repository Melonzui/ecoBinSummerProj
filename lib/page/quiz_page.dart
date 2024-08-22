import 'package:flutter/material.dart';
import 'package:ecobinproj/model/model_quiz.dart';
import 'package:ecobinproj/model/api_adapter.dart';
import 'package:ecobinproj/page/quiz/screen_quiz.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ecobinproj/page/home_page.dart';
import 'package:ecobinproj/services/firebase/firestore_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Quiz> quizs = [];
  bool isLoading = false;
  int correctAnswers = 0;

  Future<void> _fetchQuizs() async {
    setState(() {
      isLoading = true;
    });
    final response = await http.get(Uri.parse('https://bin-quiz-test-0334c6d3a64e.herokuapp.com/quiz/3/'));
    if (response.statusCode == 200) {
      setState(() {
        quizs = parseQuizs(utf8.decode(response.bodyBytes));
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load quiz data');
    }
  }

  Future<void> _updateUserPoints(int points) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final databaseService = DatabaseService(uid: user.uid);
      await databaseService.updateUserPoints(points);
    }
  }

  void _onQuizCompleted(int correctAnswers) async {
    // 정답 맞춘 수에 따라 포인트 업데이트
    int earnedPoints = correctAnswers * 100;
    await _updateUserPoints(earnedPoints);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$earnedPoints 포인트를 획득했습니다!')),
    );

    Navigator.pop(context); // 퀴즈 완료 후 페이지를 닫습니다.
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('My Quiz App'),
          backgroundColor: Colors.deepPurple,
          leading: Container(), // 뒤로가기 버튼 숨김
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(width * 0.024),
            ),
            Text(
              '플러터 퀴즈 앱',
              style: TextStyle(
                fontSize: width * 0.025,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              '퀴즈 풀기 전 안내사항 \n 꼼꼼히 읽으세요.',
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: EdgeInsets.all(width * 0.048),
            ),
            _buildStep(width, '1. 랜덤으로 나오는 퀴즈를 풀어라'),
            _buildStep(width, '2. 시간을 신경 써서 문제를 풀어라'),
            _buildStep(width, '3. 정답을 맞춰라'),
            Padding(
              padding: EdgeInsets.all(width * 0.048),
            ),
            Container(
              padding: EdgeInsets.only(bottom: width * 0.036),
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(width * 0.8, height * 0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.deepPurple, // 버튼의 배경색
                  ),
                  child: const Text(
                    '지금 퀴즈 풀기',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    await _fetchQuizs().whenComplete(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScreenQuiz(
                            quizs: quizs,
                            onQuizCompleted: _onQuizCompleted,
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(double width, String title) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        width * 0.048,
        width * 0.024,
        width * 0.048,
        width * 0.024,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.check_box,
            size: width * 0.04,
          ),
          Padding(
            padding: EdgeInsets.only(right: width * 0.024),
          ),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: width * 0.024),
            ),
          ),
        ],
      ),
    );
  }
}
