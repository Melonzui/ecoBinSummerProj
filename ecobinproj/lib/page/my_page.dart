import 'package:ecobinproj/data/sharedpreference/auth_sf.dart';
import 'package:ecobinproj/page/auth/login_page.dart';
import 'package:ecobinproj/services/auth/auth_services.dart';
import 'package:flutter/material.dart';

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPage();
}

class _MyPage extends State<MyPage> {
  bool _isSignedIn = false;
  AuthService authService = AuthService();

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
