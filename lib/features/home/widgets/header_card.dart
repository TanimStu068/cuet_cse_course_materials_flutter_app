import 'package:csematerials_app/core/constants/colors.dart';
import 'package:csematerials_app/features/home/widgets/stat_card.dart';
import 'package:flutter/material.dart';

class HeaderCard extends StatelessWidget {
  const HeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width, // full width
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      margin: EdgeInsets.zero, // remove any outer space
      decoration: const BoxDecoration(gradient: kMainGradient),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Top Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.school_rounded, color: Colors.white, size: 28),
                Padding(
                  padding: const EdgeInsets.only(right: 75),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Text(
                        "Welcome Back!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Choose your semester",
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(2),
                  child: Image.asset(
                    'assets/images/cuet_logo.webp',
                    height: 45,
                    width: 45,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // 🔹 Glass Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                StatCard(
                  icon: Icons.menu_book_rounded,
                  value: "76",
                  label: "Total Courses",
                  color: Colors.white,
                ),
                StatCard(
                  icon: Icons.download_rounded,
                  value: "3.5k",
                  label: "Downloads",
                  color: Colors.white,
                ),
                StatCard(
                  icon: Icons.calendar_today_rounded,
                  value: "1k+",
                  label: "Materials",
                  color: Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
