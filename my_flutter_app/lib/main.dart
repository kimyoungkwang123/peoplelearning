import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _userEmailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  void _login() async {
    String userEmail = _userEmailController.text;
    String password = _passwordController.text;

    // 서버로 로그인 요청을 보내는 부분
    // 이 부분에서 서버 주소와 실제 로그인 처리 로직을 구현해야 합니다.
    var response = await http.post(
      Uri.parse('http://15.164.219.104:3010/login'),
      body: {'userEmail': userEmail, 'password': password},
    );

    if (response.statusCode == 200) {
      print('로그인 성공');
    } else {
      print('로그인 실패');
    }
  }

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
              controller: _userEmailController,
              decoration: InputDecoration(labelText: 'User Email'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _login,
              child: Text('로그인'),
            ),
          ],
        ),
      ),
    );
  }
}
