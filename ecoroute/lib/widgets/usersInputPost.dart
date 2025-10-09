import 'dart:io';
import 'package:ecoroute/api_service.dart';
import 'package:ecoroute/widgets/bottomPopup.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostInputWidget extends StatefulWidget {
  final String? profilePicUrl;
  final String? userName; 
  final VoidCallback? onPostSubmitted;

  const PostInputWidget({
    Key? key,
    this.profilePicUrl,
    this.userName,
    this.onPostSubmitted,
  }) : super(key: key);

  @override
  State<PostInputWidget> createState() => _PostInputWidgetState();
}

class _PostInputWidgetState extends State<PostInputWidget> {
  final TextEditingController _captionController = TextEditingController();
  final List<File> _selectedImages = [];

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();

    // Pick multiple images
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((xfile) => File(xfile.path)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Title
          const Text(
            "Share your travels",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF011901),
            ),
          ), 
          const SizedBox(height: 10),

          // Profile + TextField + Image Picker
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture
              CircleAvatar(
                radius: 22,
                backgroundImage:
                    widget.profilePicUrl != null &&
                        widget.profilePicUrl!.isNotEmpty
                    ? NetworkImage(widget.profilePicUrl!)
                    : const AssetImage("images/profile_picture.png")
                          as ImageProvider,
              ),
              const SizedBox(width: 10),

              // Caption Field
              Expanded(
                child: TextField(
                  controller: _captionController,
                  minLines: 1,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: "Write a caption...",
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),

              // Image Picker
              IconButton(
                icon: const Icon(
                  Icons.photo_library_outlined,
                  color: Color(0xFF367E3D),
                ),
                onPressed: _pickImages,
              ),
            ],
          ),

          // Selected Images Preview with remove button
          if (_selectedImages.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 70,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImages[index],
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Remove button
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImages.removeAt(index);
                            });
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(78, 0, 0, 0),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Post Button
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_captionController.text.isNotEmpty ||
                    _selectedImages.isNotEmpty)
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _captionController.clear();
                        _selectedImages.clear();
                      });
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ),
                const SizedBox(width: 8),

                // Post Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9616),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.send, size: 16, color: Colors.white),
                  label: const Text(
                    "Post",
                    style: TextStyle(fontSize: 13, color: Colors.white),
                  ),
                  onPressed: () async {
                    // Get accountId from shared preferences
                    final prefs = await SharedPreferences.getInstance();
                    final accountId = prefs.getInt('accountId') ?? 0;

                    if (accountId == 0) {
                      showCustomSnackBar(
                        context: context,
                        icon: Icons.error_outline,
                        message: "User not logged in",
                      );
                      return;
                    }

                    // Convert File objects to temporary URLs or upload them first
                    // For now, assuming you have a function to upload images and get URLs
                    List<String> uploadedImageUrls = [];
                    for (var image in _selectedImages) {
                      try {
                        String imageUrl = await ApiService().uploadPostImage(
                          image,
                        );
                        uploadedImageUrls.add(imageUrl);
                      } catch (e) {
                        debugPrint("Failed to upload image: $e");
                      }
                    }

                    try {
                      final apiService = ApiService();
                      final response = await apiService.submitPost(
                        accountId: accountId,
                        caption: _captionController.text,
                        imageUrls: uploadedImageUrls,
                      );

                      if (response['status'] == 'success') {
                        showCustomSnackBar(
                          context: context,
                          icon: Icons.check_circle_outline,
                          message: "Post submitted!",
                        );

                        setState(() {
                          _captionController.clear();
                          _selectedImages.clear();
                        });
                      } else {
                        showCustomSnackBar(
                          context: context,
                          icon: Icons.error_outline,
                          message:
                              response['message'] ?? "Failed to submit post",
                        );
                      }
                    } catch (e) {
                      showCustomSnackBar(
                        context: context,
                        icon: Icons.error_outline,
                        message: "Error submitting post",
                      );
                      debugPrint("Error: $e");
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
