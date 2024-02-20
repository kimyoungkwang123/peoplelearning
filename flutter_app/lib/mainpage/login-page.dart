import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../main-page.dart';
import '../(login)main-page.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 아이디,비밀번호 입력
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: '이메일'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: '비밀번호'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                onKakaoLoginPressed();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.yellow,
              ),
              child: Text('Kakao로 로그인'),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly, // 버튼들을 가로로 균등하게 배치
              children: [
                TextButton(
                  onPressed: () {
                    // "취소" 버튼 클릭 시 실행될 함수
                    onCancelPressed(context);
                  },
                  child: Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    // "취소" 버튼 클릭 시 실행될 함수
                    onLoginPressed(context);
                  },
                  child: Text('로그인'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void onKakaoLoginPressed() async {
    // try {
    //   bool isInstalled = await isKakaoTalkInstalled();

    //   OAuthToken token = isInstalled
    //       ? await UserApi.instance.loginWithKakaoTalk()
    //       : await UserApi.instance.loginWithKakaoAccount();

    //   print('카카오 로그인 성공');

    //   // 로그인 후 사용자 정보 가져오기
    //   final User user = await UserApi.instance.me();
    //   final String userEmail = user.kakaoAccount!.email!;
    //   final String userName = user.kakaoAccount!.profile!.nickname!;

    //   // 사용자 정보를 MainPageLogin으로 전달하여 페이지 이동
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => MainPageLogin(
    //         userInfo: {
    //           'userEmail': userEmail,
    //           'userName': userName,
    //         },
    //       ),
    //     ),
    //   );
    // } catch (error) {
    //   // 로그인 실패 시 처리
    //   print('로그인 실패: $error');

    //   if (error is KakaoClientException) {
    //     if (error.message == 'CANCELED') {
    //       // 사용자가 로그인을 취소한 경우
    //       print('로그인 취소됨');
    //     } else {
    //       // 기타 오류인 경우
    //       print('로그인 오류: ${error.message}');
    //     }
    //   } else {
    //     // 기타 예외 발생 시
    //     print('예외 발생: $error');
    //   }
    // }

    if (await isKakaoTalkInstalled()) {
      try {
        await UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공');
        // 로그인 후 사용자 정보 가져오기
        final User user = await UserApi.instance.me();
        final String userEmail = user.kakaoAccount!.email!;
        final String userName = user.kakaoAccount!.profile!.nickname!;

        // 사용자 정보를 MainPageLogin으로 전달하여 페이지 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MainPageLogin(
              userInfo: {
                'userEmail': userEmail,
                'userName': userName,
              },
            ),
          ),
        );
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');

        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {
          return;
        }
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
          await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공');
          // 로그인 후 사용자 정보 가져오기
          final User user = await UserApi.instance.me();
          final String userEmail = user.kakaoAccount!.email!;
          final String userName = user.kakaoAccount!.profile!.nickname!;

          // 사용자 정보를 MainPageLogin으로 전달하여 페이지 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MainPageLogin(
                userInfo: {
                  'userEmail': userEmail,
                  'userName': userName,
                },
              ),
            ),
          );
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
        }
      }
    } else {
      try {
        await UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공');
        // 로그인 후 사용자 정보 가져오기
        final User user = await UserApi.instance.me();
        final String userEmail = user.kakaoAccount!.email!;
        final String userName = user.kakaoAccount!.profile!.nickname!;

        // 사용자 정보를 MainPageLogin으로 전달하여 페이지 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MainPageLogin(
              userInfo: {
                'userEmail': userEmail,
                'userName': userName,
              },
            ),
          ),
        );
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
      }
    }
  }

  void onLoginPressed(BuildContext context) async {
    final Map<String, dynamic> data = {
      'userEmail': _usernameController.text,
      'password': _passwordController.text,
    };
    final String url = 'http://192.168.0.75:3010/mainpage/login';

    print('로그인 시도');

    try {
      final response = await http.post(
        Uri.parse(url),
        body: data,
      );

      if (response.statusCode == 200) {
        // 로그인 성공 시
        print('${response.body}');

        // 응답에서 토큰 추출
        final Map<String, dynamic> responseData = json.decode(response.body);
        String? token = responseData['token'];

        if (token != null) {
          // 토큰 저장
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('token', token);
        }

        // 성공 시 페이지 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MainPageLogin(userInfo: json.decode(response.body)),
          ),
        );
      } else {
        // 로그인 실패 시
        print('로그인 실패: ${response.body}');
      }
    } catch (error) {
      // 오류 발생 시 처리
      print('오류 발생: $error');
    }
  }

  void onCancelPressed(BuildContext context) {
    // "취소" 버튼 클릭 시 실행될 함수
    print('로그인 취소');
    //취소 누를 시 메인페이지 로그인 안한 상태로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MainPage()), // NextPage는 이동하고자 하는 페이지입니다.
    );
  }
}
