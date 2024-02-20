import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> addToBasket(
    String userEmail, int lectureID) async {
  final String apiUrl = 'http://192.168.0.75:3010/basket/basketadd';
  final Map<String, dynamic> requestData = {
    'userEmail': userEmail,
    'lectureID': lectureID,
  };

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      body: jsonEncode(requestData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return {'success': true, 'message': jsonData['message']};
    } else {
      return {
        'success': false,
        'error':
            'Failed to add lecture to shopping basket: ${response.statusCode}'
      };
    }
  } catch (e) {
    return {'success': false, 'error': 'Failed to connect to the server.'};
  }
}

void main() async {
  final userEmail = 'example@example.com'; // 사용자 이메일
  final lectureID = 123; // 추가할 강의의 ID
  final result = await addToBasket(userEmail, lectureID);

  if (result['success']) {
    print('Lecture added to shopping basket: ${result['message']}');
  } else {
    print('Error: ${result['error']}');
  }
}
