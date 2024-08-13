import 'package:ecobinproj/data/sharedpreference/auth_sf.dart';
import 'package:ecobinproj/page/auth/login_page.dart';
import 'package:ecobinproj/services/auth/auth_services.dart';
import 'package:ecobinproj/services/firebase/firestore_database.dart';
import 'package:flutter/material.dart';

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPage();
}

class _MyPage extends State<MyPage> {
  bool _isSignedIn = false;
  int userPoint = 0;
  AuthService authService = AuthService();
  DatabaseService firebaseDatabase = DatabaseService(uid: 'your_user_id'); // 유저 ID를 제공해야 합니다.

  @override
  void initState() {
    super.initState();
    getUserLoggedInStatus();
  }

  Future<void> getUserLoggedInStatus() async {
    bool? value = await HelperFunctions.getUserLoggedInStatus();
    if (value != null) {
      setState(() {
        _isSignedIn = value;
      });
      if (_isSignedIn) {
        // 로그인된 경우에만 포인트를 가져옵니다.
        await fetchUserPoint();
      }
    }
  }

  Future<void> fetchUserPoint() async {
    try {
      var point = await firebaseDatabase.getPoint();
      setState(() {
        userPoint = point;
      });
    } catch (e) {
      // 오류 처리
      print('Failed to fetch user point: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                '사용자 프로필 예정화면',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 20),
              Text(
                '사용자의 누적 포인트: $userPoint',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // 버튼 색상
                    textStyle: const TextStyle(color: Colors.white), // 텍스트 색상
                  ),
                  onPressed: _isSignedIn
                      ? null // 로그인된 경우 로그인 버튼 비활성화
                      : () {
                          // 로그인되지 않은 경우에만 페이지 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                  child: const Text(
                    "로그인",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // 버튼 색상
                    textStyle: const TextStyle(color: Colors.white), // 텍스트 색상
                  ),
                  onPressed: _isSignedIn
                      ? () async {
                          // 로그아웃 버튼 기능
                          await authService.signOut(context);
                          // 로그인 상태 갱신
                          setState(() {
                            _isSignedIn = false;
                            userPoint = 0; // 로그아웃 시 포인트 초기화
                          });
                        }
                      : null, // 로그아웃되지 않은 경우 로그아웃 버튼 비활성화
                  child: const Text(
                    "로그아웃",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
