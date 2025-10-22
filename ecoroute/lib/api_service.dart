import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

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
    String? validId, // optional
    File? imageId, // optional
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

      // Only include validId if provided
      if (validId != null && validId.isNotEmpty) {
        request.fields['validId'] = validId;
      }

      // Only include imageId if provided
      if (imageId != null) {
        request.files.add(
          await http.MultipartFile.fromPath('imageId', imageId.path),
        );
      }

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
          'commentCount': post['commentCount'] ?? 0,
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

// Follow a user
Future<String> followUser({
  required int followerId,
  required int followingId,
}) async {
  final uri = Uri.parse("${ApiService.baseUrl}followUser.php");

  try {
    final response = await http
        .post(
          uri,
          body: {
            'follower_id': followerId.toString(),
            'following_id': followingId.toString(),
          },
        )
        .timeout(ApiService.requestTimeout);

    if (response.statusCode == 200) {
      print('Follow response body: ${response.body}');
      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        return 'followed';
      } else {
        throw Exception(data['message'] ?? 'Failed to follow user');
      }
    } else {
      throw Exception("HTTP ${response.statusCode}: ${response.body}");
    }
  } catch (e) {
    throw Exception("Network error: ${e.toString()}");
  }
}

// Unfollow a user
Future<String> unfollowUser({
  required int followerId,
  required int followingId,
}) async {
  final uri = Uri.parse("${ApiService.baseUrl}unfollowUser.php");

  try {
    final response = await http
        .post(
          uri,
          body: {
            'follower_id': followerId.toString(),
            'following_id': followingId.toString(),
          },
        )
        .timeout(ApiService.requestTimeout);

    if (response.statusCode == 200) {
      print('Unfollow response body: ${response.body}');
      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        return 'unfollowed';
      } else {
        throw Exception(data['message'] ?? 'Failed to unfollow user');
      }
    } else {
      throw Exception("HTTP ${response.statusCode}: ${response.body}");
    }
  } catch (e) {
    throw Exception("Network error: ${e.toString()}");
  }
}

// Fetch followers and following
Future<Map<String, List<Map<String, dynamic>>>> fetchFollowersFollowing(
  int userId,
) async {
  final uri = Uri.parse("${ApiService.baseUrl}fetchFollowersFollowing.php");

  try {
    final response = await http
        .post(uri, body: {'user_id': userId.toString()})
        .timeout(ApiService.requestTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        List<Map<String, dynamic>> followers = [];
        List<Map<String, dynamic>> following = [];

        if (data['followers'] != null) {
          followers = List<Map<String, dynamic>>.from(data['followers']);
        }

        if (data['following'] != null) {
          following = List<Map<String, dynamic>>.from(data['following']);
        }

        return {'followers': followers, 'following': following};
      } else {
        throw Exception(
          data['message'] ?? 'Failed to fetch followers/following',
        );
      }
    } else {
      throw Exception("HTTP ${response.statusCode}: ${response.body}");
    }
  } catch (e) {
    throw Exception("Network error: ${e.toString()}");
  }
}

// //Add travel plan
Future<Map<String, dynamic>> addTravelPlanWithDestination({
  required int accountId,
  required String travelTitle,
  required String travelDescription,
  required String travelStartDate,
  required String travelNumDays,
  required String customColor,
  required List<Map<String, dynamic>> destinations,
}) async {
  final uri = Uri.parse(
    "${ApiService.baseUrl}addTravelPlanwithDestination.php",
  );

  try {
    var request = http.MultipartRequest('POST', uri)
      ..fields['accountId'] = accountId.toString()
      ..fields['travelTitle'] = travelTitle
      ..fields['travelDescription'] = travelDescription
      ..fields['travelStartDate'] = travelStartDate
      ..fields['travelNumDays'] = travelNumDays
      ..fields['customColor'] = customColor
      ..fields['destinations'] = jsonEncode(destinations);

    final streamedResponse = await request.send();
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

//fetch Travel plan
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
            'destinations': (plan['destinations'] as List<dynamic>? ?? [])
                .map<Map<String, dynamic>>((dest) {
                  return {
                    'destination_id': dest['destination_id'],
                    'establishment_id': dest['establishment_id'],
                    'destinationTime': dest['destinationTime'],
                    'dayNumber': dest['dayNumber'] ?? 1,
                  };
                })
                .toList(),
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

// Add Group Travel Plan with destinations
Future<Map<String, dynamic>> addGroupTravel({
  required int accountId,
  required String groupTravelTitle,
  required String groupTravelDescription,
  required String groupTravelStartDate,
  required String groupTravelNumDays,
  required List<Map<String, String>> groupTravelMembers,
  required List<Map<String, dynamic>> destinations, // ✅ Added
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
      ..fields['customColor'] = customColor
      ..fields['destinations'] = jsonEncode(destinations);
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
            'destinations': (plan['destinations'] as List<dynamic>? ?? [])
                .map<Map<String, dynamic>>((dest) {
                  return {
                    'destination_id': dest['destination_id'],
                    'establishment_id': dest['establishment_id'],
                    'destinationTime': dest['destinationTime'],
                    'dayNumber': dest['dayNumber'] ?? 1,
                  };
                })
                .toList(),
          };
        }).toList();
      } else if (data['status'] == 'empty') {
        return [];
      } else {
        throw Exception(
          data['message'] ?? 'Failed to fetch group travel plans',
        );
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
// fetch establishments
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

          // safely parse latitude and longitude
          double latitude = double.tryParse(est['latitude'].toString()) ?? 0.0;
          double longitude =
              double.tryParse(est['longitude'].toString()) ?? 0.0;

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
            'latitude': latitude,
            'longitude': longitude,
            'images': (est['images'] as List<dynamic>? ?? []).map((img) {
              return {
                'imageUrl': img['imageUrl'] ?? '',
                'imageDescription': img['imageDescription'] ?? '',
              };
            }).toList(),
            'userRatings': userRatings,
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

//Nearby Add Pin
Future<bool> addNearbyPin({
  required int userId,
  required int establishmentId,
}) async {
  final uri = Uri.parse("${ApiService.baseUrl}addNearbyPin.php");

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

    print("Response: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['status'] == 'success';
    } else {
      throw Exception('HTTP ${response.statusCode}');
    }
  } catch (e) {
    throw Exception("Network error: ${e.toString()}");
  }
}

