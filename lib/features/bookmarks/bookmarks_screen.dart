import 'package:csematerials_app/features/bookmarks/widgets/bookmark_card.dart';
import 'package:csematerials_app/features/bookmarks/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<Map<String, dynamic>> bookmarks = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      bookmarks = snapshot.docs
          .map(
            (doc) => {
              'docId': doc.id, // save document id
              ...doc.data(),
            },
          )
          .toList();
    });
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('dd MMM yyyy').format(date); // e.g., "13 Nov 2025"
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 215, 217, 250),
      appBar: AppBar(
        backgroundColor: Color(0xFF4A4BB5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // go back to previous screen
          },
        ),
        title: Text(
          'Bookmarks',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: bookmarks.isEmpty
              ? Center(
                  child: Text(
                    'No bookmarks yet.',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: bookmarks.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // First item is the header
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Header(bookmarksCount: bookmarks.length),
                          const SizedBox(height: 25),
                        ],
                      );
                    }
                    final item = bookmarks[index - 1];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: BookmarkCard(
                        docId: item['docId'],
                        title: item['title'] ?? '',
                        type: item['type'] ?? '',
                        course: item['courseCode'] ?? '',
                        courseName: item['courseName'] ?? '',
                        semester: item['semester'] ?? '',
                        date: item['timestamp'] != null
                            ? _formatDate(item['timestamp'])
                            : '',
                        url: item['url'] ?? '',
                        onDelete: () {
                          setState(() {
                            bookmarks.removeAt(index - 1);
                          });
                        },
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
