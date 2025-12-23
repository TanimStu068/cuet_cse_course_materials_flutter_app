import 'package:csematerials_app/features/course/material_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class QuestionCard extends StatefulWidget {
  final String title;
  final String course;
  final String semester;
  final String type;
  final String date;
  final String url;

  const QuestionCard({
    super.key,
    required this.title,
    required this.course,
    required this.semester,
    required this.type,
    required this.date,
    required this.url,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  bool isBookmarked = false;

  Future<void> _downloadFile(String url, String fileName) async {
    try {
      // Request storage permission on Android
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission denied')),
          );
          return;
        }
      }

      // Get a directory to save the file
      final dir = Platform.isAndroid
          ? await getExternalStorageDirectory() // Android
          : await getApplicationDocumentsDirectory(); // iOS

      final filePath = '${dir!.path}/$fileName.pdf';

      // Download the file
      final dio = Dio();
      await dio.download(url, filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloaded $fileName.pdf'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Download error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to download file'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addToBookmarks(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('You must be logged in!')));
      return;
    }

    try {
      final userBookmarks = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('bookmarks');

      // Optional: prevent duplicates
      final existing = await userBookmarks
          .where('title', isEqualTo: widget.title)
          .get();

      if (existing.docs.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Already bookmarked!')));
        return;
      }

      await userBookmarks.add({
        'title': widget.title,
        'type': widget.type,
        'course': widget.course,
        'semester': widget.semester,
        'url': widget.url,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() => isBookmarked = true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The question was added to your bookmarks!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Download error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to download file'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type and Course
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffede7f6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.type,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff6a11cb),
                      ),
                    ),
                  ),
                  Text(
                    widget.date,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Title
              Text(
                widget.title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${widget.course} • Semester ${widget.semester}",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),

              // Download button
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.download, size: 16),

                    onPressed: () {
                      _downloadFile(widget.url, widget.title);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xfffbc02d),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                    ),
                    label: Text(
                      "Download",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MaterialDetailScreen(
                            title: widget.title,
                            type: widget.type,
                            courseCode: widget.course,
                            semester: widget.semester,
                            description: "No Description provided",
                            pdfUrl: widget.url,
                            courseName: widget.course,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.remove_red_eye, size: 16),
                    label: const Text(
                      "View Details",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 8,
          right: 50,
          child: GestureDetector(
            onTap: () => _addToBookmarks(context),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_outline_rounded,
                color: isBookmarked ? Colors.deepPurple : Colors.grey,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
