import 'package:csematerials_app/core/constants/colors.dart';
import 'package:csematerials_app/features/course/widgets/info_tile.dart';
import 'package:csematerials_app/features/course/widgets/stat_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MaterialDetailScreen extends StatelessWidget {
  final String title;
  final String type;
  final String courseCode;
  final String semester;
  final String description;
  final String? pdfUrl;
  final String courseName;

  const MaterialDetailScreen({
    super.key,
    required this.title,
    required this.type,
    required this.courseCode,
    required this.semester,
    required this.description,
    required this.pdfUrl,
    required this.courseName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xfff8f8f8),
      //backgroundColor: const Color.fromARGB(255, 251, 250, 250),
      backgroundColor: Color.fromARGB(255, 215, 217, 250),

      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 25),
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: kMainGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Top Row: Back + Title + Share
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      Text(
                        "Material Details",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.share_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // Material Icon Section
                  Column(
                    children: [
                      Container(
                        height: 60,
                        width: 70,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.description_outlined,
                          color: Colors.white,
                          size: 45,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          type,
                          style: GoogleFonts.poppins(
                            color: const Color(0xff8e24aa),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "PDF Document",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Course chip and semester
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            courseCode,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          semester,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        StatItem(
                          icon: Icons.visibility_outlined,
                          value: "2.4k",
                          label: "Views",
                        ),
                        StatItem(
                          icon: Icons.download_outlined,
                          value: "1.8k",
                          label: "Downloads",
                        ),
                        StatItem(
                          icon: Icons.star_border_rounded,
                          value: "4.8",
                          label: "Rating",
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // Course Name
                    InfoTile(
                      icon: Icons.book_outlined,
                      title: "Course Name",
                      value: courseName,
                      color: const Color(0xffe8eaff),
                    ),
                    const SizedBox(height: 12),

                    // Upload Date
                    InfoTile(
                      icon: Icons.date_range_outlined,
                      title: "Upload Date",
                      value: "February 10, 2025",
                      color: const Color(0xffffe0e0),
                    ),
                    const SizedBox(height: 12),

                    // Last Updated
                    InfoTile(
                      icon: Icons.update_outlined,
                      title: "Last Updated",
                      value: "2 days ago",
                      color: const Color(0xffe7ffe6),
                    ),
                    const SizedBox(height: 12),

                    // Description
                    Container(
                      padding: const EdgeInsets.all(15),
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
                    ),
                    const SizedBox(height: 20),

                    // Buttons Row
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (type.toLowerCase() == 'book') {
                                // Open Amazon link in-app
                                final bookQuery = Uri.encodeComponent(title);
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
                                if (pdfUrl != null) {
                                  try {
                                    final dio = Dio();
                                    final dir =
                                        await getApplicationDocumentsDirectory();
                                    final filePath =
                                        '${dir.path}/${courseCode}_$title.pdf';

                                    await dio.download(pdfUrl!, filePath);

                                    // ScaffoldMessenger.of(context).showSnackBar(
                                    //   SnackBar(
                                    //     content: Text(
                                    //       'Downloaded to $filePath',
                                    //     ),
                                    //   ),
                                    // );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        behavior: SnackBarBehavior.floating,
                                        elevation: 0,
                                        backgroundColor: Colors
                                            .transparent, // removes black background
                                        content: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors
                                                .white, // your new background
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 6,
                                                offset: Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: const Text(
                                            'Successfully downloaded file',
                                            style: TextStyle(
                                              color: Colors.green, // text color
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    // ScaffoldMessenger.of(context).showSnackBar(
                                    //   const SnackBar(
                                    //     content: Text('Download failed'),
                                    //   ),
                                    // );

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        behavior: SnackBarBehavior.floating,
                                        elevation: 0,
                                        backgroundColor: Colors
                                            .transparent, // removes default black bg
                                        content: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors
                                                .white, // background for the message box
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 6,
                                                offset: Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            'Download failed',
                                            style: const TextStyle(
                                              color: Colors
                                                  .red, // red text for errors
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            icon: const Icon(
                              Icons.download_rounded,
                              color: Colors.white,
                            ),
                            label: Text(
                              "Download",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF4A4BB5),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              try {
                                final user = FirebaseAuth.instance.currentUser;

                                if (user == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'You must be logged in to save materials',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final bookmarkRef = FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .collection('bookmarks')
                                    .doc(); // auto ID for each bookmark

                                await bookmarkRef.set({
                                  'title': title,
                                  'type': type,
                                  'course': courseCode,
                                  'semester': semester,
                                  'description': description,
                                  'pdfUrl': pdfUrl,
                                  'savedAt': FieldValue.serverTimestamp(),
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    elevation: 0,
                                    backgroundColor: Colors
                                        .transparent, // removes black background
                                    content: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white, // your new background
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 6,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: const Text(
                                        'Material saved successfully to bookmarks',
                                        style: TextStyle(
                                          color: Colors.green, // text color
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    elevation: 0,
                                    backgroundColor: Colors
                                        .transparent, // removes default black bg
                                    content: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors
                                            .white, // background for the message box
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 6,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        'Failed to save material: $e',
                                        style: const TextStyle(
                                          color:
                                              Colors.red, // red text for errors
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.bookmark_border_rounded),
                            label: Text(
                              "Save",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // Similar Materials
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xfff3e8ff),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Similar Materials",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Check out 12 related materials in this course",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
