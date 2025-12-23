import 'package:csematerials_app/features/ai/widgets/filter_button.dart';
import 'package:csematerials_app/features/ai/widgets/recommendation_card.dart';
import 'package:csematerials_app/features/ai/widgets/stat_box.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AIRecommendationScreen extends StatefulWidget {
  const AIRecommendationScreen({super.key});

  @override
  State<AIRecommendationScreen> createState() => _AIRecommendationScreenState();
}

class _AIRecommendationScreenState extends State<AIRecommendationScreen> {
  List<Map<String, dynamic>> _recommendations = [];
  bool _loading = true;
  String selectedFilter = "For You";

  @override
  void initState() {
    super.initState();
    loadRecommendationsForUser();
  }

  Future<List<Map<String, dynamic>>> getCourseMaterials(
    String bucket,
    String semester,
    String courseCode,
  ) async {
    try {
      final folderPath = '$semester/$courseCode/';
      final response = await Supabase.instance.client.storage
          .from(bucket)
          .list(path: folderPath);

      return response.map((file) {
        // get the public URL for this file
        final publicUrl = Supabase.instance.client.storage
            .from(bucket)
            .getPublicUrl('$folderPath${file.name}');

        return {
          'title': file.name,
          'url': publicUrl,
          'type': bucket == 'slides' ? 'Slides' : 'PYQ',
          'icon': bucket == 'slides'
              ? Icons.slideshow_rounded
              : Icons.question_answer_rounded,
        };
      }).toList();
    } catch (e) {
      print('Error fetching $bucket: $e');
      return [];
    }
  }

  Future<void> loadRecommendationsForUser() async {
    setState(() {
      _loading = true;
    });

    final user = FirebaseAuth.instance.currentUser!;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final level = userDoc['level'];
    final term = userDoc['term'];
    final roman = ["I", "II", "III", "IV"];
    final semesterDoc = "Level-${roman[level - 1]} Term-${roman[term - 1]}";

    final coursesSnapshot = await FirebaseFirestore.instance
        .collection('semesters')
        .doc(semesterDoc)
        .collection('courses')
        .get();

    List<Map<String, dynamic>> recommendations = [];

    for (var courseDoc in coursesSnapshot.docs) {
      final courseData = courseDoc.data();

      // Firestore books
      final booksSnapshot = await courseDoc.reference.collection('books').get();
      for (var bookDoc in booksSnapshot.docs) {
        final bookData = bookDoc.data();
        recommendations.add({
          'title': bookData['title'],
          'course': courseData['courseCode'],
          'courseName': courseData['courseName'] ?? 'Unknown course',
          'semester': semesterDoc,
          'type': bookData['type'] ?? 'Book',
          'description': bookData['description'] ?? '',
          'match': '90%',
          'icon': Icons.menu_book_rounded,
          'pdf_url': bookData['pdf_url'] ?? null,
        });
      }

      // Supabase slides
      final slides = await getCourseMaterials(
        'slides',
        semesterDoc,
        courseData['courseCode'],
      );
      recommendations.addAll(
        slides.map(
          (s) => {
            'title': s['title'],
            'course': courseData['courseCode'],
            'semester': semesterDoc,
            'type': s['type'],
            'description': 'Slides for ${courseData['courseName']}',
            'match': '85%',
            'icon': s['icon'],
            'pdf_url': s['url'],
          },
        ),
      );

      // Supabase previous_year_questions
      final pyqs = await getCourseMaterials(
        'previous_year_questions',
        semesterDoc,
        courseData['courseCode'],
      );
      recommendations.addAll(
        pyqs.map(
          (q) => {
            'title': q['title'],
            'course': courseData['courseCode'],
            'semester': semesterDoc,
            'type': q['type'],
            'description':
                'Previous Year Questions for ${courseData['courseName']}',
            'match': '80%',
            'icon': q['icon'],
            'pdf_url': q['url'],
          },
        ),
      );
    }

    setState(() {
      _recommendations = recommendations;
      _loading = false;
    });
  }

