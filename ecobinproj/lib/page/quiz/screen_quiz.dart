import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ecobinproj/model/model_quiz.dart';
import 'package:ecobinproj/page/quiz/screen_result.dart';
import 'package:ecobinproj/widgets/widget_candidate.dart';
import 'package:ecobinproj/page/home_page.dart';
import 'package:ecobinproj/model/model_quiz.dart';

class QuizScreen extends StatefulWidget {
  final List<Quiz> quizs;
  QuizScreen({required this.quizs});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  PageController _pageController = PageController();
  List<int> _answers = [-1, -1, -1];
  List<bool> _answerState = [false, false, false, false];
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screensize = MediaQuery.of(context).size;
    double width = screensize.width;
    double height = screensize.height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.deepPurple,
        body: Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.deepPurple),
            ),
            width: width * 0.85,
            height: height * 0.7,
            child: PageView.builder(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(), // 유저 스크롤 방지
              itemCount: widget.quizs.length + 1, // 결과 페이지 포함
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                  if (_currentIndex < widget.quizs.length) {
                    _answerState = [false, false, false, false]; // 퀴즈 상태 초기화
                  }
                });
              },
              itemBuilder: (context, index) {
                if (index == widget.quizs.length) {
                  return _buildResultScreen(width, height); // 결과 화면
                } else {
                  return _buildQuizCard(widget.quizs[index], width, height); // 퀴즈 화면
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen(double width, double height) {
    int score = 0;
    for (int i = 0; i < widget.quizs.length; i++) {
      if (widget.quizs[i].answer == _answers[i]) {
        score += 1;
      }
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: width * 0.1, bottom: width * 0.05),
            child: Text(
              '수고하셨습니다!',
              style: TextStyle(
                fontSize: width * 0.06,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            '당신의 점수는 $score / ${widget.quizs.length}',
            style: TextStyle(
              fontSize: width * 0.048,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(width * 0.024),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                      (route) => false, // 모든 이전 경로를 제거하고 홈 화면으로 이동
                );
              },
              child: Text('홈으로 돌아가기'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(Quiz quiz, double width, double height) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(0, width * 0.024, 0, width * 0.024),
            child: Text(
              'Q' + (_currentIndex + 1).toString() + '.',
              style: TextStyle(
                fontSize: width * 0.06,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: width * 0.8,
            padding: EdgeInsets.only(top: width * 0.012),
            child: AutoSizeText(
              quiz.title!,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: width * 0.048,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Container(),
          ),
          Column(
            children: _buildCandidates(width, quiz),
          ),
          Container(
            padding: EdgeInsets.all(width * 0.024),
            child: ElevatedButton(
              child: _currentIndex == widget.quizs.length - 1 ? Text('결과보기') : Text('다음 문제'),
              onPressed: _answers[_currentIndex] == -1
                  ? null
                  : () {
                if (_currentIndex == widget.quizs.length - 1) {
                  // 결과 페이지로 이동
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  // 다음 문제로 넘어가는 로직
                  setState(() {
                    _answerState = [false, false, false, false]; // 선택 초기화
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  });
                }
              },
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _buildCandidates(double width, Quiz quiz) {
    List<Widget> _children = [];
    for (int i = 0; i < 4; i++) {
      _children.add(
        CandWidget(
          index: i,
          text: quiz.candidates != null && quiz.candidates!.isNotEmpty
              ? quiz.candidates![i]
              : 'No Option',
          width: width,
          answerState: _answerState[i],
          tap: () {
            setState(() {
              for (int j = 0; j < 4; j++) {
                if (j == i) {
                  _answerState[j] = true;
                  _answers[_currentIndex] = j;
                } else {
                  _answerState[j] = false;
                }
              }
            });
          },
        ),
      );
      _children.add(
        Padding(
          padding: EdgeInsets.all(width * 0.024),
        ),
      );
    }
    return _children;
  }
}