//Nearby Fetch Pin
Future<Map<String, dynamic>?> fetchLastPinnedLocation(int userId) async {
  final uri = Uri.parse(
    "${ApiService.baseUrl}getLastNearbyPin.php?user_id=$userId",
  );

  try {
    final response = await http.get(uri).timeout(ApiService.requestTimeout);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        // Extract the last pinned establishment
        final lastPin = data['last_pin'];

        // Extract all recommended (nearby) establishments
        final List<dynamic> recommendations = data['recommendations'] ?? [];

        // Combine both into one map for convenience
        return {
          'last_pin': {
            'establishment_id': lastPin['establishment_id'],
            'latitude': lastPin['latitude'],
            'longitude': lastPin['longitude'],
          },
          'recommendations': recommendations.map((item) {
            return {
              'establishment_id': item['establishment_id'],
              'latitude': item['latitude'],
              'longitude': item['longitude'],
              'distance_km': item['distance_km'],
            };
          }).toList(),
        };
      }
    }
    return null;
  } catch (e) {
    print("Error fetching nearby pins: $e");
    return null;
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

//Fetch Most Pinned
Future<List<Map<String, dynamic>>> fetchMostPinned({int limit = 10}) async {
  final uri = Uri.parse("${ApiService.baseUrl}mostPinned.php?limit=$limit");

  try {
    final response = await http.get(uri).timeout(ApiService.requestTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] == 'success' && data['mostPinned'] != null) {
        // Return the list of establishments with pinCount
        return List<Map<String, dynamic>>.from(data['mostPinned']);
      } else {
        return [];
      }
    } else {
      throw Exception("HTTP ${response.statusCode}: ${response.body}");
    }
  } catch (e) {
    throw Exception("Network error: ${e.toString()}");
  }
}

//Fetching of travel routes in maps page
Future<Map<String, dynamic>?> fetchTravelRoute({required int travelId}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final accountId = prefs.getInt('accountId');
    if (accountId == null) return null;

    final url = Uri.parse(
      "${ApiService.baseUrl}fetchTravelRoutes.php?accountId=$accountId",
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        final routes = data['routes'] as List<dynamic>;
        final selected = routes.firstWhere(
          (r) => r['addTravel_id'] == travelId,
          orElse: () => null,
        );

        if (selected != null) {
          // Make sure nested values are converted properly
          for (var day in selected['days']) {
            for (var dest in day['destinations']) {
              dest['latitude'] =
                  double.tryParse(dest['latitude'].toString()) ?? 0.0;
              dest['longitude'] =
                  double.tryParse(dest['longitude'].toString()) ?? 0.0;
              dest['recognitionRating'] =
                  int.tryParse(dest['recognitionRating'].toString()) ?? 0;
              dest['establishmentCategory'] =
                  dest['establishmentCategory'] ?? 'All';
            }
          }
          return selected;
        }
      }
    }
  } catch (e) {
    throw Exception("Error fetching travel route: $e");
  }
  return null;
}

//Google Route

Future<List<gmaps.LatLng>> getGoogleDirections({
  required gmaps.LatLng origin,
  required gmaps.LatLng destination,
  List<String>? waypoints,
}) async {
  const String apiKey = "AIzaSyDDkOZ87G-Zi9aT5PMOoujlfuOY58YErCU";
  final String waypointsParam = waypoints != null && waypoints.isNotEmpty
      ? "&waypoints=${waypoints.join('|')}"
      : "";

  final url =
      "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}$waypointsParam&key=$apiKey";

  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if ((data['routes'] as List).isNotEmpty) {
      final points = data['routes'][0]['overview_polyline']['points'];
      return decodePolyline(points);
    }
  }
  return [];
}

// Decode polyline into LatLng list
List<gmaps.LatLng> decodePolyline(String encoded) {
  List<gmaps.LatLng> polyline = [];
  int index = 0, len = encoded.length;
  int lat = 0, lng = 0;

  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1F) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1F) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;

    polyline.add(gmaps.LatLng(lat / 1e5, lng / 1e5));
  }
  return polyline;
}
