import 'dart:async';
import 'package:csematerials_app/features/course/material_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:csematerials_app/core/constants/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final supabase = Supabase.instance.client;
  final firestore = FirebaseFirestore.instance;

  List<String> recentSearches = [];
  List<Map<String, dynamic>> searchResults = [];
  String selectedFilter = "All";
  Timer? _debounce;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  // ✅ Load recent searches from local storage
  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      recentSearches = prefs.getStringList('recent_searches') ?? [];
    });
  }

  // ✅ Save a search to local storage
  Future<void> _saveRecentSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    if (query.isEmpty) return;
    recentSearches.remove(query);
    recentSearches.insert(0, query);
    if (recentSearches.length > 10)
      recentSearches = recentSearches.sublist(0, 10);
    await prefs.setStringList('recent_searches', recentSearches);
    setState(() {});
  }

  // ✅ Debounced live search
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.trim().isEmpty) {
        setState(() => searchResults = []);
        return;
      }
      setState(() => _isLoading = true);
      await _performSearch(query.trim());
      await _saveRecentSearch(query.trim());
      setState(() => _isLoading = false);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    final normalizedQuery = query.replaceAll('-', '').toLowerCase();

    final lowerQuery = query.toLowerCase();
    List<Map<String, dynamic>> results = [];

    // ---- 1️⃣ Firestore: Books under each course ----
    final firestore = FirebaseFirestore.instance;
    final firestoreSnapshot = await firestore.collectionGroup('books').get();

    for (var doc in firestoreSnapshot.docs) {
      final data = doc.data();

      // Book-level
      final bookTitle = (data['title'] ?? '').toString().toLowerCase();
      final bookUrl = data.containsKey('url') ? data['url'] : null;

      // Go two levels up: course document
      final courseRef = doc.reference.parent.parent!;
      final courseSnap = await courseRef.get();
      final courseData = courseSnap.data() as Map<String, dynamic>? ?? {};

      final courseName = (courseData['courseName'] ?? '')
          .toString()
          .toLowerCase();
      final courseCode = (courseData['courseCode'] ?? '')
          .toString()
          .toLowerCase();

      // Match query
      if (bookTitle.contains(lowerQuery) ||
          courseName.contains(lowerQuery) ||
          courseCode.contains(lowerQuery)) {
        results.add({
          'source': 'Firestore',
          'title': data['title'] ?? 'Unknown Book',
          'type': 'Books',
          'url': bookUrl,
          'course': courseData['courseName'] ?? '',
          'courseCode': courseData['courseCode'] ?? '',
        });
      }
    }
    //supabase handle
    for (final bucketName in ['slides', 'previous_year_questions']) {
      final bucket = supabase.storage.from(bucketName);
      final semesters = await bucket.list(path: '');

      for (final semester in semesters) {
        final semesterPath = semester.name;
        final courses = await bucket.list(path: semesterPath);

        for (final course in courses) {
          final courseFolderName = course.name.toLowerCase().replaceAll(
            '-',
            '',
          );

          // ✅ Only include the course if it matches the search query
          if (courseFolderName == normalizedQuery) {
            final files = await bucket.list(
              path: '$semesterPath/${course.name}',
            );

            for (final file in files) {
              if (!file.name.toLowerCase().endsWith('.pdf')) continue;

              results.add({
                'source': 'Supabase',
                'title': file.name.replaceAll('.pdf', ''),
                'type': bucketName == 'slides' ? 'Slides' : 'Questions',
                'url': bucket.getPublicUrl(
                  '$semesterPath/${course.name}/${file.name}',
                ),
                'course': course.name,
                'semester': semesterPath,
              });
            }
          }
        }
      }
    }

    setState(() {
      if (selectedFilter == 'All') {
        searchResults = results;
      } else {
        searchResults = results
            .where(
              (r) =>
                  r['type'].toString().toLowerCase() ==
                  selectedFilter.toLowerCase(),
            )
            .toList();
      }
    });

    print('✅ Found ${results.length} results for "$query"');
    for (var r in results) {
      print(r);
    }
  }

  void _onFilterSelected(String filter) {
    setState(() {
      selectedFilter = filter;
    });
    if (_controller.text.trim().isNotEmpty) {
      _onSearchChanged(_controller.text.trim());
    }
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {
      searchResults = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 215, 217, 250),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(gradient: kMainGradient),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Search Materials",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _controller,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText:
                            'Search by course name, code, or material type',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                        suffixIcon: _controller.text.isNotEmpty
                            ? GestureDetector(
                                onTap: _clearSearch,
                                child: const Icon(
                                  Icons.clear,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Icon(Icons.filter_alt_outlined, color: Colors.white),
                      const SizedBox(width: 7),
                      Text(
                        'Filter by type',
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // Filter chips
                  SizedBox(
                    height: 45,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['All', 'Books', 'Slides']
                            .map(
                              (filter) => GestureDetector(
                                onTap: () => _onFilterSelected(filter),
                                child: Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selectedFilter == filter
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    filter,
                                    style: GoogleFonts.poppins(
                                      color: selectedFilter == filter
                                          ? const Color(0xff8e24aa)
                                          : Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- Search Results ---
            // Inside the Column that contains the search results
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Initial Search Icon + Message ---
                          if (_controller.text.isEmpty)
                            Column(
                              children: [
                                const SizedBox(height: 30),
                                const Icon(
                                  Icons.search,
                                  size: 80,
                                  color: Colors.deepPurple,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Start Your Search",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Find exactly what you need from our materials',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: const Color.fromARGB(
                                      137,
                                      100,
                                      99,
                                      99,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // --- Recent Searches ---
                                if (recentSearches.isNotEmpty)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Recent Searches",
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        children: recentSearches.map((query) {
                                          return GestureDetector(
                                            onTap: () {
                                              _controller.text = query;
                                              _onSearchChanged(query);
                                            },
                                            child: Chip(
                                              label: Text(
                                                query,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                ),
                                              ),
                                              backgroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                side: BorderSide(
                                                  color: Colors.grey.shade300,
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                              ],
                            ),

                          // --- Search Results ---
                          if (_controller.text.isNotEmpty)
                            searchResults.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.search,
                                          size: 80,
                                          color: Colors.deepPurple,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          "No results found",
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          'Find exactly what you need from our materials',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: const Color.fromARGB(
                                              137,
                                              100,
                                              99,
                                              99,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: searchResults.length,
                                    itemBuilder: (context, index) {
                                      final result = searchResults[index];
                                      return SearchResultCard(result: result);
                                    },
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

class SearchResultCard extends StatefulWidget {
  final Map<String, dynamic> result;

  const SearchResultCard({super.key, required this.result});

  @override
  State<SearchResultCard> createState() => _SearchResultCardState();
}

class _SearchResultCardState extends State<SearchResultCard> {
  bool isBookmarked = false;

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'books':
        return Colors.deepPurple;
      case 'slides':
        return Colors.orange;
      case 'questions':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Future<void> _downloadFile(BuildContext context) async {
    final url = widget.result['url'];
    if (url == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No file URL found!')));
      return;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/${widget.result['title']}.pdf';
      final dio = Dio();

      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            debugPrint(
              'Downloading: ${(received / total * 100).toStringAsFixed(0)}%',
            );
          }
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloaded $filePath.pdf'),
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

  Future<void> _viewFile(BuildContext context) async {
    final url = widget.result['url'];
    if (url == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No URL to view!')));
      return;
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cannot open link!')));
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
        'title': widget.result['title'] ?? '',
        'type': widget.result['type'] ?? '',
        'course': widget.result['course'] ?? '',
        'semester': widget.result['semester'] ?? '',
        'url': widget.result['url'] ?? '',
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
    final type = widget.result['type'] ?? 'Unknown';
    final title = widget.result['title'] ?? 'Untitled';
    final course = widget.result['course'] ?? '';
    final semester = widget.result['semester'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TYPE & BOOKMARK ROW ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getTypeColor(type).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      color: _getTypeColor(type),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                    color: isBookmarked ? Colors.deepPurple : Colors.grey,
                  ),
                  onPressed: () => _addToBookmarks(context),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // --- Title ---
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 4),
            Text(
              '$course • $semester',
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
            const SizedBox(height: 10),

            // --- Buttons Row ---
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _downloadFile(context),
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Download', style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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
                          title: widget.result['title'] ?? '',
                          type: widget.result['type'] ?? '',
                          courseCode: widget.result['courseCode'] ?? '',
                          semester: widget.result['semester'] ?? '',
                          description: widget.result['description'] ?? '',
                          pdfUrl: widget.result['url'],
                          courseName: widget.result['course'] ?? '',
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
    );
  }
}
