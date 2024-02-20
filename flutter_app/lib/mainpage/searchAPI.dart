import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchAPI {
  static Future<List<SearchLecture>> fetchSearchResults(
      String? selectedCategory, String searchText) async {
    // 서버 통신 로직 작성
    final apiUrl = 'http://192.168.0.75:3010/mainpage/search';

    try {
      final response = await http.get(
        Uri.parse(
            '$apiUrl?lectureTitle=$searchText&categoryID=$selectedCategory'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['lecture_list'];

        List<SearchLecture> searchLecture =
            data.map((dynamic item) => SearchLecture.fromJson(item)).toList();
        print(searchLecture);
        return searchLecture;
      } else {
        throw Exception('Failed to load lectures');
      }
    } catch (error) {
      print('Error in fetchLectures: $error'); // 에러 메시지 출력
      throw Exception('Failed to connect to the server');
    }
  }
}

class SearchLecture {
  final int lectureID;
  final int categoryID;
  final String lectureTitle;
  final String InstructorName;
  final String Lecture_image_URL;
  final int price;
  final String categoryName;

  SearchLecture({
    required this.lectureID,
    required this.categoryID,
    required this.lectureTitle,
    required this.InstructorName,
    required this.Lecture_image_URL,
    required this.price,
    required this.categoryName,
  });

  factory SearchLecture.fromJson(Map<String, dynamic> json) {
    return SearchLecture(
      lectureID: json['lectureID'],
      categoryID: json['categoryID'],
      lectureTitle: json['lectureTitle'],
      InstructorName: json['InstructorName'],
      Lecture_image_URL: json['Lecture_image_URL'],
      price: json['price'],
      categoryName: json['categoryName'],
    );
  }
}
