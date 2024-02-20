import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Payment>> fetchPurchaseHistory(String userEmail) async {
  try {
    final apiUrl = 'http://192.168.0.75:3010/user/purchase-history';
    final response = await http.get(
      Uri.parse('$apiUrl?userEmail=$userEmail'), // userEmail을 쿼리 스트링에 포함하여 요청
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print(response.body);
      final List<dynamic> data = json.decode(response.body)['payment_list'];

      // Payment.fromJson 함수를 사용하여 JSON 데이터를 Payment 객체로 변환
      List<Payment> payments =
          data.map((dynamic item) => Payment.fromJson(item)).toList();

      print(payments);
      return payments;
    } else {
      throw Exception('Failed to load purchase history');
    }
  } catch (error) {
    print(error); // 에러 메시지 출력
    throw Exception(error);
  }
}

class Payment {
  final String Lecture_image_URL;
  final String lectureTitle;
  final int price;
  final String Payment_Method;
  final DateTime payment_Date;

  Payment({
    required this.Lecture_image_URL,
    required this.lectureTitle,
    required this.price,
    required this.Payment_Method,
    required this.payment_Date,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      Lecture_image_URL: json['Lecture_image_URL'],
      lectureTitle: json['lectureTitle'],
      price: json['price'],
      Payment_Method: json['Payment_Method'],
      payment_Date: DateTime.parse(json['payment_Date']),
    );
  }
}
