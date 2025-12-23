import 'dart:io';
import 'package:csematerials_app/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _courseCodeController = TextEditingController();
  final _courseNameController = TextEditingController();

  String? _selectedType;
  String? _selectedSemester;
  File? _selectedFile;
  bool _isUploading = false;

  final List<String> semesters = [
    "Level-I Term-I",
    "Level-I Term-II",
    "Level-II Term-I",
    "Level-II Term-II",
    "Level-III Term-I",
    "Level-III Term-II",
    "Level-IV Term-I",
    "Level-IV Term-II",
  ];

  final List<String> materialTypes = ["Slide", "Book", "Question"];
  final supabase = Supabase.instance.client;
  final firestore = FirebaseFirestore.instance;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _selectedFile = File(result.files.single.path!));
    }
  }

  Future<void> _uploadMaterial() async {
    if (_selectedFile == null ||
        _selectedType == null ||
        _selectedSemester == null ||
        _courseCodeController.text.isEmpty ||
        _courseNameController.text.isEmpty ||
        _titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields and select file."),
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final bucketName = _selectedType == "Question"
          ? "previous_year_questions"
          : "slides";
      final fileName = _selectedFile!.path.split('/').last;
      final path =
          "${_selectedSemester}/${_courseCodeController.text}/$fileName";

      await supabase.storage.from(bucketName).upload(path, _selectedFile!);
      final publicUrl = supabase.storage.from(bucketName).getPublicUrl(path);

      await firestore.collection('materials').add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'type': _selectedType,
        'semester': _selectedSemester,
        'courseCode': _courseCodeController.text.trim(),
        'courseName': _courseNameController.text.trim(),
        'url': publicUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Upload successful!")));

      setState(() {
        _selectedFile = null;
        _isUploading = false;
        _titleController.clear();
        _descriptionController.clear();
        _courseCodeController.clear();
        _courseNameController.clear();
        _selectedType = null;
        _selectedSemester = null;
      });
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Upload failed: $e")));
    }
  }

  Future<void> _deleteMaterial(
    String docId,
    String fileUrl,
    String type,
  ) async {
    try {
      final bucketName = type == "Question"
          ? "previous_year_questions"
          : "slides";
      final filePath = fileUrl.split("$bucketName/").last;
      await supabase.storage.from(bucketName).remove([filePath]);
      await firestore.collection('materials').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Material deleted successfully.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Delete failed: $e")));
    }
  }

  InputDecoration myInputDecoration() {
    return InputDecoration(
      // No floating label
      floatingLabelBehavior: FloatingLabelBehavior.never,

      filled: true,
      fillColor: Colors.white,

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.indigo, width: 1.6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFF6F8FB),
      backgroundColor: Color.fromARGB(255, 215, 217, 250),

      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text("Admin Panel", style: TextStyle(color: Colors.white)),
        elevation: 2,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: kMainGradient),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Upload Material Card
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: kMainGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            "📤 Upload New Material",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.only(right: 190),
                        child: Text(
                          'Material Title',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _titleController,
                        decoration: myInputDecoration(),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(right: 125),
                        child: Text(
                          'Description (optional)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _descriptionController,
                        decoration: myInputDecoration(),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(right: 83),
                        child: Text(
                          'Course Code (e.g. CSE-100)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _courseCodeController,
                        decoration: myInputDecoration(),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(right: 183),
                        child: Text(
                          'Course Name',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _courseNameController,
                        decoration: myInputDecoration(),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        isExpanded: true,
                        hint: const Text("Select Type"),
                        items: materialTypes
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(
                                  type,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedType = v),
                        decoration: myInputDecoration(),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedSemester,
                        isExpanded: true,
                        hint: const Text("Select Semester"),
                        items: semesters
                            .map(
                              (sem) => DropdownMenuItem(
                                value: sem,
                                child: Text(
                                  sem,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedSemester = v),
                        decoration: myInputDecoration(),
                      ),

                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.attach_file),
                        label: Text(
                          _selectedFile == null
                              ? "Select PDF File"
                              : "Selected: ${_selectedFile!.path.split('/').last}",
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A4BB5),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isUploading ? null : _uploadMaterial,
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text("Upload Material"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC89700),
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Uploaded Materials Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          "📚 Uploaded Materials",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF2E3192),
                          ),
                        ),
                        const SizedBox(height: 12),
                        StreamBuilder<QuerySnapshot>(
                          stream: firestore
                              .collection('materials')
                              .orderBy('timestamp', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            final docs = snapshot.data!.docs;
                            if (docs.isEmpty) {
                              return const Text("No materials uploaded yet.");
                            }
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: docs.length,
                              itemBuilder: (context, index) {
                                final data =
                                    docs[index].data() as Map<String, dynamic>;
                                final docId = docs[index].id;
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 4,
                                  ),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.picture_as_pdf,
                                      color: Colors.redAccent,
                                    ),
                                    title: Text(
                                      data['title'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "${data['type']} • ${data['courseCode']} • ${data['semester']}",
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _deleteMaterial(
                                        docId,
                                        data['url'],
                                        data['type'],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_isUploading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
