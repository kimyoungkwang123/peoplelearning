import 'package:flutter/material.dart';
import '../main-page.dart';
import 'signup-api.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: '이름을 입력하세요'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: '이메일을 입력하세요'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: '전화번호를 입력하세요'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: '비밀번호를 입력하세요'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: '비밀번호를 다시 입력하세요'),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    // 취소 버튼 클릭 시 현재 페이지 닫고 이전 페이지로 이동
                    onCancelSignupPressed(context);
                  },
                  child: Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 회원가입 버튼 클릭 시 회원가입 시도
                    onSignupPressed(context);
                  },
                  child: Text('회원가입'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void onCancelSignupPressed(BuildContext context) {
    // 회원가입 취소 로직
    print('회원가입 취소');
    // 회원가입 취소 후 로그인 페이지로 이동
    Navigator.pop(context);
  }

  void onSignupPressed(BuildContext context) async {
    // 회원가입 시도 로직
    print('회원가입 시도');

    final String name = _nameController.text;
    final String email = _emailController.text;
    final String phoneNumber = _phoneNumberController.text;
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    // 비밀번호 확인
    if (password != confirmPassword) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('비밀번호가 일치하지 않습니다.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
      return;
    }

    bool isEmailValid(String email) {
      // 이메일 정규 표현식
      final RegExp regex =
          RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      return regex.hasMatch(email);
    }

// 전화번호 형식 변경 함수
    String formatPhoneNumber(String phoneNumber) {
      // 숫자만 남기고 나머지 문자 제거
      phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      // 전화번호 형식에 맞게 변경
      return phoneNumber.replaceFirstMapped(
          RegExp(r'^(\d{3})(\d{3,4})(\d{4})$'),
          (match) => '${match[1]}-${match[2]}-${match[3]}');
    }

    try {
      // 이메일 형식 확인
      if (!isEmailValid(email)) {
        throw Exception('올바른 이메일 형식이 아닙니다.');
      }
      // 전화번호 형식 확인 및 변경
      String formattedPhoneNumber = formatPhoneNumber(phoneNumber);

      // 회원가입 시도
      await SignupApi.signup(
        userEmail: email,
        cellphone: formattedPhoneNumber,
        password: password,
        userName: name,
      );

      // 회원가입 성공 시 메인 페이지로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(),
        ),
      );
    } catch (error) {
      // 회원가입 실패 시 에러 메시지 출력
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(error.toString()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
    }
  }
}
