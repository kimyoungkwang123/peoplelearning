import 'dart:convert';
import 'package:http/http.dart' as http;

class VideoBoardApi {
  static Future<List<BoardPost>> fetchBoardData() async {
    final apiUrl = 'http://192.168.0.75:3010/lecturevideo/board';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        print('response.body : ' + response.body);
        if (responseData is Map<String, dynamic>) {
          final List<dynamic> boardDataList = responseData['data'];
          if (boardDataList is List) {
            return boardDataList
                .map((data) => BoardPost.fromJson(data))
                .toList();
          } else {
            throw Exception('Invalid board data format');
          }
        } else {
          throw Exception('Invalid response data format');
        }
      } else {
        throw Exception('Failed to load board data: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to load board data: $error');
    }
  }
}

class BoardPost {
  final int boardID;
  final String boardTitle;
  final String boardText;
  final DateTime boardTime;
  final int boardLike;
  final int boardUnlike;
  final String userName;
  final int boardCount;
  final int commentCount;

  BoardPost(
      {required this.boardID,
      required this.boardTitle,
      required this.boardText,
      required this.boardTime,
      required this.boardLike,
      required this.boardUnlike,
      required this.userName,
      required this.boardCount,
      required this.commentCount});

  factory BoardPost.fromJson(Map<String, dynamic> json) {
    return BoardPost(
        boardID: json['boardID'],
        boardTitle: json['boardTitle'],
        boardText: json['boardText'],
        boardTime: DateTime.parse(json['boardTime']),
        boardLike: json['boardLike'],
        boardUnlike: json['boardUnlike'],
        userName: json['userName'],
        boardCount: json['boardCount'],
        commentCount: json['commentCount']);
  }
}
