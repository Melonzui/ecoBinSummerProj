import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ecobinproj/page/quiz_page.dart';
import 'package:ecobinproj/model/model_quiz.dart';

class ResultScreen extends StatelessWidget {
  final List<int> answers;
  final List<Quiz> quizs;

  ResultScreen({required this.answers, required this.quizs});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;

    int score = 0;
    for (int i = 0; i < quizs.length; i++) {
      if (quizs[i].answer == answers[i]) {
        score += 1;
      }
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Quiz App'),
          backgroundColor: Colors.deepPurple,
          leading: Container(),
        ),
        body: Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.deepPurple),
              color: Colors.deepPurple,
            ),
            width: width * 0.85,
            height: height * 0.5,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: width * 0.048),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.deepPurple),
                    color: Colors.white,
                  ),
                  width: width * 0.75,
                  height: height * 0.35,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, width * 0.048, 0, width * 0.012),
                        child: Text(
                          '수고하셨습니다',
                          style: TextStyle(
                            fontSize: width * 0.055,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '당신의 점수는',
                        style: TextStyle(
                          fontSize: width * 0.048,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Spacer를 사용하여 원하는 크기만큼의 공간 추가
                      SizedBox(height: width * 0.02),
                      Text(
                        '$score / ${quizs.length}',
                        style: TextStyle(
                          fontSize: width * 0.082,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: width * 0.012),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: width * 0.048),
                  child: SizedBox(
                    width: width * 0.73,
                    height: height * 0.05,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return QuizPage();
                        }));
                      },
                      child: Text('홈으로 돌아가기'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
