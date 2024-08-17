import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ecobinproj/model/model_quiz.dart';
import 'package:ecobinproj/model/api_adapter.dart';

import 'package:ecobinproj/page/quiz/screen_quiz.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuizPage extends StatefulWidget {
  @override
  _QuizPage createState() => _QuizPage();
}

class _QuizPage extends State<QuizPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Quiz> quizs = [];
  bool isLoading = false;

  _fetchQuizs() async {
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
      throw Exception('failed to load data');
    }
  }

  //테스트용 퀴즈 데이터
  // List<Quiz> quizs = [
  //   Quiz.fromMap({
  //     'title': 'test',
  //     'candidates': ['a', 'b', 'c', 'd'],
  //     'answer': 0
  //   }),
  //   Quiz.fromMap({
  //     'title': 'test2',
  //     'candidates': ['a', 'b', 'c', 'd'],
  //     'answer': 1
  //   }),
  //   Quiz.fromMap({
  //     'title': 'test3',
  //     'candidates': ['a', 'b', 'c', 'd'],
  //     'answer': 2
  //   }),
  // ];

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('My Quiz App'),
          backgroundColor: Colors.deepPurple,
          leading: Container(),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            /*Center(
              child: Image.asset(
                'images/quiz.png',
                width: width * 0.8,
              ),
            ),*/
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
            Text(
              '퀴즈 풀기 전 안내사항 \n 꼼꼼히 읽으세요.',
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: EdgeInsets.all(width * 0.048),
            ),
            _buildStep(width, '1. 랜덤으로 나오는 퀴즈를 풀어라'),
            _buildStep(width, '2. 아아아아아'),
            _buildStep(width, '3. 가나다라'),
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
                  child: Text(
                    '지금 퀴즈 풀기',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    // _scaffoldKey.currentState.showSnackBar(SnackBar(
                    //   content: Row(
                    //     children: <Widget>[
                    //       CircularProgressIndicator(),
                    //       Padding(padding: EdgeInsets.only(left: width*0.036),
                    //       ),
                    //       Text('로딩 중...'),
                    //     ],
                    //   ),
                    //   ),
                    //   );
                    _fetchQuizs().whenComplete(() {
                      return Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizScreen(
                            quizs: quizs,
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
              style: TextStyle(fontSize: width * 0.024), // 텍스트 크기 조정
            ),
          ),
        ],
      ),
    );
  }
}
