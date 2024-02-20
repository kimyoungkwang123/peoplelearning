import 'dart:convert';
import 'package:http/http.dart' as http;

class WrittenBoardApi {
  static Future<void> postWrittenBoard({
    required String userEmail,
    required String boardText,
    required String boardTitle,
  }) async {
    final apiUrl = 'http://192.168.0.75:3010/user/written';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userEmail': userEmail,
          'boardText': boardText,
          'boardTitle': boardTitle,
        }),
      );

      if (response.statusCode == 200) {
        print('successfully');
      } else {
        throw Exception('Failed to insert board information');
      }
    } catch (error) {
      print('Error posting written board: $error');
      throw Exception(error);
    }
  }
}
