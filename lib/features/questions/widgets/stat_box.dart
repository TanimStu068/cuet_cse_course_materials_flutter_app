import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class StatBox extends StatelessWidget {
  final String number;
  final String label;

  const StatBox({super.key, required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14), // slightly smaller corners
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6), // softer blur
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16, //20
            vertical: 12, //14
          ), // smaller padding
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12), // subtle glass color
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                number,
                style: GoogleFonts.poppins(
                  fontSize: 17, // smaller text
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12, // smaller label
                  color: Colors.white70,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
