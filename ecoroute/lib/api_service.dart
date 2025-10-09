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

  //Fetch logged in User Profile
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

  //Fetch Users
  Future<Map<String, dynamic>> fetchUserById({required int userId}) async {
    final uri = Uri.parse("${baseUrl}getUsers.php?user_id=$userId");

    try {
      final response = await httpClient.get(uri).timeout(requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          final user = data['user'];

          // Safely parse numeric fields
          final parsedUserId = user['user_id'] is int
              ? user['user_id']
              : int.tryParse(user['user_id'].toString()) ?? 0;

          return {
            'user_id': parsedUserId,
            'firstName': user['firstName'] ?? '',
            'lastName': user['lastName'] ?? '',
            'userName': user['userName'] ?? '',
            'profilePic':
                user['profilePic'] != null &&
                    (user['profilePic'] as String).isNotEmpty
                ? "https://ecoroute-taal.online/uploads/profile_pics/${user['profilePic']}"
                : "https://ecoroute-taal.online/images/default_profile.png",
          };
        } else {
          throw Exception(data['message'] ?? 'User not found');
        }
      } else {
        throw Exception("HTTP ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      throw Exception("Network error: ${e.toString()}");
    }
  }

  //Logout
  static Future<void> logoutUser(int accountId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/logout.php"),
      body: {"accountId": accountId.toString()},
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

    // Only attach if user selected an image
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
            'likesCount': post['likesCount'] ?? 0,
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

// Get Community Posts
Future<List<Map<String, dynamic>>> getAllCommunityPosts() async {
  final uri = Uri.parse("${ApiService.baseUrl}getCommunityPosts.php");
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['status'] == 'success') {
      final List posts = data['posts'] ?? [];
      return posts.map<Map<String, dynamic>>((post) {
        final images =
            (post['postImages'] as List?)?.map((e) => e.toString()).toList() ??
            [];

        return {
          'communityPost_id': post['communityPost_id'],
          'user_id': post['user_id'],
          'userName': post['userName'] ?? '',
          'ProfilePic': post['profilePic'] ?? '',
          'postCaption': post['postCaption'] ?? '',
          'postImages': images,
          'dateCreated': post['dateCreated'] ?? '',
          'likesCount': post['likesCount'] ?? 0,
        };
      }).toList();
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch community posts');
    }
  } else {
    throw Exception('Network error: ${response.statusCode}');
  }
}

// Community Post Likes
Future<String> togglePostLike({
  required int userId,
  required int communityPostId,
}) async {
  final uri = Uri.parse("${ApiService.baseUrl}toggleLike.php");

  try {
    final response = await http
        .post(
          uri,
          body: {
            'user_id': userId.toString(),

            'communityPost_id': communityPostId.toString(),
          },
        )
        .timeout(ApiService.requestTimeout);

    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
      final data = jsonDecode(response.body);

      if (data['status'] == 'liked') {
        return 'liked';
      } else if (data['status'] == 'unliked') {
        return 'unliked';
      } else {
        throw Exception(data['message'] ?? 'Failed to toggle like');
      }
    } else {
      throw Exception("HTTP ${response.statusCode}: ${response.body}");
    }
  } catch (e) {
    throw Exception("Network error: ${e.toString()}");
  }
}

// Fetch all liked community posts for a specific user
Future<List<int>> fetchUserLikedPosts(int userId) async {
  final uri = Uri.parse(
    "${ApiService.baseUrl}getUserLikedPost.php?user_id=$userId",
  );

  try {
    final response = await http.get(uri).timeout(ApiService.requestTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success'] == true && data['favorites'] != null) {
        // Convert all IDs to int
        return List<int>.from(
          data['favorites'].map((e) => int.parse(e.toString())),
        );
      } else {
        return []; // No liked posts found
      }
    } else {
      throw Exception("HTTP ${response.statusCode}: ${response.body}");
    }
  } catch (e) {
    throw Exception("Network error: ${e.toString()}");
  }
}

