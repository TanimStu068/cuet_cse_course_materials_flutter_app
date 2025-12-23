import 'package:csematerials_app/core/constants/colors.dart';
import 'package:csematerials_app/features/questions/widgets/custom_chip.dart';
import 'package:csematerials_app/features/questions/widgets/glass_search_bar.dart';
import 'package:csematerials_app/features/questions/widgets/question_card.dart';
import 'package:csematerials_app/features/questions/widgets/stat_box.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PreviousQuestionsScreen extends StatefulWidget {
  const PreviousQuestionsScreen({super.key});

  @override
  State<PreviousQuestionsScreen> createState() =>
      _PreviousQuestionsScreenState();
}

class _PreviousQuestionsScreenState extends State<PreviousQuestionsScreen> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  Map<String, Map<String, List<String>>> _data = {};
  Map<String, Map<String, List<String>>> _filteredData = {}; // Filtered view

  String _searchQuery = '';
  String _selectedYear = 'All';
  String _selectedType = 'All Types';
  @override
  void initState() {
    super.initState();
    _loadAllSemesters();
  }

  Future<void> _loadAllSemesters() async {
    try {
      final bucket = 'previous_year_questions';
      final client = Supabase.instance.client;

      Map<String, Map<String, List<String>>> tempData = {};

      // Step 1: Get all semesters
      final semesters = await client.storage.from(bucket).list(path: '');
      print("Current semester : $semesters");
      if (semesters.isEmpty) {
        print('⚠️ No semesters found in Supabase bucket.');
        setState(() => _isLoading = false);
        return;
      }

      for (final sem in semesters) {
        if (sem.name.isEmpty) continue;
        print('📘 Semester: ${sem.name}');
        tempData[sem.name] = {};

        // Step 2: Get all courses for each semester
        final courses = await client.storage.from(bucket).list(path: sem.name);
        for (final course in courses) {
          if (course.name.isEmpty) continue;
          print('   📗 Course: ${course.name}');

          // Step 3: Get all PDFs for each course
          final files = await client.storage
              .from(bucket)
              .list(path: '${sem.name}/${course.name}');

          final pdfFiles = files
              .where((f) => f.name.toLowerCase().endsWith('.pdf'))
              .toList();
          tempData[sem.name]![course.name] = pdfFiles
              .map((f) => f.name)
              .toList();
          for (final file in pdfFiles) {
            if (file.name.endsWith('.pdf')) {
              print('      📄 File: ${file.name}');
            }
          }
        }
      }
      setState(() {
        _data = tempData;
        _filteredData = Map.from(tempData);
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading data: $e');
    }
  }

  Future<void> _openFile(
    String semester,
    String course,
    String fileName,
  ) async {
    final bucket = 'previous_year_questions';
    final filePath = '$semester/$course/$fileName';

    final url = supabase.storage.from(bucket).getPublicUrl(filePath);
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open $url';
    }
  }

  void _filterData() {
    Map<String, Map<String, List<String>>> temp = {};

    _data.forEach((semester, courses) {
      final filteredCourses = <String, List<String>>{};
      courses.forEach((course, files) {
        if (_searchQuery.isNotEmpty &&
            !course.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return;
        }

        final filteredFiles = files.where((file) {
          final lower = file.toLowerCase();

          // Year filter
          final yearMatch = RegExp(r'(19|20)\d{2}').firstMatch(lower);
          final fileYear = yearMatch != null ? yearMatch.group(0) : null;

          // ✅ Year filter
          if (_selectedYear != 'All') {
            if (fileYear == null) return false; // no year in file
            if (fileYear != _selectedYear) return false; // not matching
          }

          // // Type filter
          // Type filter
          if (_selectedType != 'All Types') {
            final type = _selectedType.toLowerCase();
            // Normalize file name: lowercase + remove underscores/spaces
            final normalized = lower.replaceAll(RegExp(r'[\s_]+'), '');

            if (type == 'final' &&
                !(normalized.contains('final') ||
                    normalized.contains('exam'))) {
              return false;
            }

            if (type == 'lab quiz' && !(normalized.contains('quiz'))) {
              return false;
            }

            if (type == 'class test' &&
                !(RegExp(r'ct\d*').hasMatch(normalized) ||
                    normalized.contains('classtest'))) {
              // Matches CT, ct, CT1, ct2, etc.
              return false;
            }

            if (type == 'term' && !normalized.contains('term')) {
              return false;
            }
          }

          return true;
        }).toList();

        if (filteredFiles.isNotEmpty) {
          filteredCourses[course] = filteredFiles;
        }
      });

      if (filteredCourses.isNotEmpty) {
        temp[semester] = filteredCourses;
      }
    });

    setState(() {
      _filteredData = temp;
    });
  }

  void _onSearchChanged(String value) {
    _searchQuery = value;
    _filterData();
  }

  void _onYearSelected(String year) {
    _selectedYear = year;
    _filterData();
  }

  void _onTypeSelected(String type) {
    _selectedType = type;
    _filterData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 215, 217, 250),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: Color(0xFF4A4BB5),
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Previous Year Questions",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(right: 19),
                        child: Text(
                          "Past exam paper & solutions",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color.fromARGB(255, 207, 206, 206),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header section
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(gradient: kMainGradient),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          StatBox(number: '75', label: 'Subjects'),
                          const SizedBox(width: 8),
                          StatBox(number: '8', label: 'Semesters'),
                          const SizedBox(width: 8),
                          StatBox(number: '5.2k', label: 'Downloads'),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    //glass view search bar containing the text "Search by course name or code"
                    Padding(
                      padding: const EdgeInsets.only(right: 11),
                      child: SizedBox(
                        width: 307,
                        child: GlassSearchBar(onChanged: _onSearchChanged),
                      ),
                    ),

                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(Icons.calendar_month, color: Colors.white),
                        const SizedBox(width: 7),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Filter by Year",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          CustomChip(
                            label: "All",
                            selected: _selectedYear == "All",
                            onTap: () => _onYearSelected("All"),
                          ),
                          const SizedBox(width: 7),
                          CustomChip(
                            label: "2022",
                            selected: _selectedYear == "2022",
                            onTap: () => _onYearSelected("2022"),
                          ),
                          const SizedBox(width: 7),
                          CustomChip(
                            label: "2023",
                            selected: _selectedYear == "2023",
                            onTap: () => _onYearSelected("2023"),
                          ),
                          const SizedBox(width: 7),
                          CustomChip(
                            label: "2024",
                            selected: _selectedYear == "2024",
                            onTap: () => _onYearSelected("2024"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.filter_list, color: Colors.white),
                        const SizedBox(width: 7),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Exam Type",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          CustomChip(
                            label: "All Types",
                            selected: _selectedType == "All Types",
                            onTap: () => _onTypeSelected("All Types"),
                          ),
                          const SizedBox(width: 7),
                          CustomChip(
                            label: "Lab Quiz",
                            selected: _selectedType == "Lab Quiz",
                            onTap: () => _onTypeSelected("Lab Quiz"),
                          ),
                          const SizedBox(width: 7),
                          CustomChip(
                            label: "Term",
                            selected: _selectedType == "Term",
                            onTap: () => _onTypeSelected("Term"),
                          ),
                          const SizedBox(width: 7),
                          CustomChip(
                            label: "Class Test",
                            selected: _selectedType == "Class Test",
                            onTap: () => _onTypeSelected("Class Test"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Title: Final Exam
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Exam",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Question cards
              // --- Display Supabase Data Dynamically ---
              _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    )
                  : _filteredData.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("No previous year questions found."),
                    )
                  : ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: _filteredData.entries.expand((semesterEntry) {
                        final semesterName = semesterEntry.key;
                        final courses = semesterEntry.value;

                        return courses.entries.expand((courseEntry) {
                          final courseName = courseEntry.key;
                          final files = courseEntry.value;

                          return files.map((file) {
                            String cleanName = file.replaceAll('.pdf', '');
                            final parts = cleanName.split('_');

                            String type = 'Unknown';
                            String year = '';

                            for (var part in parts) {
                              final p = part.toLowerCase();

                              if (p.contains('ct')) {
                                type = 'Class Test';
                              } else if (p.contains('quiz')) {
                                if (p.contains('lab')) {
                                  type = 'Lab Quiz';
                                } else {
                                  type = 'Quiz';
                                }
                              } else if (p.contains('term')) {
                                type = 'Term';
                              } else if (p.contains('final') ||
                                  p.contains('exam')) {
                                type = 'Final';
                              }

                              // Detect year (e.g., 2023)
                              if (RegExp(r'^(19|20)\d{2}$').hasMatch(p)) {
                                year = p;
                              }
                            }

                            if (year.isEmpty) {
                              final match = RegExp(
                                r'(19|20)\d{2}',
                              ).firstMatch(cleanName);
                              if (match != null) year = match.group(0)!;
                            }

                            final url = supabase.storage
                                .from('previous_year_questions')
                                .getPublicUrl(
                                  '$semesterName/$courseName/$file',
                                );

                            if (url.isEmpty) return const SizedBox.shrink();

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: QuestionCard(
                                title: file.replaceAll('.pdf', ''),
                                course: courseName,
                                semester: semesterName,
                                type: type,
                                date: year,
                                url: url,
                              ),
                            );
                          });
                        });
                      }).toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
