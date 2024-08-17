import 'package:ecobinproj/page/camera.dart';
import 'package:ecobinproj/page/home_screen.dart';
import 'package:ecobinproj/page/map_page.dart';
import 'package:ecobinproj/page/my_page.dart';
import 'package:ecobinproj/page/quiz_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  int _selectedIndex = 2;

  final List<Widget> _pages = <Widget>[
    const QuizPage(),
    const CameraPage(),
    const HomeScreen(),
    const MapPage(
      result: '',
    ),
    const MyPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "홈 화면",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        toolbarHeight: 40,
        backgroundColor: Colors.grey,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            //backgroundColor: Colors.grey,
            icon: Icon(
              Icons.question_mark,
              color: Colors.red,
            ),
            label: "Quiz",
          ),
          BottomNavigationBarItem(
            //backgroundColor: Colors.grey,
            icon: Icon(
              Icons.camera,
              color: Colors.red,
            ),
            label: "Camera",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: Colors.red,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.map,
              color: Colors.red,
            ),
            label: "map",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.people,
              color: Colors.red,
            ),
            label: "Profile",
          ),
        ],
      ),
      body: _pages[_selectedIndex],
    );
  }
}