//Add Comment on Community Posts
Future<Map<String, dynamic>> addCommunityPostComment({
  required int accountId,
  required int communityPostId,
  required String commentContent,
}) async {
  final uri = Uri.parse("${ApiService.baseUrl}addCommentPost.php");

  try {
    var request = http.MultipartRequest('POST', uri)
      ..fields['accountId'] = accountId.toString()
      ..fields['communityPost_id'] = communityPostId.toString()
      ..fields['commentContent'] = commentContent;

    final streamedResponse = await request.send();
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

// Fetch all comments for a community post
Future<List<Map<String, dynamic>>> fetchCommunityPostComments({
  required int communityPostId,
}) async {
  final uri = Uri.parse("${ApiService.baseUrl}getAllComments.php");

  try {
    var request = http.MultipartRequest('POST', uri)
      ..fields['communityPost_id'] = communityPostId.toString();

    final streamedResponse = await request.send();
    final responseString = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode == 200) {
      final data = jsonDecode(responseString);

      if (data['status'] == 'success') {
        // Returns the list of comments
        return List<Map<String, dynamic>>.from(data['comments']);
      } else {
        throw Exception("Failed to fetch comments: ${data['message']}");
      }
    } else {
      throw Exception("HTTP ${streamedResponse.statusCode}: $responseString");
    }
  } catch (e) {
    throw Exception("Network error: ${e.toString()}");
  }
}

// Add Travel Plan
Future<Map<String, dynamic>> addTravelPlan({
  required int accountId,
  required String travelTitle,
  required String travelDescription,
  required String travelStartDate,
  required String travelNumDays,
  required String customColor,
}) async {
  final uri = Uri.parse("${ApiService.baseUrl}addTravelPlan.php");

  try {
    var request = http.MultipartRequest('POST', uri)
      ..fields['accountId'] = accountId.toString()
      ..fields['travelTitle'] = travelTitle
      ..fields['travelDescription'] = travelDescription
      ..fields['travelStartDate'] = travelStartDate
      ..fields['travelNumdays'] = travelNumDays
      ..fields['customColor'] = customColor;

    final streamedResponse = await request.send().timeout(
      ApiService.requestTimeout,
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

// Fetch Travel Plans
Future<List<Map<String, dynamic>>> fetchTravelPlan({
  required int accountId,
}) async {
  final uri = Uri.parse(
    "${ApiService.baseUrl}fetchTravelPlan.php?accountId=$accountId",
  );

  try {
    final response = await http.get(uri).timeout(ApiService.requestTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        final List<dynamic> plans = data['data'] ?? [];
        return plans.map<Map<String, dynamic>>((plan) {
          return {
            'addTravel_id': plan['addTravel_id'],
            'travelTitle': plan['travelTitle'] ?? '',
            'travelDescription': plan['travelDescription'] ?? '',
            'travelStartDate': plan['travelStartDate'] ?? '',
            'travelNumDays': plan['travelNumDays'] ?? '',
            'customColor': plan['customColor'] ?? '',
          };
        }).toList();
      } else if (data['status'] == 'empty') {
        return []; // no travel plans found
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch travel plans');
      }
    } else {
      throw Exception("HTTP ${response.statusCode}: ${response.body}");
    }
  } catch (e) {
    throw Exception("Network error: ${e.toString()}");
  }
}

//Delete Travel Plan
Future<bool> deleteTravelPlan(int travelId) async {
  try {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}deleteTravelPlan.php'),
      body: {'addTravel_id': travelId.toString()},
    );

    print('HTTP status: ${response.statusCode}');
    print('Response body: "${response.body}"');

    if (response.statusCode != 200 || response.body.isEmpty) {
      return false;
    }

    final data = json.decode(response.body);

    if (data['success'] == true) {
      return true;
    } else {
      print('PHP error: ${data['error']}');
      return false;
    }
  } catch (e) {
    print('Error decoding response: $e');
    return false;
  }
}

// edit travel plan
// Future<bool> editTravelPlan(int travelId, String title, String date) async {
//   final response = await http.post(
//     Uri.parse('$apiUrl/editTravelPlan.php'),
//     body: {
//       'travelId': travelId.toString(),
//       'title': title,
//       'date': date,
//     },
//   );
//   final data = json.decode(response.body);
//   return data['success'] ?? false;
// }

// Add Group Travel Plan
Future<Map<String, dynamic>> addGroupTravel({
  required int accountId,
  required String groupTravelTitle,
  required String groupTravelDescription,
  required String groupTravelStartDate,
  required String groupTravelNumDays,
  required List<Map<String, String>> groupTravelMembers,
  required String customColor,
}) async {
  final uri = Uri.parse("${ApiService.baseUrl}addGroupTravel.php");

  try {
    var request = http.MultipartRequest('POST', uri)
      ..fields['accountId'] = accountId.toString()
      ..fields['groupTravelTitle'] = groupTravelTitle
      ..fields['groupTravelDescription'] = groupTravelDescription
      ..fields['groupTravelStartDate'] = groupTravelStartDate
      ..fields['groupTravelNumDays'] = groupTravelNumDays
      ..fields['groupTravelMembers'] = jsonEncode(groupTravelMembers)
      ..fields['customColor'] = customColor;

    final streamedResponse = await request.send().timeout(
      ApiService.requestTimeout,
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

// Fetch Group Travel Plans
Future<List<Map<String, dynamic>>> fetchGroupTravelPlan({
  required int accountId,
}) async {
  final uri = Uri.parse(
    "${ApiService.baseUrl}fetchGroupTravel.php?accountId=$accountId",
  );

  try {
    final response = await http.get(uri).timeout(ApiService.requestTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        final List<dynamic> plans = data['data'] ?? [];
        return plans.map<Map<String, dynamic>>((plan) {
          return {
            'groupTravel_id': plan['groupTravel_id'],
            'groupTravelTitle': plan['groupTravelTitle'] ?? '',
            'groupTravelDescription': plan['groupTravelDescription'] ?? '',
            'groupTravelStartDate': plan['groupTravelStartDate'] ?? '',
            'groupTravelNumDays': plan['groupTravelNumDays'] ?? '',
            'groupTravelMembers': plan['groupTravelMembers'] ?? [],
            'customColor': plan['customColor'] ?? '',
          };
        }).toList();
      } else if (data['status'] == 'empty') {
        return [];
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch travel plans');
      }
    } else {
      throw Exception("HTTP ${response.statusCode}: ${response.body}");
    }
  } catch (e) {
    throw Exception("Network error: ${e.toString()}");
  }
}

//Delete Group Travel
Future<bool> deleteGroupTravel(int groupTravelId) async {
  try {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}deleteGroupTravel.php'),
      body: {'groupTravel_id': groupTravelId.toString()},
    );

    print('HTTP status: ${response.statusCode}');
    print('Response body: "${response.body}"');

    if (response.statusCode != 200 || response.body.isEmpty) {
      return false;
    }

    final data = json.decode(response.body);

    if (data['success'] == true) {
      return true;
    } else {
      print('PHP error: ${data['error']}');
      return false;
    }
  } catch (e) {
    print('Error decoding response: $e');
    return false;
  }
}

Future<List<Map<String, dynamic>>> fetchAllEstablishments() async {
  final uri = Uri.parse("${ApiService.baseUrl}getEstablishmentDetails.php");

  const categoryMap = {
    1: 'Eco Park',
    2: 'Amusement Park',
    3: 'Cultural Cite',
    4: 'Church',
    5: 'Restaurant',
    6: 'Hotel',
    7: 'Local Market',
  };

  try {
    final response = await http.get(uri).timeout(ApiService.requestTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        final List<dynamic> establishments = data['establishments'] ?? [];

        return establishments.map<Map<String, dynamic>>((est) {
          // safely parse establishment_id
          final estIdRaw = est['establishment_id'];
          int estId = 0;
          if (estIdRaw is int) {
            estId = estIdRaw;
          } else if (estIdRaw is String) {
            estId = int.tryParse(estIdRaw) ?? 0;
          }

          // safely parse category
          final categoryId =
              int.tryParse(est['establishmentCategory'].toString()) ?? 0;

          // safely parse ratings
          final userRatingRaw = est['userRating'];
          double userRating = 0.0;
          if (userRatingRaw is int) {
            userRating = userRatingRaw.toDouble();
          } else if (userRatingRaw is double) {
            userRating = userRatingRaw;
          } else if (userRatingRaw is String) {
            userRating = double.tryParse(userRatingRaw) ?? 0.0;
          }

          final recognitionRatingRaw = est['recognitionRating'];
          int recognitionRating = 0;
          if (recognitionRatingRaw is int) {
            recognitionRating = recognitionRatingRaw;
          } else if (recognitionRatingRaw is String) {
            recognitionRating = int.tryParse(recognitionRatingRaw) ?? 0;
          }

          // Parse userRatings (feedbacks) from PHP
          final userRatings = (est['userRatings'] as List<dynamic>? ?? []).map((
            rating,
          ) {
            return {
              'userRatings_id': rating['userRatings_id'] ?? 0,
              'user_id': rating['user_id'] ?? 0,
              'ratingStar': rating['ratingStar'] ?? 0,
              'ratingFeedback': rating['ratingFeedback'] ?? '',
              'dateTime': rating['dateTime'] ?? '',
            };
          }).toList();

          return {
            'establishment_id': estId,
            'establishmentName': est['establishmentName'] ?? '',
            'establishmentCategory': categoryMap[categoryId] ?? 'Unknown',
            'address': est['address'] ?? '',
            'phoneNumber': est['phoneNumber'] ?? '',
            'emailAddress': est['emailAddress'] ?? '',
            'recognitionRating': recognitionRating,
            'userRating': userRating,
            'listingDescription': est['listingDescription'] ?? '',
            'highlightedDescription': est['highlightedDescription'] ?? '',
            'images': (est['images'] as List<dynamic>? ?? []).map((img) {
              return {
                'imageUrl': img['imageUrl'] ?? '',
                'imageDescription': img['imageDescription'] ?? '',
              };
            }).toList(),
            'userRatings': userRatings, // <--- added
          };
        }).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch establishments');
      }
    } else {
      throw Exception("HTTP ${response.statusCode}: ${response.body}");
    }
  } catch (e) {
    throw Exception("Network error: ${e.toString()}");
  }
}

