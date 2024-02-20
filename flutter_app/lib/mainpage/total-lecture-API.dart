import 'dart:convert';
import 'package:http/http.dart' as http;

class TotalLectureApi {
  static Future<List<Lecture>> fetchLectures(String type,
      {Map<String, dynamic>? userInfo}) async {
    final apiUrl = 'http://192.168.0.75:3010/totallecture/';

    try {
      // userInfo를 쿼리 매개변수에 추가하여 서버에 전달
      final response = await http.get(
        Uri.parse('$apiUrl?type=$type'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['lecture_list'];

        List<Lecture> lectures =
            data.map((dynamic item) => Lecture.fromJson(item)).toList();
        print(lectures);
        return lectures;
      } else {
        throw Exception('Failed to load lectures');
      }
    } catch (error) {
      print('Error in fetchLectures: $error'); // 에러 메시지 출력
      throw Exception('Failed to connect to the server');
    }
  }
}

class Lecture {
  final int lectureID;
  final String title;
  final String instructorName;
  final String imageURL;
  final int price;
  final double average_scope;
  final int isPurchased;
  final int categoryID;

  Lecture({
    required this.lectureID,
    required this.title,
    required this.instructorName,
    required this.imageURL,
    required this.price,
    required this.average_scope,
    required this.isPurchased,
    required this.categoryID,
  });

  factory Lecture.fromJson(Map<String, dynamic> json) {
    return Lecture(
      lectureID: json['lectureID'],
      title: json['lectureTitle'],
      instructorName: json['InstructorName'],
      imageURL: json['Lecture_image_URL'],
      price: json['price'],
      average_scope: (json['average_scope'] as num?)?.toDouble() ?? 0.0,
      isPurchased: json['isPurchased'],
      categoryID: json['categoryID'],
    );
  }
}
