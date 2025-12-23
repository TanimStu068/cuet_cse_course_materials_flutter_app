import 'package:flutter/material.dart';
import 'package:csematerials_app/core/routing/app_routes.dart';

class SemesterCard extends StatelessWidget {
  final String semester;
  final List<Color> gradient;

  const SemesterCard({required this.semester, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.courseList,
          arguments: {'semesterId': semester},
        );
      },
      child: Container(
        decoration: BoxDecoration(
          // color: Color(0xFF4A4BB5),
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradient.last.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(3, 5),
            ),
          ],
        ),
        child: Center(
          child: Text(
            "$semester\nSemester",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
