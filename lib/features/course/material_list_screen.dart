import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csematerials_app/features/course/widgets/course_stats_row.dart';
import 'package:csematerials_app/features/course/widgets/header_section.dart';
import 'package:csematerials_app/features/course/widgets/material_card.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MaterialListScreen extends StatefulWidget {
  final String semesterId;
  final String courseCode;

  const MaterialListScreen({
    super.key,
    required this.semesterId,
    required this.courseCode,
  });

  @override
  State<MaterialListScreen> createState() => _MaterialListScreenState();
}

class _MaterialListScreenState extends State<MaterialListScreen> {
  String selectedFilter = "All";
  String searchQuery = "";

  void _updateFilter(String newFilter) {
    setState(() {
      selectedFilter = newFilter;
    });
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final semesterId = args['semesterId'];
    final courseCode = args['courseCode'];
    final courseTitle = args['courseTitle'];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 215, 217, 250),
      body: SafeArea(
        child: Column(
          children: [
            HeaderSection(
              courseCode: courseCode,
              courseName: courseTitle,
              selectedFilter: selectedFilter,
              onFilterSelected: _updateFilter,
              onSearchChanged: (query) {
                setState(() {
                  searchQuery = query.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('semesters')
                  .doc(semesterId)
                  .collection('courses')
                  .doc(courseCode)
                  .collection('books')
                  .snapshots(),
              builder: (context, bookSnapshot) {
                final bookCount = bookSnapshot.data?.docs.length ?? 0;

                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchSlidesFromSupabase(semesterId, courseCode),
                  builder: (context, slideSnapshot) {
                    final slideCount = slideSnapshot.data?.length ?? 0;
                    final totalCount = bookCount + slideCount;

                    return Column(
                      children: [
                        CourseStatsRow(
                          materialsCount: totalCount,
                          views: '1.2k',
                          downloads: 847,
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 12),

            // 🔹 Firestore + Supabase Combined List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('semesters')
                    .doc(semesterId)
                    .collection('courses')
                    .doc(courseCode)
                    .collection('books')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final books = snapshot.data?.docs ?? [];

                  return FutureBuilder<List<Map<String, dynamic>>>(
                    // 👇 Fetch slides from Supabase Storage
                    future: _fetchSlidesFromSupabase(semesterId, courseCode),
                    builder: (context, slideSnapshot) {
                      if (slideSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final slides = slideSnapshot.data ?? [];

                      // Combine both lists
                      final allMaterials = [
                        ...books.map(
                          (doc) => {
                            'title':
                                (doc.data() as Map<String, dynamic>)['title'],
                            'type': 'Book',
                            'color': const Color(0xff5b2cff),
                          },
                        ),
                        ...slides.map(
                          (s) => {
                            'title': s['name'],
                            'type': 'Slide',
                            'color': const Color(0xff009688),
                            'url': s['url'],
                          },
                        ),
                      ];

                      // 🔹 Apply filter
                      final filteredMaterials = selectedFilter == "All"
                          ? allMaterials
                          : allMaterials
                                .where((m) => m['type'] == selectedFilter)
                                .toList();
                      final searchedMaterials = filteredMaterials.where((m) {
                        final title = (m['title'] ?? '')
                            .toString()
                            .toLowerCase();
                        return title.contains(searchQuery);
                      }).toList();

                      if (allMaterials.isEmpty) {
                        return const Center(child: Text("No materials found."));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: searchedMaterials.length,
                        itemBuilder: (context, index) {
                          final data = searchedMaterials[index];
                          final isSlide = (data['type'] ?? '') == 'Slide';
                          return MaterialCard(
                            title: data['title'] ?? 'Untitled',
                            type: data['type'] ?? 'Unknown',
                            color: data['color'] ?? Colors.grey,
                            date: "Added recently",
                            url: isSlide ? data['url'] as String? : null,
                            courseCode: courseCode,
                            semesterId: semesterId,
                            courseName: courseTitle,
                          );
                        },
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
}

Future<List<Map<String, dynamic>>> _fetchSlidesFromSupabase(
  String semesterName,
  String courseCode,
) async {
  try {
    final supabase = Supabase.instance.client;

    final path = "$semesterName/$courseCode";

    debugPrint("📦 Fetching slides from: $path");

    final response = await supabase.storage.from('slides').list(path: path);

    final files = response.map((file) {
      final url = supabase.storage
          .from('slides')
          .getPublicUrl('$path/${file.name}');
      return {'name': file.name, 'url': url};
    }).toList();

    debugPrint("✅ Found ${files.length} slides in $path");
    return files;
  } catch (e, stack) {
    debugPrint("❌ Error fetching slides: $e");
    debugPrint("$stack");
    return [];
  }
}
