import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ecobinproj/model/model_quiz.dart';
import 'package:ecobinproj/page/quiz/screen_result.dart';
import 'package:ecobinproj/widgets/widget_candidate.dart';

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
            height: height * 0.7, // 높이를 0.7로 변경하여 버튼 포함
            child: PageView.builder(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(), // 유저 스크롤 방지
              itemCount: widget.quizs.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                  _answerState = [false, false, false, false];
                });
              },
              itemBuilder: (context, index) {
                return _buildQuizCard(widget.quizs[index], width, height);
              },
            ),
          ),
        ),
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
              style: ElevatedButton.styleFrom(
                minimumSize: Size(width * 0.5, height * 0.05), // 버튼 크기 조정
                backgroundColor: Colors.deepPurple, // 버튼의 배경색
                foregroundColor: Colors.white, // 버튼의 텍스트 색상
              ),
              onPressed: _answers[_currentIndex] == -1
                  ? null
                  : () {
                      if (_currentIndex == widget.quizs.length - 1) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ResultScreen(answers: _answers, quizs: widget.quizs)));
                        // 결과 보기로 이동하는 로직 추가
                      } else {
                        setState(() {
                          _answerState = [false, false, false, false];
                          _currentIndex += 1;
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
              : 'No Option', // 기본값 제공
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
