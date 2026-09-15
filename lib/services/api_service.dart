import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../models/article.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api/v1';

  // ===== POSTS =====

  static Future<List<Article>> getPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/posts/posts'));
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat artikel (${response.statusCode})');
    }
    final body = json.decode(response.body);
    final List<dynamic> data = body['data'];
    return data.map((e) => Article.fromJson(e)).toList();
  }

  static Future<Article> getPostById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/posts/posts/$id'));
    if (response.statusCode != 200) {
      throw Exception('Artikel tidak ditemukan');
    }
    final body = json.decode(response.body);
    return Article.fromJson(body['data']);
  }

  static Future<void> savePost({
    int? id,
    required int categoryId,
    required String title,
    required String content,
    XFile? imageFile,
  }) async {
    final isUpdate = id != null;
    final uri = Uri.parse(
      isUpdate ? '$baseUrl/posts/posts/$id' : '$baseUrl/posts/posts',
    );

    final request = http.MultipartRequest(isUpdate ? 'PUT' : 'POST', uri);
    request.fields['categoryId'] = categoryId.toString();
    request.fields['title'] = title;
    request.fields['content'] = content;

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      final extension = imageFile.name.split('.').last.toLowerCase();
      final mimeType = (extension == 'png') ? 'png' : 'jpeg';

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: imageFile.name.isNotEmpty ? imageFile.name : 'upload.$extension',
          contentType: MediaType('image', mimeType),
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Gagal menyimpan artikel (${response.statusCode})');
    }
  }

  static Future<void> deletePost(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/posts/posts/$id'));
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus artikel');
    }
  }

  // ===== CATEGORIES =====

  static Future<List<Category>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat kategori (${response.statusCode})');
    }
    final body = json.decode(response.body);
    final List<dynamic> data = body['data'];
    return data.map((e) => Category.fromJson(e)).toList();
  }

  static Future<void> createCategory(String name, {XFile? imageFile}) async {
    final uri = Uri.parse('$baseUrl/categories');
    final request = http.MultipartRequest('POST', uri);
    request.fields['name'] = name;

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      final extension = imageFile.name.split('.').last.toLowerCase();
      final mimeType = (extension == 'png') ? 'png' : 'jpeg';

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: imageFile.name.isNotEmpty ? imageFile.name : 'upload.$extension',
          contentType: MediaType('image', mimeType),
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Gagal membuat kategori (${response.statusCode})');
    }
  }

  static Future<void> updateCategory(int id, String name, {XFile? imageFile}) async {
    final uri = Uri.parse('$baseUrl/categories/$id');
    final request = http.MultipartRequest('PUT', uri);
    request.fields['name'] = name;

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      final extension = imageFile.name.split('.').last.toLowerCase();
      final mimeType = (extension == 'png') ? 'png' : 'jpeg';

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: imageFile.name.isNotEmpty ? imageFile.name : 'upload.$extension',
          contentType: MediaType('image', mimeType),
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Gagal mengubah kategori (${response.statusCode})');
    }
  }

  static Future<void> deleteCategory(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/categories/$id'));
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus kategori');
    }
  }
}