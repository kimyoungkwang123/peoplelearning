import 'dart:convert';
import 'package:http/http.dart' as http;

class BoardLikeApi {
  static Future<void> likeBoard({
    required int boardID,
    required String userEmail,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.75:3010/lecturevideo/board/like'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'boardID': boardID,
          'userEmail': userEmail,
        }),
      );

      if (response.statusCode == 200) {
        // 좋아요 요청이 성공적으로 처리되었을 때 추가 작업이 필요하다면 여기에 추가할 수 있습니다.
      } else {
        print('Failed to like board: ${response.statusCode}');
      }
    } catch (error) {
      print('Error liking board: $error');
    }
  }
}
