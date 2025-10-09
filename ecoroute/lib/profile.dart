import 'package:ecoroute/api_service.dart';
import 'package:ecoroute/community/userProfilePosts.dart';
import 'package:ecoroute/editProfile.dart';
import 'package:ecoroute/widgets/usersInputPost.dart';
import 'package:flutter/material.dart';
import 'package:ecoroute/widgets/customHeaderHome.dart';
import 'package:ecoroute/widgets/bottomNavBar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const Profile({super.key, this.userData});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final GlobalKey<UserProfilePostsState> _postsKey = GlobalKey();
  void _reloadPosts() {
    _postsKey.currentState?.loadUserPosts();
  }

  void _safeSetState(VoidCallback fn) {
    if (mounted) { 
      setState(fn);
    }
  }

  int _currentIndex = 4;
  final _apiService = ApiService();

  Map<String, dynamic>? _user;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accountId = prefs.getInt("accountId");
      if (accountId == null) {
        throw Exception("No accountId saved inn preferences");
      }

      final userData = await _apiService.fetchProfile(accountId: accountId);

      _safeSetState(() {
        _user = userData;
        _loading = false;
      });
    } catch (e) {
      _safeSetState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      backgroundColor: const Color(0xFF011901),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Text(
                  "Error: $_error",
                  style: TextStyle(color: Colors.white),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(80),
                              bottomRight: Radius.circular(80),
                            ),
                          ),
                          child: Column(
                            children: [
                              SearchHeader(
                                showSearch: false,
                                iconColor: Colors.black,
                                logoPath: 'images/logo-dark-green.png',
                                showProfile: false,
                                logout: true,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 5,
                                ),
                                child: Divider(
                                  color: Color(0xFF011901),
                                  thickness: 0.5,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 20,
                                  right: 20,
                                  top: 5,
                                  bottom: 15,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle, 
                                        border: Border.all(
                                          color: Colors.green,
                                          width: 2,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: 45,
                                        backgroundImage:
                                            (_user != null &&
                                                _user!['profilePic'] != null &&
                                                _user!['profilePic']
                                                    .toString()
                                                    .isNotEmpty)
                                            ? NetworkImage(
                                                "https://ecoroute-taal.online/uploads/profile_pics/${_user!['profilePic']}",
                                              )
                                            : const AssetImage(
                                                    'images/profile_picture.png',
                                                  )
                                                  as ImageProvider,
                                      ),
                                    ),

                                    const SizedBox(height: 10),
                                    Text(
                                      _user?['userName'] ?? 'Unknown',
                                      style: const TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF011901),
                                      ),
                                    ),
                                    Transform.translate(
                                      offset: const Offset(0, -7),
                                      child: Text(
                                        _user?['email'] ?? 'No email',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF011901),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              '20',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF011901),
                                              ),
                                            ),
                                            Text('Followers'),
                                          ],
                                        ),
                                        SizedBox(width: 15),

                                        // Vertical Divider
                                        Container(
                                          height: 30,
                                          width: 1,
                                          color: Colors.grey,
                                        ),

                                        SizedBox(width: 15),
                                        Column(
                                          children: [
                                            Text(
                                              '50',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF011901),
                                              ),
                                            ),
                                            Text('Following'),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 15),
                                    // Transform.translate(
                                    //   offset: Offset(0, 35),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFFF9616,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        if (_user != null) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditProfile(userData: _user!),
                                            ),
                                          ).then((_) {
                                            //
                                            _loadProfile();
                                          });
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "User data not loaded yet",
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 8,
                                        ),
                                        child: Text(
                                          'Edit Profile',
                                          style: TextStyle(
                                            color: Color(0xFF011901),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Post Input Box
                    PostInputWidget(
                      profilePicUrl: _user?['profilePic'] != null
                          ? "https://ecoroute-taal.online/uploads/profile_pics/${_user!['profilePic']}"
                          : null,
                      userName: _user?['userName'],
                      onPostSubmitted: _reloadPosts, 
                    ),
                    UserProfilePosts(
                      username: _user?['userName'] ?? "Unknown",
                      profilePicUrl: _user?['profilePic'] != null
                          ? "https://ecoroute-taal.online/uploads/profile_pics/${_user!['profilePic']}"
                          : "https://via.placeholder.com/150",
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
