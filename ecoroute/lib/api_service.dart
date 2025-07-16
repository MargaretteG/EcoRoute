import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ApiService {
  // 🔧 Change this to 10.0.2.2 if using emulator
  static const String baseUrl = "http://192.168.100.11/Ecoroute/";
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
    required int gender,
    required String username,
    required String password,
    String? validID,
    File? imageID,
  }) async {
    final uri = Uri.parse("${baseUrl}sign_up.php");

    try {
      var request = http.MultipartRequest('POST', uri)
        ..fields['firstName'] = firstName
        ..fields['lastName'] = lastName
        ..fields['address'] = address
        ..fields['email'] = email
        ..fields['phoneNum'] = phoneNum
        ..fields['nationality'] = nationality
        ..fields['dateBirth'] = dateBirth
        ..fields['gender'] = gender.toString()
        ..fields['ValidID'] = validID ?? ''
        ..fields['username'] = username
        ..fields['password'] = password;

      if (imageID != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'imageID', // matches PHP $_FILES['imageID']
            imageID.path,
          ),
        );
      }

      // Send the request
      final streamedResponse = await request.send().timeout(
        requestTimeoutUploadImage,
      );

      // Read and decode the response
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
