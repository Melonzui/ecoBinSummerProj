import 'package:flutter/material.dart';

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
