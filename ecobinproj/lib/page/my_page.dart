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
  bool _isLoading = true; // 로딩 상태 변수

  @override
  void initState() {
    super.initState();
    getUserLoggedInStatus();
  }

  Future<void> getUserLoggedInStatus() async {
    try {
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
    } catch (e) {
      print('Error fetching login status: $e');
    } finally {
      setState(() {
        _isLoading = false; // 로딩 완료
      });
    }
  }

  Future<void> fetchUserPoint() async {
    try {
      int point = await firebaseDatabase.getPoint();
      setState(() {
        userPoint = point;
      });
    } catch (e) {
      print('Failed to fetch user points: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // 로딩 중일 때 표시
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  child: Icon(Icons.person, size: 50),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User ID: ${firebaseDatabase.uid}', // 사용자 아이디 표시
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      TextButton(
                        onPressed: _isSignedIn
                            ? () async {
                          await authService.signOut(context);
                          setState(() {
                            _isSignedIn = false;
                            userPoint = 0; // 로그아웃 시 포인트 초기화
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('로그아웃되었습니다.')),
                          );
                        }
                            : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        child: Text(
                          _isSignedIn ? "로그아웃" : "로그인",
                          style: TextStyle(fontSize: 20),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero, // 여백 제거
                          minimumSize: Size(100, 40), // 최소 크기 설정
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 버튼 크기를 텍스트 크기로 맞춤
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: 40, thickness: 2), // 첫 번째 구분선
            Center(
              child: Text(
                '누적 포인트: ${_isSignedIn ? userPoint : 0}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(thickness: 2), // 두 번째 구분선
            ListTile(
              leading: Icon(Icons.quiz, size: 30), // 아이콘 크기를 키움
              title: const Text("내가 푼 퀴즈 다시보기"),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                if (!_isSignedIn) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('로그인 상태에서는 클릭만 가능합니다.')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('내가 푼 문제 확인')),
                  );
                }
              },
            ),
            Divider(thickness: 2), // 세 번째 구분선
            ListTile(
              leading: Icon(Icons.contact_support, size: 30), // 아이콘 크기를 키움
              title: const Text("고객센터"),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('고객센터페이지로 이동')),
                );
              },
            ),
            Divider(thickness: 2), // 네 번째 구분선
          ],
        ),
      ),
    );
  }

}
