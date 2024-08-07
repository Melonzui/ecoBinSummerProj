import 'package:ecobinproj/page/camera.dart';
import 'package:ecobinproj/page/map_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    const HomeScreen(),
    const MapPage(),
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
              Icons.house,
              color: Colors.red,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.map,
              color: Colors.red,
            ),
            label: "Add",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.abc,
              color: Colors.red,
            ),
            label: "Custom",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.dangerous_rounded,
              color: Colors.red,
            ),
            label: "Danger",
          ),
        ],
      ),
      body: _pages[_selectedIndex],
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              '테스트 홈화면',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
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
