// import 'package:cuet_cse_course_materials_app/core/constants/colors.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class ChangePasswordScreen extends StatefulWidget {
//   const ChangePasswordScreen({super.key});

//   @override
//   State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
// }

// class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
//   final _currentPasswordController = TextEditingController();
//   final _newPasswordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   bool _isLoading = false;

//   final _formKey = GlobalKey<FormState>();

//   // Reauthenticate user before changing password
//   Future<void> _changePassword() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     try {
//       final user = FirebaseAuth.instance.currentUser!;
//       final cred = EmailAuthProvider.credential(
//         email: user.email!,
//         password: _currentPasswordController.text.trim(),
//       );

//       // reauthenticate
//       await user.reauthenticateWithCredential(cred);

//       // check new passwords match
//       if (_newPasswordController.text.trim() !=
//           _confirmPasswordController.text.trim()) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("New passwords do not match")),
//         );
//         setState(() => _isLoading = false);
//         return;
//       }

//       // update password
//       await user.updatePassword(_newPasswordController.text.trim());

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("✅ Password updated successfully!")),
//       );

//       Navigator.pop(context);
//     } on FirebaseAuthException catch (e) {
//       String message = "Something went wrong";
//       if (e.code == 'wrong-password') {
//         message = "❌ Incorrect current password.";
//       } else if (e.code == 'weak-password') {
//         message = "⚠️ New password is too weak.";
//       } else {
//         message = e.message ?? message;
//       }
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(message)));
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Change Password",
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Color(0xFF4A4BB5),
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _currentPasswordController,
//                 obscureText: true,
//                 decoration: const InputDecoration(
//                   labelText: "Current Password",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) =>
//                     value!.isEmpty ? "Enter your current password" : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _newPasswordController,
//                 obscureText: true,
//                 decoration: const InputDecoration(
//                   labelText: "New Password",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) =>
//                     value!.length < 6 ? "At least 6 characters" : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _confirmPasswordController,
//                 obscureText: true,
//                 decoration: const InputDecoration(
//                   labelText: "Confirm New Password",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) => value != _newPasswordController.text
//                     ? "Passwords do not match"
//                     : null,
//               ),
//               const SizedBox(height: 30),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF4A4BB5),
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                   ),
//                   onPressed: _isLoading ? null : _changePassword,
//                   child: _isLoading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : Text(
//                           "Update Password",
//                           style: GoogleFonts.poppins(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text.trim(),
      );

      await user.reauthenticateWithCredential(cred);

      if (_newPasswordController.text.trim() !=
          _confirmPasswordController.text.trim()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("New passwords do not match")),
        );
        setState(() => _isLoading = false);
        return;
      }

      await user.updatePassword(_newPasswordController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Password updated successfully!")),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = "Something went wrong";
      if (e.code == 'wrong-password') {
        message = "❌ Incorrect current password.";
      } else if (e.code == 'weak-password') {
        message = "⚠️ New password is too weak.";
      } else {
        message = e.message ?? message;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration(
    String label, {
    bool showText = false,
    VoidCallback? onToggle,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 15, color: Colors.black54),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      suffixIcon: onToggle != null
          ? IconButton(
              icon: Icon(
                showText
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: Colors.grey,
              ),
              onPressed: onToggle,
            )
          : null,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = const Color(0xFF4A4BB5);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 235, 235, 236),
      appBar: AppBar(
        title: Text(
          "Change Password",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: mainColor,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "Update your password securely",
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 80),

              // Current Password
              TextFormField(
                controller: _currentPasswordController,
                obscureText: !_showCurrent,
                decoration: _inputDecoration(
                  "Current Password",
                  showText: _showCurrent,
                  onToggle: () => setState(() => _showCurrent = !_showCurrent),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Enter your current password" : null,
              ),
              const SizedBox(height: 18),

              // New Password
              TextFormField(
                controller: _newPasswordController,
                obscureText: !_showNew,
                decoration: _inputDecoration(
                  "New Password",
                  showText: _showNew,
                  onToggle: () => setState(() => _showNew = !_showNew),
                ),
                validator: (value) =>
                    value!.length < 6 ? "At least 6 characters" : null,
              ),
              const SizedBox(height: 18),

              // Confirm Password
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_showConfirm,
                decoration: _inputDecoration(
                  "Confirm New Password",
                  showText: _showConfirm,
                  onToggle: () => setState(() => _showConfirm = !_showConfirm),
                ),
                validator: (value) => value != _newPasswordController.text
                    ? "Passwords do not match"
                    : null,
              ),
              const SizedBox(height: 35),

              // Button
              SizedBox(
                width: double.infinity,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: mainColor.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _isLoading ? null : _changePassword,
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            "Update Password",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
