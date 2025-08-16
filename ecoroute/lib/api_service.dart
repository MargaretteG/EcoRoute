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

  // ✅ NEW: Sign In
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
      if (streamedResponse.statusCode == 200) {
        return jsonDecode(responseString);
      } else {
        throw Exception("HTTP ${streamedResponse.statusCode}: $responseString");
      }
    } catch (e) {
      throw Exception("Network error: ${e.toString()}");
    }
  }
}
