import 'package:flutter/material.dart';
import 'package:ecobinproj/model/model_quiz.dart';
import 'package:ecobinproj/model/api_adapter.dart';
import 'package:ecobinproj/page/quiz/screen_quiz.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ecobinproj/page/home_page.dart';
import 'package:ecobinproj/model/model_quiz.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Quiz> quizs = [];
  bool isLoading = false;

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
                    '지금 퀴즈 풀f기',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    await _fetchQuizs().whenComplete(() {
                      final homePageState = context.findAncestorStateOfType<HomePage1>();
                      if (homePageState != null) {
                        homePageState.setState(() {
                          homePageState.selectedQuizs = quizs; // 퀴즈 데이터를 설정
                          homePageState.onItemTapped(3); // "퀴즈" 페이지로 이동하는 인덱스
                        });
                      }
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
