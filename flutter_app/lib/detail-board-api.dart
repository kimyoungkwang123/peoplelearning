import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailBoardApi {
  static Future<Map<String, dynamic>> fetchDetailBoard(String boardID) async {
    final response = await http.get(Uri.parse(
        'http://192.168.0.75:3010/lecturevideo/board/detail?boardID=$boardID'));

    if (response.statusCode == 200) {
      // 서버로부터 데이터를 성공적으로 받아온 경우
      final jsonData = json.decode(response.body);
      print(response.body);
      return {
        'code': jsonData['code'],
        'message': jsonData['message'],
        'data': jsonData['data']
      };
    } else {
      // 요청이 실패한 경우
      throw Exception('Failed to load detail board data');
    }
  }
}

class BoardDetail {
  final String boardTitle;
  final String boardText;
  final DateTime boardTime;
  final int boardLike;
  final int boardUnlike;
  final String userName;
  final int boardCount;

  BoardDetail(
      {required this.boardTitle,
      required this.boardText,
      required this.boardTime,
      required this.boardLike,
      required this.boardUnlike,
      required this.userName,
      required this.boardCount});

  factory BoardDetail.fromJson(Map<String, dynamic> json) {
    return BoardDetail(
        boardTitle: json['boardTitle'],
        boardText: json['boardText'],
        boardTime: DateTime.parse(json['boardTime']),
        boardLike: json['boardLike'],
        boardUnlike: json['boardUnlike'],
        userName: json['userName'],
        boardCount: json['boardCount']);
  }
}
