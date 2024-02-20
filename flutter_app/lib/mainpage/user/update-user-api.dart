import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdateUserAPI {
  static Future<void> updateUser(String userEmail, String userName,
      String currentPassword, String newPassword) async {
    try {
      final apiUrl = 'http://192.168.0.75:3010/user/update-user';
      final requestBody = {
        'userEmail': userEmail,
        'userName': userName,
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        print('User information updated successfully');
      } else {
        print(
            'Failed to update user information. Server returned status code: ${response.statusCode}');
        print('Server response: ${response.body}');
        throw Exception(
            'Failed to update user information. Server returned status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error updating user information: $error');
      throw Exception('Failed to connect to the server');
    }
  }
}
