import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> fetchBasket(String userEmail) async {
  final String apiUrl =
      'http://192.168.0.75:3010/basket/mybasket?userEmail=$userEmail';

  try {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print(jsonData);
      // 서버로부터 성공적인 응답을 받았을 때 데이터 반환
      return {'success': true, 'data': jsonData};
    } else {
      // 오류 응답 처리
      return {
        'success': false,
        'error': 'Failed to load basket: ${response.statusCode}'
      };
    }
  } catch (error) {
    // 예외 처리
    return {'success': false, 'error': error};
  }
}

class Lecture {
  final int shopping_basketID;
  final String Lecture_image_URL;
  final String lectureTitle;
  final int price;
  final String instructorName;

  Lecture(
      {required this.shopping_basketID,
      required this.Lecture_image_URL,
      required this.lectureTitle,
      required this.price,
      required this.instructorName});
  factory Lecture.fromJson(Map<String, dynamic> json) {
    return Lecture(
        shopping_basketID: json['shopping_basketID'],
        Lecture_image_URL: json['Lecture_image_URL'],
        lectureTitle: json['lectureTitle'],
        price: json['price'],
        instructorName: json['instructorName']);
  }
}
