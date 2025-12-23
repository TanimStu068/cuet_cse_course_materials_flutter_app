// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:dio/dio.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class SearchResultCard extends StatefulWidget {
//   final Map<String, dynamic> result;

//   const SearchResultCard({super.key, required this.result});

//   @override
//   State<SearchResultCard> createState() => _SearchResultCardState();
// }

// class _SearchResultCardState extends State<SearchResultCard> {
//   bool isBookmarked = false;

//   Color _getTypeColor(String type) {
//     switch (type.toLowerCase()) {
//       case 'books':
//         return Colors.deepPurple;
//       case 'slides':
//         return Colors.orange;
//       case 'questions':
//         return Colors.blue;
//       default:
//         return Colors.grey;
//     }
//   }

//   Future<void> _downloadFile(BuildContext context) async {
//     final url = widget.result['url'];
//     if (url == null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('No file URL found!')));
//       return;
//     }

//     try {
//       final dir = await getApplicationDocumentsDirectory();
//       final filePath = '${dir.path}/${widget.result['title']}.pdf';
//       final dio = Dio();

//       await dio.download(
//         url,
//         filePath,
//         onReceiveProgress: (received, total) {
//           if (total != -1) {
//             debugPrint(
//               'Downloading: ${(received / total * 100).toStringAsFixed(0)}%',
//             );
//           }
//         },
//       );

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Downloaded $filePath.pdf'),
//           behavior: SnackBarBehavior.floating,
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       debugPrint('Download error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Failed to download file'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Future<void> _viewFile(BuildContext context) async {
//     final url = widget.result['url'];
//     if (url == null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('No URL to view!')));
//       return;
//     }

//     final uri = Uri.parse(url);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri, mode: LaunchMode.inAppWebView);
//     } else {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Cannot open link!')));
//     }
//   }

//   Future<void> _addToBookmarks(BuildContext context) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('You must be logged in!')));
//       return;
//     }

//     try {
//       final userBookmarks = FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .collection('bookmarks');

//       await userBookmarks.add({
//         'title': widget.result['title'] ?? '',
//         'type': widget.result['type'] ?? '',
//         'course': widget.result['course'] ?? '',
//         'semester': widget.result['semester'] ?? '',
//         'url': widget.result['url'] ?? '',
//         'timestamp': FieldValue.serverTimestamp(),
//       });

//       setState(() => isBookmarked = true);

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'The material was added to your bookmarks successfully!',
//           ),
//           behavior: SnackBarBehavior.floating,
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       debugPrint('Bookmark error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to add to bookmarks')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final type = widget.result['type'] ?? 'Unknown';
//     final title = widget.result['title'] ?? 'Untitled';
//     final course = widget.result['course'] ?? '';
//     final semester = widget.result['semester'] ?? '';

//     return Card(
//       margin: const EdgeInsets.only(bottom: 10),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // --- TYPE & BOOKMARK ROW ---
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 10,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: _getTypeColor(type).withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     type,
//                     style: TextStyle(
//                       color: _getTypeColor(type),
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(
//                     isBookmarked
//                         ? Icons.bookmark_rounded
//                         : Icons.bookmark_outline_rounded,
//                     color: isBookmarked ? Colors.deepPurple : Colors.grey,
//                   ),
//                   onPressed: () => _addToBookmarks(context),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 8),

//             // --- Title ---
//             Text(
//               title,
//               style: GoogleFonts.poppins(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//               ),
//             ),

//             const SizedBox(height: 4),
//             Text(
//               '$course • $semester',
//               style: TextStyle(color: Colors.grey[700], fontSize: 13),
//             ),
//             const SizedBox(height: 10),

//             // --- Buttons Row ---
//             Row(
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: () => _downloadFile(context),
//                   icon: const Icon(Icons.download, size: 16),
//                   label: const Text('Download', style: TextStyle(fontSize: 13)),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orange,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 14,
//                       vertical: 8,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 TextButton.icon(
//                   onPressed: () {

//                   },
//                   icon: const Icon(Icons.remove_red_eye, size: 16),
//                   label: const Text(
//                     "View",
//                     style: TextStyle(fontWeight: FontWeight.w600),
//                   ),
//                   style: TextButton.styleFrom(
//                     foregroundColor: Colors.blueAccent,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