  Future<void> loadTrendingRecommendations() async {
    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final level = userDoc['level'];
      final term = userDoc['term'];
      final roman = ["I", "II", "III", "IV"];
      final semesterId = "Level-${roman[level - 1]} Term-${roman[term - 1]}";

      // Fetch all courses in current semester
      final coursesSnapshot = await FirebaseFirestore.instance
          .collection('semesters')
          .doc(semesterId)
          .collection('courses')
          .get();

      List<Map<String, dynamic>> trending = [];

      for (var courseDoc in coursesSnapshot.docs) {
        final courseData = courseDoc.data();
        final courseCode = courseData['courseCode'];
        final courseName = courseData['courseName'];

        // --- Firestore books ---
        final booksSnapshot = await courseDoc.reference
            .collection('books')
            .get();
        trending.addAll(
          booksSnapshot.docs.map((bookDoc) {
            final bookData = bookDoc.data();
            return {
              'title': bookData['title'],
              'course': courseCode,
              'semester': semesterId,
              'type': 'Book',
              'description': 'Book for $courseName',
              'match': '🔥 Trending',
              'icon': Icons.menu_book_rounded,
              'pdf_url': bookData['pdf_url'] ?? null,
            };
          }),
        );

        // --- Supabase slides ---
        final slides = await Supabase.instance.client.storage
            .from('slides')
            .list(path: '$semesterId/$courseCode/');
        trending.addAll(
          slides.map((file) {
            final url = Supabase.instance.client.storage
                .from('slides')
                .getPublicUrl('$semesterId/$courseCode/${file.name}');
            return {
              'title': file.name,
              'course': courseCode,
              'semester': semesterId,
              'type': 'Slides',
              'description': 'Slides for $courseName',
              'match': '🔥 Trending',
              'icon': Icons.slideshow_rounded,
              'pdf_url': url,
            };
          }),
        );

        // --- Supabase PYQs ---
        final pyqs = await Supabase.instance.client.storage
            .from('previous_year_questions')
            .list(path: '$semesterId/$courseCode/');
        trending.addAll(
          pyqs.map((file) {
            final url = Supabase.instance.client.storage
                .from('previous_year_questions')
                .getPublicUrl('$semesterId/$courseCode/${file.name}');
            return {
              'title': file.name,
              'course': courseCode,
              'semester': semesterId,
              'type': 'PYQ',
              'description': 'Previous Year Questions for $courseName',
              'match': '🔥 Trending',
              'icon': Icons.question_answer_rounded,
              'pdf_url': url,
            };
          }),
        );
      }

      // Shuffle and take top 10
      trending.shuffle();
      setState(() {
        _recommendations = trending.take(10).toList();
      });
    } catch (e) {
      print('Error loading trending: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> loadSmartPicks() async {
    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final level = userDoc['level'];
      final term = userDoc['term'];
      final roman = ["I", "II", "III", "IV"];
      final semesterId = "Level-${roman[level - 1]} Term-${roman[term - 1]}";

      // Fetch all courses in current semester
      final coursesSnapshot = await FirebaseFirestore.instance
          .collection('semesters')
          .doc(semesterId)
          .collection('courses')
          .get();

      List<Map<String, dynamic>> smartPicks = [];

      for (var courseDoc in coursesSnapshot.docs) {
        final courseData = courseDoc.data();
        final courseCode = courseData['courseCode'];
        final courseName = courseData['courseName'];

        // Firestore books
        final booksSnapshot = await courseDoc.reference
            .collection('books')
            .get();
        for (var bookDoc in booksSnapshot.docs) {
          final bookData = bookDoc.data();
          smartPicks.add({
            'title': bookData['title'],
            'course': courseCode,
            'semester': semesterId,
            'type': 'Book',
            'description': 'AI thinks you’ll like this from $courseName',
            'match': '✨ 92%',
            'icon': Icons.menu_book_rounded,
            'pdf_url': bookData['pdf_url'] ?? null,
          });
        }

        // Supabase slides
        final slides = await Supabase.instance.client.storage
            .from('slides')
            .list(path: '$semesterId/$courseCode/');
        if (slides.isNotEmpty) {
          final file = slides.first;
          final url = Supabase.instance.client.storage
              .from('slides')
              .getPublicUrl('$semesterId/$courseCode/${file.name}');
          smartPicks.add({
            'title': file.name,
            'course': courseCode,
            'semester': semesterId,
            'type': 'Slides',
            'description': 'AI thinks you’ll like this slide from $courseName',
            'match': '✨ 92%',
            'icon': Icons.slideshow_rounded,
            'pdf_url': url,
          });
        }

        // Supabase PYQs
        final pyqs = await Supabase.instance.client.storage
            .from('previous_year_questions')
            .list(path: '$semesterId/$courseCode/');
        if (pyqs.isNotEmpty) {
          final file = pyqs.first;
          final url = Supabase.instance.client.storage
              .from('previous_year_questions')
              .getPublicUrl('$semesterId/$courseCode/${file.name}');
          smartPicks.add({
            'title': file.name,
            'course': courseCode,
            'semester': semesterId,
            'type': 'PYQ',
            'description': 'AI thinks you’ll like this PYQ from $courseName',
            'match': '✨ 92%',
            'icon': Icons.question_answer_rounded,
            'pdf_url': url,
          });
        }
      }

      // Shuffle and take top 10
      smartPicks.shuffle();
      setState(() {
        _recommendations = smartPicks.take(10).toList();
      });
    } catch (e) {
      print('Error loading Smart Picks: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 215, 217, 250),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff6a11cb), Color(0xfffbc02d)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 60,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "AI Recommendations",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Powered by machine learning • Personalized for you",
                      style: GoogleFonts.poppins(
                        fontSize: 11.6,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        StatBox(
                          number: '9',
                          label: 'Posted',
                          icon: Icons.upload_rounded,
                        ),
                        StatBox(
                          number: '95%',
                          label: 'Accuracy',
                          icon: Icons.auto_awesome_rounded,
                        ),
                        StatBox(
                          number: '12',
                          label: 'New',
                          icon: Icons.new_releases_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Button
                    ElevatedButton(
                      onPressed: () {
                        loadRecommendationsForUser();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      child: Text(
                        "Refresh Recommendations",
                        style: GoogleFonts.poppins(
                          color: const Color(0xff6a11cb),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Filter bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      FilterButton(
                        label: "For You",
                        selected: selectedFilter == "For You",
                        icon: Icons.recommend_rounded,
                        onTap: () {
                          setState(() {
                            selectedFilter = "For You";
                            loadRecommendationsForUser();
                          });
                        },
                      ),
                      FilterButton(
                        label: "Trending",
                        selected: selectedFilter == "Trending",
                        icon: Icons.trending_up_rounded,
                        onTap: () {
                          setState(() {
                            selectedFilter = "Trending";
                            loadTrendingRecommendations();
                          });
                        },
                      ),
                      FilterButton(
                        label: "Smart Picks",
                        selected: selectedFilter == "Smart Picks",
                        icon: Icons.auto_awesome_rounded,
                        onTap: () {
                          setState(() {
                            selectedFilter = "Smart Picks";
                            loadSmartPicks();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Recommendation Cards
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _recommendations.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Text(
                        "No recommendations found.",
                        style: GoogleFonts.poppins(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    )
                  : Column(
                      children: _recommendations
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: RecommendationCard(
                                title: item['title']!,
                                type: item['type']!,
                                course: item['course']!,
                                semester: item['semester']!,
                                match: item['match']!,
                                description: item['description']!,
                                icon: item['icon'],
                                pdfUrl: item['pdf_url'],
                                courseName:
                                    item['courseName'] ?? 'Unknown Course',
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
