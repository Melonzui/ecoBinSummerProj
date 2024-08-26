import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecobinproj/data/sharedpreference/auth_sf.dart';
import 'package:ecobinproj/page/auth/register_page.dart';
import 'package:ecobinproj/page/my_page.dart';
import 'package:ecobinproj/services/auth/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecobinproj/services/firebase/firestore_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  bool _isLoading = false;
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0c4da2),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MyPage(),
              ),
            );
          },
        ),
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(color: Color(0xFF5b8fe9)),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
          child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Text("에코빈",
                      style: TextStyle(
                          fontSize: 25, color: Color(0xFF0c4da2), fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "이메일",
                      hintText: "example@example.com",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      setState(() {
                        email = val;
                      });
                    },
                    validator: (val) {
                      return RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(val!)
                          ? null
                          : "유효한 이메일을 입력해주세요.";
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "비밀번호",
                      hintText: "6자리 이상의 비밀번호",
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val!.length < 6) {
                        return "비밀번호는 6자리 이상이어야 합니다.";
                      } else {
                        return null;
                      }
                    },
                    onChanged: (val) {
                      setState(() {
                        password = val;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0c4da2),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                      child: const Text(
                        "로그인",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      onPressed: () {
                        login();
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text.rich(TextSpan(
                    text: "계정이 없으신가요?  ",
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                    children: <TextSpan>[
                      TextSpan(
                          text: "여기를 눌러서 계정생성하기",
                          style: const TextStyle(
                              color: Colors.lightBlue, decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const RegisterPage(), // 계정이 없을 경우 회원가입 페이지로 이동
                                ),
                              );
                            }),
                    ],
                  )),
                ],
              )),
        ),
      ),
    );
  }

  login() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService.loginWithUserNameandPassword(email, password).then((value) async {
        if (value == true) {
          QuerySnapshot snapshot =
          await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).gettingUserData();
          if (snapshot.docs.isNotEmpty) {
            await HelperFunctions.saveUserLoggedInStatus(true);
            await HelperFunctions.saveUserEmailSF(email);
            await HelperFunctions.saveUserNameSF(snapshot.docs[0]['id']);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MyPage(), // 로그인 성공 시 마이페이지로 이동
              ),
            );
          } else {
            setState(() {
              _isLoading = false;
            });
          }
        } else {
          _showLoginErrorDialog();  // 로그인 실패 시 호출
          setState(() {
            _isLoading = false;
          });
        }
      }).catchError((e) {
        _showLoginErrorDialog();  // 로그인 실패 시 호출
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  void _showLoginErrorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("로그인 실패"),
          content: Text("이메일 또는 비밀번호가 잘못되었습니다. 회원가입 페이지로 이동하시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 대화상자 닫기
              },
              child: Text("아니요"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 대화상자 닫기
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterPage(), // 회원가입 페이지로 이동
                  ),
                );
              },
              child: Text("예"),
            ),
          ],
        );
      },
    );
  }
}