//User Favorites
Future<String> addOrUpdateFavorite({
  required int userId,
  required int establishment_id,
  required int favoriteStatus,
}) async {
  final uri = Uri.parse("${ApiService.baseUrl}addToFavorites.php");

  try {
    final response = await http
        .post(
          uri,
          body: {
            'user_id': userId.toString(),
            'establishment_id': establishment_id.toString(),
            'favoriteStatus': favoriteStatus.toString(),
          },
        )
        .timeout(ApiService.requestTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        return data['message'] ?? 'Action successful';
      } else {
        throw Exception(data['message'] ?? 'Failed to update favorite');
      }
    } else {
      throw Exception("HTTP ${response.statusCode}: ${response.body}");
    }
  } catch (e) {
    throw Exception("Network error: ${e.toString()}");
  }
}

// Fetch all favorited establishments for a specific user
Future<List<int>> fetchUserFavorites(int userId) async {
  final uri = Uri.parse(
    "${ApiService.baseUrl}getUserFavorites.php?user_id=$userId",
  );

  try {
    final response = await http.get(uri).timeout(ApiService.requestTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success'] == true && data['favorites'] != null) {
        // Convert all IDs to int
        return List<int>.from(
          data['favorites'].map((e) => int.parse(e.toString())),
        );
      } else {
        return []; // No favorites found
      }
    } else {
      throw Exception("HTTP ${response.statusCode}: ${response.body}");
    }
  } catch (e) {
    throw Exception("Network error: ${e.toString()}");
  }
}

// Remove a favorite establishment for a specific user
Future<bool> removeUserFavorite(int userId, int establishmentId) async {
  final uri = Uri.parse("${ApiService.baseUrl}removeFavorite.php");

  try {
    final response = await http
        .post(
          uri,
          body: {
            'user_id': userId.toString(),
            'establishment_id': establishmentId.toString(),
          },
        )
        .timeout(ApiService.requestTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return true; // Successfully removed
      } else {
        return false;
      }
    } else {
      throw Exception("HTTP ${response.statusCode}: ${response.body}");
    }
  } catch (e) {
    throw Exception("Network error: ${e.toString()}");
  }
}

// Add Travel Review
Future<Map<String, dynamic>> addTravelReview({
  required int accountId,
  required int establishmentId,
  required double ratingStar,
  required String ratingFeedback,
}) async {
  final uri = Uri.parse("${ApiService.baseUrl}addTravelReview.php");

  try {
    var request = http.MultipartRequest('POST', uri)
      ..fields['accountId'] = accountId.toString()
      ..fields['establishment_id'] = establishmentId.toString()
      ..fields['ratingStar'] = ratingStar.toString()
      ..fields['ratingFeedback'] = ratingFeedback;

    final streamedResponse = await request.send();
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
