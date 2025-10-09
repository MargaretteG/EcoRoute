import 'package:ecoroute/widgets/bottomPopup.dart';
import 'package:ecoroute/widgets/popup.dart';
import 'package:flutter/material.dart';
import 'package:ecoroute/api_service.dart';

class LeaveFeedbackSection extends StatefulWidget {
  final int accountId; // logged-in user
  final int establishmentId;

  const LeaveFeedbackSection({
    super.key,
    required this.accountId,
    required this.establishmentId,
  });

  @override
  State<LeaveFeedbackSection> createState() => _LeaveFeedbackSectionState();
}

class _LeaveFeedbackSectionState extends State<LeaveFeedbackSection> {
  final TextEditingController _feedbackController = TextEditingController();
  double _starRating = 0.0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_starRating == 0 || _feedbackController.text.isEmpty) {
      showCustomSnackBar(
        context: context,
        icon: Icons.error_outline,
        message: "Please add a rating and feedback.",
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Show pop-up for confirmation
    showDialog(
      context: context,
      builder: (_) => PopUp(
        title: "Submit Feedback",
        headerIcon: Icons.rate_review_rounded,
        description: "Are you sure you want to submit this review?",
        confirmText: "Submit",
        hasTextField: false,
        onConfirm: () async {
          try {
            final result = await addTravelReview(
              accountId: widget.accountId,
              establishmentId: widget.establishmentId,
              ratingStar: _starRating,
              ratingFeedback: _feedbackController.text,
            );

            Navigator.pop(context); // Close pop-up

            if (result['status'] == 'success') {
              showCustomSnackBar(
                context: context,
                icon: Icons.check_circle_outline,
                message: "Feedback submitted successfully!",
              );

              _feedbackController.clear();
              setState(() => _starRating = 0.0);
            } else {
              showCustomSnackBar(
                context: context,
                icon: Icons.error_outline,
                message: result['message'] ?? "Failed to submit feedback",
              );
            }
          } catch (e) {
            showCustomSnackBar(
              context: context,
              icon: Icons.error_outline,
              message: "Error: $e",
            );
          } finally {
            setState(() => _isSubmitting = false);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 235, 235, 235),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 3,
                  blurRadius: 6,
                  offset: const Offset(2, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _feedbackController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Write your feedback here...',
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 10),

                // Star Rating
                Row(
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _starRating = index + 1.0;
                        });
                      },
                      child: Icon(
                        index < _starRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 26,
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 10),

                // Submit button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF011901),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onPressed: _isSubmitting ? null : _submitFeedback,
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text(
                      'Submit',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
