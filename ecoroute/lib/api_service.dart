import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ApiService {
  static const String baseUrl = "https://ecoroute-taal.online/";
  static const Duration requestTimeout = Duration(seconds: 10);
  static const Duration requestTimeoutUploadImage = Duration(seconds: 20);

  late http.Client httpClient;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Uuid _uuid = const Uuid();

  ApiService() {
    httpClient = _createHttpClient();
  }

  http.Client _createHttpClient() {
    final HttpClient client = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    return IOClient(client);
  }

  Future<Map<String, dynamic>> signUp({
    required String firstName,
    required String lastName,
    required String address,
    required String email,
    required String phoneNum,
    required String nationality,
    required String dateBirth,
    required String gender,
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse("${baseUrl}signUpValidation.php");

    try {
      var request = http.MultipartRequest('POST', uri)
        ..fields['firstName'] = firstName
        ..fields['lastName'] = lastName
        ..fields['address'] = address
        ..fields['email'] = email
        ..fields['phoneNum'] = phoneNum
        ..fields['nationality'] = nationality
        ..fields['dateBirth'] = dateBirth
        ..fields['gender'] = gender
        ..fields['username'] = username
        ..fields['password'] = password;

      final streamedResponse = await request.send().timeout(
        requestTimeoutUploadImage,
      );

      final responseString = await streamedResponse.stream.bytesToString();
      if (streamedResponse.statusCode == 200) {
        return jsonDecode(responseString);
      } else {
        throw Exception("HTTP ${streamedResponse.statusCode}: $responseString");
      }
    } catch (e) {
      throw Exception("Network error: ${e.toString()}");
    }
  }

  // Sign In
  // Future<Map<String, dynamic>> signIn1({
  //   required String username,
  //   required String password,
  // }) async {
  //   final uri = Uri.parse("${baseUrl}loginValidation.php");

  //   try {
  //     var request = http.MultipartRequest('POST', uri)
  //       ..fields['username'] = username
  //       ..fields['password'] = password;

  //     final streamedResponse = await request.send().timeout(requestTimeout);

  //     final responseString = await streamedResponse.stream.bytesToString();
  //     print("DEBUG Login Response: $responseString");

  //     if (streamedResponse.statusCode == 200) {
  //       try {
  //         return jsonDecode(responseString);
  //       } catch (e) {
  //         throw Exception("Invalid JSON: $responseString");
  //       }
  //     } else {
  //       throw Exception("HTTP ${streamedResponse.statusCode}: $responseString");
  //     }
  //   } catch (e) {
  //     throw Exception("Network error: ${e.toString()}");
  //   }
  // }

  Future<Map<String, dynamic>> signIn({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse("${baseUrl}loginValidation.php");

    try {
      var request = http.MultipartRequest('POST', uri)
        ..fields['username'] = username
        ..fields['password'] = password;

      final streamedResponse = await request.send().timeout(requestTimeout);
      final responseString = await streamedResponse.stream.bytesToString();
      print("DEBUG Login Response: $responseString");

      if (streamedResponse.statusCode == 200) {
        final data = jsonDecode(responseString);

        if (data["status"] == "success") {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("token", data["token"]);
          await prefs.setInt("accountId", data["accountId"]); // <-- save it
          await prefs.setString("userData", jsonEncode(data["user"]));
        }

        return data;
      } else {
        throw Exception("HTTP ${streamedResponse.statusCode}: $responseString");
      }
    } catch (e) {
      throw Exception("Network error: ${e.toString()}");
    }
  }

  Future<Map<String, dynamic>> fetchProfile({required int accountId}) async {
    final uri = Uri.parse("${baseUrl}getProfile.php?accountId=$accountId");
    final response = await httpClient.get(uri).timeout(requestTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        return data['user'];
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception("HTTP ${response.statusCode}: ${response.body}");
    }
  }

  //Logout
  static Future<void> logoutUser(int accountId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/logout.php"),
      body: {
        "accountId": accountId.toString(),
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        return; // logout worked
      } else {
        throw Exception(data['message'] ?? "Logout failed");
      }
    } else {
      throw Exception("Failed to logout (HTTP ${response.statusCode})");
    }
  }

  Future<void> saveUserData(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userData", jsonEncode(user));
  }

  Future<Map<String, dynamic>> updateProfile(
    Map<String, String> body, {
    File? imageFile,
  }) async {
    final uri = Uri.parse("${baseUrl}editProfile.php");
    var request = http.MultipartRequest('POST', uri)..fields.addAll(body);

    // 👇 Only attach if user selected an image
    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('profile_picture', imageFile.path),
      );
    }

    final streamed = await request.send();
    final response = await streamed.stream.bytesToString();
    return jsonDecode(response);
  }

  // Submit Community Post
  Future<Map<String, dynamic>> submitPost({
    required int accountId,
    String caption = '',
    List<String> imageUrls = const [],
  }) async {
    final uri = Uri.parse("${baseUrl}inputCommunityPost.php");

    try {
      var request = http.MultipartRequest('POST', uri)
        ..fields['accountId'] = accountId.toString()
        ..fields['postCaption'] = caption
        ..fields['postImages'] = jsonEncode(imageUrls);

      final streamedResponse = await request.send().timeout(
        requestTimeoutUploadImage,
      );
      final responseString = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        final data = jsonDecode(responseString);
        return data;
      } else {
        throw Exception("HTTP ${streamedResponse.statusCode}: $responseString");
      }
    } catch (e) {
      throw Exception("Network error: ${e.toString()}");
    }
  }

  // Image Post Upload
  Future<String> uploadPostImage(File imageFile) async {
    final uri = Uri.parse("${baseUrl}uploadPostImage.php");
    var request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    final streamed = await request.send();
    final response = await streamed.stream.bytesToString();
    final data = jsonDecode(response);

    if (data['status'] == 'success') {
      return data['url'];
    } else {
      throw Exception(data['message'] ?? 'Image upload failed');
    }
  }

  // Get User Post for Profile Page
  Future<List<Map<String, dynamic>>> getUserPosts({
    required int accountId,
  }) async {
    final uri = Uri.parse("$baseUrl/getUserPosts.php?accountId=$accountId");
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        final List posts = data['posts'] ?? [];
        return posts.map<Map<String, dynamic>>((post) {
          final images =
              (post['postImages'] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [];
          return {
            'communityPost_id': post['communityPost_id'],
            'postCaption': post['postCaption'] ?? '',
            'postImages': images,
            'dateCreated': post['dateCreated'] ?? '',
          };
        }).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch posts');
      }
    } else {
      throw Exception('Network error: ${response.statusCode}');
    }
  }
}
