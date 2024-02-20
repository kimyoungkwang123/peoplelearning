import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Category>> fetchCategoryList() async {
  final String apiUrl = 'http://192.168.0.75:3010/mainpage/categorynamelist';

  try {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      List<Category> categoryList =
          jsonData.map((item) => Category.fromJson(item)).toList();
      return categoryList;
    } else {
      throw Exception('Failed to load category list');
    }
  } catch (error) {
    throw Exception('Error fetching category list: $error');
  }
}

class Category {
  final int categoryID;
  final String categoryName;

  Category({
    required this.categoryID,
    required this.categoryName,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryID: json['categoryID'],
      categoryName: json['categoryName'],
    );
  }
}
