// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:http/http.dart';

class HttpService {
  final String baseURl = "https://api.carvia-test.org/store-service";

  Future<List<Map<String, dynamic>>> getData(int page) async {
    Response res = await get(Uri.parse('$baseURl/notes?page=$page'));

    if (res.statusCode == 200) {
      final List<dynamic> content = jsonDecode(res.body)['content'] ?? [];
      print("Content data is $content");
      return content.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch notes');
    }
  }

  Future<void> postData(
      {String? note, String? imagePath, String? filePath}) async {
    final Uri url = Uri.parse('$baseURl/notes');

    try {
      var request = MultipartRequest('POST', url);
      if (note != null) {
        request.fields['note'] = note;
      }
      if (imagePath != null) {
        request.files.add(await MultipartFile.fromPath('file', imagePath));
      }
      if (filePath != null) {
        request.files.add(await MultipartFile.fromPath('file', filePath));
      }

      var streamedRespone = await request.send();
      var response = await Response.fromStream(streamedRespone);

      if (response.statusCode == 200) {
        // Successfully posted data
        print('Data posted successfully $response');
      } else {
        // Handle error responses
        print('Failed to post data: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      // Handle network or server errors
      print('Error posting data: $e');
    }
  }
}
