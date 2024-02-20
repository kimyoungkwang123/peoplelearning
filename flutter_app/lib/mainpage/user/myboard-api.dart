import 'dart:convert';
import 'package:http/http.dart' as http;

class myboardAPI {
  static Future<List<Board>> fetchLectures(String userEmail,
      {Map<String, dynamic>? userInfo}) async {
    try {
      final apiUrl = 'http://192.168.0.75:3010/user/myboard';

      final response = await http.get(
        Uri.parse('$apiUrl?userEmail=$userEmail'), // userEmail을 쿼리 스트링에 포함하여 요청
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print(response.body);
        final List<dynamic> data = json.decode(response.body)['board_list'];

        List<Board> board =
            data.map((dynamic item) => Board.fromJson(item)).toList();
        return board;
      } else {
        throw Exception('Failed to load lectures');
      }
    } catch (error) {
      print('Error in fetchLectures: $error'); // 에러 메시지 출력
      throw Exception('Failed to connect to the server');
    }
  }
}

class Board {
  final int boardID;
  final int boardCount;
  final DateTime boardTime;
  final String boardText;
  final int boardLike;
  final String boardTitle;
  final int boardUnlike;

  Board({
    required this.boardID,
    required this.boardCount,
    required this.boardTime,
    required this.boardText,
    required this.boardLike,
    required this.boardTitle,
    required this.boardUnlike,
  });

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      boardID: json['boardID'],
      boardCount: json['boardCount'],
      boardTime: DateTime.parse(json['boardTime']),
      boardText: json['boardText'],
      boardLike: json['boardLike'],
      boardTitle: json['boardTitle'],
      boardUnlike: json['boardUnlike'],
    );
  }
}
