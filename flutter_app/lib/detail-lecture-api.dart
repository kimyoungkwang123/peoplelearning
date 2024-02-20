import 'dart:convert';
import 'package:http/http.dart' as http;
import 'detail-lecture.dart';

class DetailLectureApi {
  static Future<DetailLectureData> fetchDetailLecture(
      int lectureId, String? userEmail) async {
    final apiUrl = 'http://192.168.0.75:3010/lecturedetail/';

    try {
      final response = await http.get(
        Uri.parse(
          '$apiUrl?lectureID=$lectureId${userEmail != null ? '&userEmail=$userEmail' : ''}',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // 나머지 코드는 그대로 유지합니다.
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print(data);
        DetailLectureData detailLectureResponse =
            DetailLectureData.fromJson(data);
        print(detailLectureResponse);
        return detailLectureResponse;
      } else {
        throw Exception('Failed to load detail lecture');
      }
    } catch (error) {
      print(error);
      throw Exception(error);
    }
  }
}

class DetailLectureData {
  final LectureInfo lectureInfo;
  final LectureMaterialsActive lectureMaterialsActive;
  final InstructorInfo instructorInfo;
  final List<LectureContentTitle> lectureContentTitle;

  DetailLectureData({
    required this.lectureInfo,
    required this.lectureMaterialsActive,
    required this.instructorInfo,
    required this.lectureContentTitle,
  });

  factory DetailLectureData.fromJson(Map<String, dynamic> json) {
    return DetailLectureData(
      lectureInfo: LectureInfo.fromJson(json['lectureInfo']),
      lectureMaterialsActive:
          LectureMaterialsActive.fromJson(json['lectureMaterialsActive']) ??
              LectureMaterialsActive(ispurchased: 0),
      instructorInfo: InstructorInfo.fromJson(json['instructorInfo']),
      lectureContentTitle: (json['lecturecontentTitle'] as List)
          .map((contentJson) => LectureContentTitle.fromJson(contentJson))
          .toList(),
    );
  }
}

class LectureInfo {
  final String lecture_materialsType;
  final String lecture_materialsURL;
  final String lectureTitle;
  final String lectureText;
  final int Lecture_materialsID;
  final String Lecture_image_URL;
  final int price;
  final double average_scope;

  LectureInfo({
    required this.lecture_materialsType,
    required this.lecture_materialsURL,
    required this.lectureTitle,
    required this.lectureText,
    required this.Lecture_materialsID,
    required this.Lecture_image_URL,
    required this.price,
    required this.average_scope,
  });

  factory LectureInfo.fromJson(Map<String, dynamic> json) {
    return LectureInfo(
      lecture_materialsType: json['lecture_materialsType'],
      lecture_materialsURL: json['lecture_materialsURL'],
      lectureTitle: json['lectureTitle'],
      lectureText: json['lectureText'],
      Lecture_materialsID: json['Lecture_materialsID'],
      Lecture_image_URL: json['Lecture_image_URL'],
      price: json['price'],
      average_scope: (json['average_scope'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class LectureMaterialsActive {
  final int ispurchased;

  LectureMaterialsActive({
    required this.ispurchased,
  });

  factory LectureMaterialsActive.fromJson(dynamic json) {
    if (json is List<dynamic> && json.isNotEmpty) {
      // 리스트의 첫 번째 요소를 가져와서 처리
      final Map<String, dynamic> data = json[0];
      return LectureMaterialsActive(
        ispurchased: data['Lecture_materials_Active'] ?? 0,
      );
    } else if (json is Map<String, dynamic>) {
      // 단일 객체인 경우 바로 처리
      return LectureMaterialsActive(
        ispurchased: json['Lecture_materials_Active'] ?? 0,
      );
    } else {
      // 다른 형식의 데이터인 경우 기본값 반환
      return LectureMaterialsActive(
        ispurchased: 0,
      );
    }
  }
}

class InstructorInfo {
  final String instructorName;
  final String instructorText;

  InstructorInfo({
    required this.instructorName,
    required this.instructorText,
  });

  factory InstructorInfo.fromJson(Map<String, dynamic> json) {
    return InstructorInfo(
      instructorName: json['InstructorName'],
      instructorText: json['InstructorText'],
    );
  }
}

class LectureContentTitle {
  final String contentTitle;

  LectureContentTitle({
    required this.contentTitle,
  });

  factory LectureContentTitle.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      final contentTitle = json['contentTitle'];
      return LectureContentTitle(
        contentTitle: contentTitle is String ? contentTitle : '',
      );
    } else if (json is List<dynamic> && json.isNotEmpty) {
      final contentTitle = json[0]['contentTitle'];
      return LectureContentTitle(
        contentTitle: contentTitle is String ? contentTitle : '',
      );
    } else if (json is String) {
      return LectureContentTitle(
        contentTitle: json.isNotEmpty ? json : '',
      );
    } else {
      return LectureContentTitle(
        contentTitle: '',
      );
    }
  }
}
