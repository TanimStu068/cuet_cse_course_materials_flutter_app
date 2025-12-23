import 'package:csematerials_app/core/routing/app_routes.dart';
import 'package:csematerials_app/features/webview/webview_screen.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialCard extends StatefulWidget {
  final String title;
  final String type;
  final Color color;
  final String date;
  final String? url;
  final String courseCode;
  final String semesterId;
  final String courseName;

  const MaterialCard({
    super.key,
    required this.title,
    required this.type,
    required this.color,
    required this.date,
    required this.courseCode,
    required this.semesterId,
    required this.courseName,
    this.url,
  });

  @override
  State<MaterialCard> createState() => _MaterialCardState();
}

class _MaterialCardState extends State<MaterialCard> {
  bool isBookmarked = false;
  // 🔹 Common Amazon book link
  static const String amazonBookUrl =
      "https://www.amazon.com/books-used-books-textbooks/b?ie=UTF8&node=283155";

  Future<void> _openUrl(String urlStr) async {
    final uri = Uri.parse(urlStr);
    if (!await canLaunchUrl(uri)) {
      debugPrint('Cannot open url: $urlStr');
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _downloadSlide(
    BuildContext context,
    String fileUrl,
    String fileName,
  ) async {
    try {
      // Request permission (Android)
      if (Platform.isAndroid) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission denied')),
          );
          return;
        }
      }

      // Prepare save directory
      final dir = await getExternalStorageDirectory();
      final savePath = "${dir!.path}/$fileName";

      final dio = Dio();

      // Show SnackBar to indicate start
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Downloading $fileName...")));

      await dio.download(
        fileUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            debugPrint(
              "Download progress: ${(received / total * 100).toStringAsFixed(0)}%",
            );
          }
        },
      );

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

      await userBookmarks.add({
        'title': widget.title,
        'type': widget.type,
        'courseCode': widget.courseCode,
        'courseName': widget.courseName,
        'semester': widget.semesterId,
        'url': widget.url ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() => isBookmarked = true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The material was added to your bookmarks successfully!',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Bookmark error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add to bookmarks')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isBook = widget.type.toLowerCase() == 'book';
    final bool isSlide = widget.type.toLowerCase() == 'slide';

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
            border: Border(top: BorderSide(color: widget.color, width: 4)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isBook
                      ? Icons.menu_book_rounded
                      : Icons.picture_as_pdf_rounded,
                  color: widget.color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: widget.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.type,
                            style: TextStyle(
                              color: widget.color,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.date,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // 🔹 Conditional Buttons
                    Row(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.amber.shade600, // Slide button color
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            if (isBook) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const WebViewScreen(
                                    url: amazonBookUrl,
                                    title: 'Buy Book',
                                  ),
                                ),
                              );
                            } else if (isSlide && widget.url != null) {
                              await _downloadSlide(
                                context,
                                widget.url!,
                                widget.title,
                              );
                            }
                          },
                          icon: Icon(Icons.download_rounded, size: 16),
                          label: const Text(
                            "Download",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 15),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.materialDetails,
                            arguments: {
                              'title': widget.title,
                              'type': widget.type,
                              'courseCode': widget.courseCode,
                              'courseName': widget.courseName,
                              'semester': widget.semesterId,
                              'description': 'Description not provided',
                              'pdfUrl': widget.url,
                            },
                          ),
                          child: Text(
                            "View Details",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff6a11cb),
                            ),
                          ),
                        ),

                        const SizedBox(width: 4),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 4,
          right: 10,
          child: IconButton(
            icon: Icon(
              isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_outline_rounded,
              color: isBookmarked ? Colors.deepPurple : Colors.grey,
            ),
            onPressed: () => _addToBookmarks(context),
          ),
        ),
      ],
    );
  }
}
