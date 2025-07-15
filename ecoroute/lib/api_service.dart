import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ApiService {
  static const String apiUrl = "https://127.0.0.1/";
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
    required String dateBirth, // in YYYY-MM-DD format
    required int gender, // you can send "Male"/"Female" or any string
    required String validID, // e.g., "Passport"
    required String imageID, // file name or path if you're storing image path
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse("${apiUrl}Ecoroute/sign_up.php");
    try {
      final response = await httpClient
          .post(
            uri,
            body: {
              'firstName': firstName,
              'lastName': lastName,
              'address': address,
              'email': email,
              'phoneNum': phoneNum,
              'nationality': nationality,
              'dateBirth': dateBirth,
              'gender': gender,
              'ValidID': validID,
              'imageID': imageID,
              'username': username,
              'password': password,
            },
          )
          .timeout(requestTimeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception("HTTP ${response.statusCode}");
    } catch (e) {
      throw Exception("Network error: ${e.toString()}");
    }
  }
}
