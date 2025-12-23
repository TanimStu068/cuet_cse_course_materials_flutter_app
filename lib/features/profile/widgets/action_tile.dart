import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? color;
  final bool isLogout;
  final VoidCallback onTap;

  const ActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    final tileColor = isLogout
        ? Colors.red.shade50
        : Colors.white.withOpacity(0.95);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? const Color(0xff8e24aa)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: isLogout ? FontWeight.w600 : FontWeight.normal,
                  color: isLogout ? Colors.red : Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
