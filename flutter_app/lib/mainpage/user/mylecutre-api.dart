import 'package:http/http.dart' as http;
import 'dart:convert';

class MyLectureApi {
  static Future<List<Lecture>> fetchUserLectures(
      String userEmail, String type, String sort,
      {Map<String, dynamic>? userInfo}) async {
    final apiUrl = 'http://192.168.0.75:3010/user/mylecture';

    try {
      final response = await http.get(
        Uri.parse(
            '$apiUrl?userEmail=$userEmail&type=$type&sort=$sort'), // sort 매개변수를 쿼리 문자열에 추가
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print(response.body);
        final List<dynamic> data = json.decode(response.body)['lecture_list'];
        List<Lecture> lectures =
            data.map((dynamic item) => Lecture.fromJson(item)).toList();
        print(data.runtimeType); // 데이터의 타입 출력
        print(data); // 실제 데이터 출력

        print(lectures);
        return lectures;
      } else {
        throw Exception('Failed to load user lectures');
      }
    } catch (error) {
      print(error);
      throw Exception(error);
    }
  }
}

class Lecture {
  final int lectureID;
  final double progress;
  final String Lecture_image_URL;
  final String lectureTitle;

  Lecture({
    required this.lectureID,
    required this.progress,
    required this.Lecture_image_URL,
    required this.lectureTitle,
  });

  factory Lecture.fromJson(Map<String, dynamic> json) {
    return Lecture(
      lectureID: json['lectureID'] as int,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      Lecture_image_URL: json['Lecture_image_URL'] as String,
      lectureTitle: json['lectureTitle'] as String,
    );
  }
}
