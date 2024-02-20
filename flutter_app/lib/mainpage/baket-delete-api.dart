import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> deleteFromBasket(
    String userEmail, int shoppingBasketID) async {
  final String apiUrl = 'http://192.168.0.75:3010/basket/basketdelete';
  final Map<String, dynamic> requestData = {
    'userEmail': userEmail,
    'shoppingBasketID': shoppingBasketID,
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
        'error': 'Failed to delete item from basket: ${response.statusCode}'
      };
    }
  } catch (e) {
    return {'success': false, 'error': 'Failed to connect to the server.'};
  }
}
