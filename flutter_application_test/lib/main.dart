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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  // 추가된 부분 시작
  Future<void> _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    final Uri uri = Uri.parse('http://localhost:3000/login');
    final response = await http.post(
      uri,
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      print('Login successful! Response: ${response.body}');
    } else {
      print('Login failed. Status code: ${response.statusCode}');
    }
  }
  // 추가된 부분 끝

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.greenAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 32),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  ElevatedButton(
                    onPressed: _login,
                    child: Text('로그인'),
                  ),
                  ElevatedButton(
                    onPressed: _login,
                    child: Text('회원가입'),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
