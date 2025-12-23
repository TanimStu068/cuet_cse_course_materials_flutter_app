import 'package:csematerials_app/core/constants/colors.dart';
import 'package:csematerials_app/core/routing/app_routes.dart';
import 'package:csematerials_app/features/profile/widgets/action_tile.dart';
import 'package:csematerials_app/features/profile/widgets/info_card.dart';
import 'package:csematerials_app/features/profile/widgets/info_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int? selectedLevel;
  int? selectedTerm;
  bool isAdmin = false;
  String? profileImageUrl;

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // fireStore user data
  String? fullName;
  String? StudentId;
  String? email;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<String?> _uploadToSupabase(File file) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final filePath = "profile_$uid.jpg";

      final storage = Supabase.instance.client.storage;

      // upload file
      final response = await storage
          .from('profile-images')
          .upload(filePath, file, fileOptions: const FileOptions(upsert: true));

      // get public URL
      final imageUrl = storage.from('profile-images').getPublicUrl(filePath);

      print("✅ Uploaded to Supabase: $imageUrl");

      return imageUrl;
    } catch (e) {
      print("❌ Supabase Upload Error: $e");
      return null;
    }
  }

  Future<void> _loadUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    print("🔍 Current logged in email: ${currentUser.email}");
    print("🔍 Current logged in UID: ${currentUser.uid}");

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (docSnapshot.exists) {
        final userData = docSnapshot.data();

        setState(() {
          fullName = userData?['fullName'];
          StudentId = userData?['id'];
          email = userData?['email'];
          selectedLevel = userData?['level'];
          selectedTerm = userData?['term'];
          isAdmin = userData?['isAdmin'] ?? false;
          profileImageUrl = userData?['profileImage'];
        });

        // Load profile image from Firestore
        if (userData?['profileImage'] != null) {
          print("🖼 Loaded profile image URL");
          // No need to load file — NetworkImage handles this
        }

        print("✅ Loaded user data: $userData");
      } else {
        print("⚠️ No Firestore document found for UID: ${currentUser.uid}");
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    // request permision before opening camera/gallery
    if (source == ImageSource.camera) {
      var cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) return;
    } else {
      if (Platform.isAndroid) {
        final storagePermission = await Permission.storage.request();
        if (!storagePermission.isGranted) {
          return;
        }
      } else {
        final photoPermission = await Permission.photos.request();
        if (!photoPermission.isGranted) {
          return;
        }
      }
    }
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 85, // compress slightly for speed
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      //upload to supabase
      final imageUrl = await _uploadToSupabase(_profileImage!);

      if (imageUrl != null) {
        final uid = FirebaseAuth.instance.currentUser!.uid;

        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'profileImage': imageUrl,
        });

        print("Firestore updated with image URl");

        setState(() {});
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 40,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt,
                    color: Colors.deepPurple,
                  ),
                  title: const Text("Take a Photo"),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: Colors.deepPurple,
                  ),
                  title: const Text("Choose from Gallery"),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSemesterPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          maxChildSize: 0.5,
          minChildSize: 0.3,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: 4,
                        width: 50,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Text(
                      "Select Level",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: [1, 2, 3, 4].map((level) {
                        final isSelected = selectedLevel == level;
                        return ChoiceChip(
                          label: Text("Level $level"),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() => selectedLevel = level);
                          },
                          selectedColor: const Color(0xFF4A4BB5),
                          backgroundColor: Colors.grey.shade200,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Select Term",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: [1, 2].map((term) {
                        final isSelected = selectedTerm == term;
                        return ChoiceChip(
                          label: Text("Term $term"),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() => selectedTerm = term);
                          },
                          selectedColor: const Color(0xFF4A4BB5),
                          backgroundColor: Colors.grey.shade200,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (selectedLevel == null || selectedTerm == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please select level & term"),
                              ),
                            );
                            return;
                          }
                          final uid = FirebaseAuth.instance.currentUser!.uid;
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .set({
                                'level': selectedLevel,
                                'term': selectedTerm,
                              }, SetOptions(merge: true));
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A4BB5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          "Save Semester",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 215, 217, 250),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 35),
                decoration: BoxDecoration(
                  gradient: kMainGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 👤 Profile Picture
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : (profileImageUrl != null
                                          ? NetworkImage(profileImageUrl!)
                                          : const AssetImage(
                                              'assets/images/profile_pic.webp',
                                            ))
                                      as ImageProvider,
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: InkWell(
                              onTap: _showImagePickerOptions,
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.deepPurple,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      fullName ?? "Loading...",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      StudentId ?? "",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      email ?? "",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Downloads & Bookmarks summary
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InfoItem(value: "47", label: "Total Downloads"),
                          Container(
                            width: 1,
                            height: 30,
                            color: Colors.grey.shade300,
                          ),
                          InfoItem(value: "5", label: "Bookmarks"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Profile Information Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Profile Information",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    InfoCard(
                      icon: Icons.badge_outlined,
                      title: "Student ID",
                      value: StudentId ?? "Loading...",
                    ),
                    const SizedBox(height: 10),

                    InfoCard(
                      icon: Icons.email_outlined,
                      title: "Email",
                      value: email ?? "Loading...",
                    ),
                    const SizedBox(height: 10),

                    GestureDetector(
                      onTap: _showSemesterPicker,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.05),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.school_outlined,
                              color: Color(0xff8e24aa),
                            ),
                            SizedBox(width: 12),
                            Text(
                              selectedLevel != null && selectedTerm != null
                                  ? "Level $selectedLevel Term $selectedTerm"
                                  : "Select Semester",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Spacer(),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    InfoCard(
                      icon: Icons.download_outlined,
                      title: "Total Downloads",
                      value: "47 materials",
                    ),
                    const SizedBox(height: 25),

                    // Action Buttons
                    ActionTile(
                      icon: Icons.bookmark_outline,
                      title: "View Bookmarks",
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.bookmarks);
                      },
                    ),
                    ActionTile(
                      icon: Icons.edit_outlined,
                      title: "Change Password",
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.changePassword);
                      },
                    ),
                    ActionTile(
                      icon: Icons.info_outline,
                      title: "About App",
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.aboutApp);
                      },
                    ),
                    if (isAdmin)
                      ActionTile(
                        icon: Icons.admin_panel_settings_outlined,
                        title: "Admin Panel",
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.adminPanel);
                        },
                      ),

                    ActionTile(
                      icon: Icons.logout,
                      title: "Logout",
                      color: Colors.red,
                      isLogout: true,
                      onTap: () async {
                        final confirm = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Log Out'),
                            content: const Text(
                              'Are you sure you want to log out?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancle'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                ),
                                child: const Text('LogOut'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          // clear local storage or session here if needed
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.login,
                            (route) => false,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
