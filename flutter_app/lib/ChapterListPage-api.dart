import 'dart:convert';
import 'package:http/http.dart' as http;

class ChapterListPageApi {
  static Future<List<LectureContent>> fetchChapterList(int lectureID) async {
    final apiUrl = Uri.parse(
        'http://192.168.0.75:3010/lecturevideo/?lectureID=$lectureID');

    try {
      final response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic>? lectureContentsJson = jsonData['data'];
        print(lectureContentsJson);

        if (lectureContentsJson != null && lectureContentsJson is List) {
          List<LectureContent> lectureContents = [];
          Map<String, LectureContent> lectureMap = {};

          for (var contentJson in lectureContentsJson) {
            final lectureContent = LectureContent.fromJson(contentJson);
            final contentTitle = lectureContent.contentTitle;

            if (!lectureMap.containsKey(contentTitle)) {
              lectureMap[contentTitle] = lectureContent;
            }

            // 해당 LectureContent 객체에 하위 목차 추가
            final subChapter = SubChapter.fromJson(contentJson);
            lectureMap[contentTitle]?.subChapters.add(subChapter);
          }

          // LectureContents 객체를 리스트에 추가
          lectureContents.addAll(lectureMap.values);

          return lectureContents;
        } else {
          throw Exception('실패');
        }
      } else {
        throw Exception('강의 목록 로드 실패: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('강의 목록 불러오기 오류: $error');
    }
  }
}

class LectureContent {
  final String contentTitle;
  final List<SubChapter> subChapters;

  LectureContent({
    required this.contentTitle,
    required this.subChapters,
  });

  factory LectureContent.fromJson(Map<String, dynamic> json) {
    return LectureContent(
      contentTitle: json['contentTitle'],
      subChapters: [], // 하위 목차를 빈 목록으로 초기화
    );
  }
}

class SubChapter {
  final String table_of_contents_of_sub_lecturesTitle;
  final int video_time;
  final String video_url;
  final int table_of_contents_of_sub_lecturesID;

  SubChapter(
      {required this.table_of_contents_of_sub_lecturesTitle,
      required this.video_time,
      required this.video_url,
      required this.table_of_contents_of_sub_lecturesID});

  factory SubChapter.fromJson(Map<String, dynamic> json) {
    return SubChapter(
        table_of_contents_of_sub_lecturesTitle:
            json['table_of_contents_of_sub_lecturesTitle'],
        video_time: json['video_time'],
        video_url: json['video_url'],
        table_of_contents_of_sub_lecturesID:
            json['table_of_contents_of_sub_lecturesID']);
  }
}
