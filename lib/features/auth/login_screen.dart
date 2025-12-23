import 'package:flutter/material.dart';
import '../../../core/routing/app_routes.dart';
import 'package:csematerials_app/data/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool isLoading = false;

  bool rememberMe = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void showStyledSnackBar(
    BuildContext context,
    String message, {
    bool isError = true,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError
            ? Colors.redAccent.shade100
            : Colors.greenAccent.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // 👈 Add this line
      // ✅ Background gradient matches card theme
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E3192), // Deep CUET Blue
              Color(0xFF4B56C0), // Softer blue transition
            ],
            stops: [0.0, 1.0],
          ),
          //color: Color.fromARGB(193, 209, 207, 207),
          // gradient: LinearGradient(
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          //   colors: [
          //     Color(0xFFFBECC4), // soft light gold
          //     Color(0xFF2E3192), // CUET deep blue
          //   ],
          //   stops: [0.1, 1.0],
          // ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Card Content
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),

                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 32,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFF7E5A4), // soft golden tone
                                    Color(0xFF6F77E8), // smooth blue tone
                                  ],
                                  stops: [0.0, 1.0],
                                ),
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // CUET logo
                                  Image.asset(
                                    "assets/images/cuet_logo.webp",
                                    height: 90,
                                  ),
                                  const SizedBox(height: 16),

                                  // Tagline
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 3,
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      "🚀 Smart Learning Platform",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  const Text(
                                    "Welcome to",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "CUET CSE Materials",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.indigo.shade900,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    "Access all your course materials in one place",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),

                                  const SizedBox(height: 30),

                                  // Email
                                  TextField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      labelText: "Email Address",
                                      prefixIcon: const Icon(
                                        Icons.email_outlined,
                                        color: Colors.grey,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      hintText: "u2104068@student.cuet.ac.bd",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 18),

                                  // Password
                                  TextField(
                                    controller: _passwordController,
                                    obscureText: obscurePassword,
                                    decoration: InputDecoration(
                                      labelText: "Password",
                                      prefixIcon: const Icon(
                                        Icons.lock_outline,
                                        color: Colors.grey,
                                      ),
                                      suffixIcon: GestureDetector(
                                        onTap: () => setState(
                                          () => obscurePassword =
                                              !obscurePassword,
                                        ),
                                        child: Icon(
                                          obscurePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      hintText: "Enter your password",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: rememberMe,
                                            onChanged: (v) =>
                                                setState(() => rememberMe = v!),
                                          ),
                                          const Text("Remember me"),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          final TextEditingController
                                          emailController =
                                              TextEditingController();

                                          await showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text(
                                                'Reset Password',
                                              ),
                                              content: TextField(
                                                controller: emailController,
                                                decoration: const InputDecoration(
                                                  labelText: 'Enter your email',
                                                  hintText:
                                                      'u2104001@student.cuet.ac.bd',
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    final email =
                                                        emailController.text
                                                            .trim();
                                                    if (email.isEmpty) return;

                                                    try {
                                                      await _authService
                                                          .sendPasswordReset(
                                                            email,
                                                          );
                                                      if (!context.mounted)
                                                        return;
                                                      Navigator.pop(context);
                                                      showStyledSnackBar(
                                                        context,
                                                        'Password reset email sent. Check your inbox.',
                                                        isError: false,
                                                      );
                                                    } catch (_) {
                                                      showStyledSnackBar(
                                                        context,
                                                        'Failed to send email. Try again later.',
                                                        isError: true,
                                                      );
                                                    }
                                                  },
                                                  child: const Text('Send'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },

                                        child: const Text(
                                          "Forgot password?",
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                              255,
                                              233,
                                              180,
                                              21,
                                            ),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),

                                  // Login Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        setState(() => isLoading = true);

                                        // try {
                                        //   await _authService.signIn(
                                        //     _emailController.text.trim(),
                                        //     _passwordController.text.trim(),
                                        //   );

                                        //   if (!mounted) return;

                                        //   final user =
                                        //       FirebaseAuth.instance.currentUser;
                                        //   if (user != null) {
                                        //     final doc = await FirebaseFirestore
                                        //         .instance
                                        //         .collection('users')
                                        //         .doc(user.uid)
                                        //         .get();
                                        //     final data = doc.data();
                                        //     final bool isAdmin =
                                        //         data?['isAdmin'] ?? false;

                                        //     showStyledSnackBar(
                                        //       context,
                                        //       'Login Successfully',
                                        //       isError: false,
                                        //     );

                                        //     if (isAdmin) {
                                        //       Navigator.pushReplacementNamed(
                                        //         context,
                                        //         AppRoutes.adminPanel,
                                        //       );
                                        //     } else {
                                        //       Navigator.pushReplacementNamed(
                                        //         context,
                                        //         AppRoutes.home,
                                        //       );
                                        //     }
                                        //   }
                                        // } on FirebaseAuthException catch (_) {
                                        //   showStyledSnackBar(
                                        //     context,
                                        //     'Login failed, Incorrect email or password.',
                                        //     isError: true,
                                        //   );
                                        // } catch (e) {
                                        //   showStyledSnackBar(
                                        //     context,
                                        //     'Something went wrong. Try again later.',
                                        //     isError: true,
                                        //   );
                                        // } finally {
                                        //   if (mounted)
                                        //     setState(() => isLoading = false);
                                        // }

                                        try {
                                          await _authService.signIn(
                                            _emailController.text.trim(),
                                            _passwordController.text.trim(),
                                          );

                                          if (!mounted) return;

                                          showStyledSnackBar(
                                            context,
                                            'Login successful!',
                                            isError: false,
                                          );

                                          Navigator.pushReplacementNamed(
                                            context,
                                            AppRoutes.home,
                                          );
                                        } on FirebaseAuthException catch (_) {
                                          showStyledSnackBar(
                                            context,
                                            'Login failed, Incorrect email or password.',
                                            isError: true,
                                          );
                                        } finally {
                                          if (mounted)
                                            setState(() => isLoading = false);
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFC89700,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        shadowColor: Colors.black.withOpacity(
                                          0.2,
                                        ),
                                        elevation: 4,
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Login",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(Icons.arrow_forward),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // ✅ Footer fixed at bottom
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Need help? "),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              "Contact CSE Department",
                              style: TextStyle(
                                color: Colors.blue.shade100,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "© 2025 CUET CSE. All rights reserved.",
                        style: TextStyle(fontSize: 10, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),

              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.4),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
