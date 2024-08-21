import 'package:ecobinproj/model/model_quiz.dart'; // Quiz 모델을 사용하기 위한 import
import 'package:flutter/material.dart';
import 'package:ecobinproj/page/camera.dart';
import 'package:ecobinproj/page/home_screen.dart';
import 'package:ecobinproj/page/map_page.dart';
import 'package:ecobinproj/page/my_page.dart';
import 'package:ecobinproj/page/quiz/screen_quiz.dart'; // QuizScreen import
import 'package:ecobinproj/page/quiz_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static void onItemTapped(BuildContext context, int index) {
    final homePageState = context.findAncestorStateOfType<HomePage1>();
    if (homePageState != null) {
      homePageState.onItemTapped(index);
    }
  }

  @override
  State<HomePage> createState() => HomePage1();
}

class HomePage1 extends State<HomePage> {
  int selectedIndex = 0;
  List<Quiz> selectedQuizs = []; // Quiz 데이터를 저장할 리스트

  final List<Widget> _pages = <Widget>[

    const HomeScreen(),
    const CameraPage(),

    const MapPage(
      result: '',
    ),
    QuizPage(),
    const MyPage(),
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        toolbarHeight: 40,
        backgroundColor: Colors.black45,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black45,
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        items: const [
          BottomNavigationBarItem(
            backgroundColor: Colors.grey,
            icon: Icon(
              Icons.home,
              color: Colors.white,
            ),
            label: "홈",
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.grey,
            icon: Icon(
              Icons.camera,
              color: Colors.white,
            ),
            label: "카메라",
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.grey,
            icon: Icon(
              Icons.map,
              color: Colors.white,
            ),
            label: "지도",
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.grey,
            icon: Icon(
              Icons.quiz,
              color: Colors.white,
            ),
            label: "퀴즈",
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.grey,
            icon: Icon(
              Icons.people,
              color: Colors.white,
            ),
            label: "마이페이지",
          ),
        ],
      ),
      // 동적으로 QuizScreen 표시
      body: selectedIndex == 3 && selectedQuizs.isNotEmpty
          ? QuizScreen(quizs: selectedQuizs)  // 퀴즈 데이터를 전달하여 화면 표시
          : _pages[selectedIndex], // 나머지 페이지 표시
    );
  }
}
