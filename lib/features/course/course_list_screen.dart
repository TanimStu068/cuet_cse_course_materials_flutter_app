import 'package:csematerials_app/core/constants/colors.dart';
import 'package:csematerials_app/core/routing/app_routes.dart';
import 'package:csematerials_app/features/course/widgets/course_card.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseListScreen extends StatefulWidget {
  final String semesterId;

  const CourseListScreen({super.key, required this.semesterId});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  Future<Map<String, int>> _getSemesterStats(String semesterId) async {
    final firestore = FirebaseFirestore.instance;
    final coursesSnapshot = await firestore
        .collection('semesters')
        .doc(semesterId)
        .collection('courses')
        .get();

    int courses = coursesSnapshot.size;
    int materials = 0;

    for (var doc in coursesSnapshot.docs) {
      final courseCode = doc['courseCode'] ?? '';
      final booksSnapshot = await firestore
          .collection('semesters')
          .doc(semesterId)
          .collection('courses')
          .doc(courseCode)
          .collection('books')
          .get();
      materials += booksSnapshot.size;
    }

    return {
      'courses': courses,
      'materials': materials,
      'new': 0, // (Optional — you can track “isNew” field later)
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xfff4f2f7),
      backgroundColor: Color.fromARGB(255, 215, 217, 250),

      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Top Header Section
            Container(
              decoration: const BoxDecoration(
                gradient: kMainGradient,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(25),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back + Title + Search Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          "🎓 ${widget.semesterId}",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.search);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('semesters')
                        .doc(widget.semesterId)
                        .collection('courses')
                        .snapshots(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.docs.length ?? 0;
                      return Text(
                        "$count courses available",
                        style: const TextStyle(color: Colors.white70),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Info Boxes Row
                  FutureBuilder<Map<String, int>>(
                    future: _getSemesterStats(widget.semesterId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _infoBox("Courses", "...", LucideIcons.bookOpen),
                            _infoBox("Materials", "...", LucideIcons.folder),
                            _infoBox("New", "...", LucideIcons.sparkles),
                          ],
                        );
                      }

                      final stats = snapshot.data!;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _infoBox(
                            "Courses",
                            "${stats['courses']}",
                            LucideIcons.bookOpen,
                          ),
                          _infoBox(
                            "Materials",
                            "${stats['materials']}",
                            LucideIcons.folder,
                          ),
                          _infoBox("New", "7", LucideIcons.sparkles),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),

            // 🔹 “Choose a course” Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const Text(
                "Choose a course below",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 19),
              ),
            ),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('semesters')
                    .doc(widget.semesterId)
                    .collection('courses')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No courses found"));
                  }

                  final courses = snapshot.data!.docs;

                  // 🔹 Always show linear ListView
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course =
                          courses[index].data() as Map<String, dynamic>;
                      return CourseCard(
                        semesterId: widget.semesterId,
                        code: course['courseCode'] ?? '',
                        title: course['courseName'] ?? '',
                        type: course['type'] ?? '',
                        icon: Icons.book_rounded,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // small info box widget
  static Widget _infoBox(String title, String value, IconData icon) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
