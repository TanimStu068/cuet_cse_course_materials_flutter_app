import 'package:csematerials_app/features/course/material_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class RecommendationCard extends StatefulWidget {
  final String title;
  final String type;
  final String course;
  final String semester;
  final String match;
  final String description;
  final IconData icon;
  final String? pdfUrl;
  final String courseName;

  const RecommendationCard({
    super.key,
    required this.title,
    required this.type,
    required this.course,
    required this.semester,
    required this.match,
    required this.description,
    required this.icon,
    required this.courseName,
    this.pdfUrl,
  });

  @override
  State<RecommendationCard> createState() => _RecommendationCardState();
}

class _RecommendationCardState extends State<RecommendationCard> {
  bool isBookmarked = false;

  Color _typeColor() {
    switch (widget.type) {
      case 'Book':
        return Colors.orange.shade100;
      case 'Slides':
        return Colors.purple.shade100;
      case 'Notes':
        return Colors.green.shade100;
      case 'Lab':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade200;
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
        'course': widget.course,
        'semester': widget.semester,
        'url': widget.pdfUrl,
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
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 30,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 222, 194, 251),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.auto_awesome_rounded, size: 15),
                            const SizedBox(width: 4),
                            Text(
                              'AI pick',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 80,
                        height: 30,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _typeColor(),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(widget.icon, size: 15),
                            const SizedBox(width: 4),
                            Text(
                              widget.type,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      //const SizedBox(width: 6),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        widget.match,
                        style: GoogleFonts.poppins(
                          color: const Color(0xff6a11cb),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const Icon(
                        Icons.star,
                        color: Color(0xfffbc02d),
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              //second row
              Row(
                children: [
                  Text(
                    widget.course,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Sem ${widget.semester}",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),

              Text(
                widget.title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                widget.description,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 7),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (widget.type.toLowerCase() == 'book') {
                        // Open Amazon link in-app
                        final bookQuery = Uri.encodeComponent(widget.title);
                        final amazonUrl =
                            'https://www.amazon.com/s?k=$bookQuery';
                        final Uri uri = Uri.parse(amazonUrl);

                        if (!await launchUrl(
                          uri,
                          mode: LaunchMode.inAppWebView,
                        )) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cannot open Amazon link'),
                            ),
                          );
                        }
                      } else {
                        // Download slides / PYQ
                        if (widget.pdfUrl != null) {
                          try {
                            final dio = Dio();
                            final dir =
                                await getApplicationDocumentsDirectory();
                            final filePath =
                                '${dir.path}/${widget.course}_${widget.title}.pdf';

                            await dio.download(widget.pdfUrl!, filePath);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'The question was added to your bookmarks!',
                                ),
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
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff6a11cb),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    child: Text(
                      "Download",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MaterialDetailScreen(
                            title: widget.title,
                            type: widget.type,
                            courseCode: widget.course,
                            semester: widget.semester,
                            description: widget.description,
                            pdfUrl: widget.pdfUrl,
                            courseName: widget.courseName,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "View Details",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff6a11cb),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 4,
          right: 105,
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
