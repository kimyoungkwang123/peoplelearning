import 'dart:convert';
import 'package:http/http.dart' as http;

class VideoPageApi {
  static Future<Map<String, dynamic>> fetchVideoData(
    String table_of_contents_of_sub_lecturesID,
  ) async {
    final apiUrl = 'http://192.168.0.75:3010/lecturevideo/videoDetail';

    try {
      final response = await http.get(
        Uri.parse(
            '$apiUrl?table_of_contents_of_sub_lecturesID=$table_of_contents_of_sub_lecturesID'), // 변경됨
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print(response.body);
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load video data: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to load video data: $error');
    }
  }
}

class VideoData {
  final String lectureTitle;
  final String table_of_contents_of_sub_lecturesTitle;
  final int video_time;
  final String video_url;

  VideoData({
    required this.lectureTitle,
    required this.table_of_contents_of_sub_lecturesTitle,
    required this.video_time,
    required this.video_url,
  });

  factory VideoData.fromJson(Map<String, dynamic> json) {
    return VideoData(
      lectureTitle: json['lectureTitle'],
      table_of_contents_of_sub_lecturesTitle:
          json['table_of_contents_of_sub_lecturesTitle'],
      video_time: json['video_time'],
      video_url: json['video_url'],
    );
  }
}
