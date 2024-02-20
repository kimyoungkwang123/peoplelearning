import 'dart:convert';
import 'package:http/http.dart' as http;

class SignupApi {
  static Future<void> signup({
    required String userEmail,
    required String cellphone,
    required String password,
    required String userName,
  }) async {
    final apiUrl = 'http://192.168.0.75:3010/mainpage/signup';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userEmail': userEmail,
          'cellphone': cellphone,
          'password': password,
          'userName': userName,
        }),
      );

      if (response.statusCode == 200) {
        print('Signup successful'); // 회원가입 성공 메시지 출력
      } else if (response.statusCode == 401) {
        print('User already exists'); // 이미 존재하는 사용자 메시지 출력
      } else {
        throw Exception('Failed to signup'); // 회원가입 실패 에러 던지기
      }
    } catch (error) {
      print('Error signing up: $error'); // 에러 메시지 출력
      throw Exception(error); // 서버 연결 실패 에러 던지기
    }
  }
}
