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
    QuizPage(),
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
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
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
              Icons.camera,
              color: Colors.white,
            ),
            label: "카메라",
          ),
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
              Icons.map,
              color: Colors.white,
            ),
            label: "지도",
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
      body: _pages[_selectedIndex],
    );
  }
}
