import 'package:csematerials_app/features/home/widgets/big_feature_card.dart';
import 'package:csematerials_app/features/home/widgets/header_card.dart';
import 'package:csematerials_app/features/home/widgets/semester_card.dart';
import 'package:flutter/material.dart';
import 'package:csematerials_app/core/routing/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 215, 217, 250),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //header
              const HeaderCard(),
              Container(
                margin: EdgeInsets.zero,
                color: Color.fromARGB(255, 215, 217, 250),

                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 17,
                ),

                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ Previous Year Question Card
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.prevQuestions);
                        },

                        child: BigFeatureCard(
                          title: "Previous Year Questions",
                          subtitle: "Past exam papers & solutions",
                          icon: Icons.description_rounded,
                          gradient: [Color(0xFFF72585), Color(0xFF7209B7)],
                          stats: ["250+ Papers", "2022–2024", "1.5k Downloads"],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ✅ AI Picks
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.aiRecommendation,
                          );
                        },
                        child: BigFeatureCard(
                          title: "AI Picks for You",
                          subtitle: "Personalized materials",
                          icon: Icons.psychology_rounded,
                          gradient: [Color(0xFF7B2FF7), Color(0xFFDF98FA)],
                          stats: [],
                          compact: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 18),

                    // ✅ Section Title
                    Text(
                      "All Semesters",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Select to view courses',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),

                    const SizedBox(height: 10),

                    // ✅ Semester Grid (1-8)
                    GridView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 8,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.4,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemBuilder: (_, i) {
                        final semesterNames = [
                          "Level-I Term-I",
                          "Level-I Term-II",
                          "Level-II Term-I",
                          "Level-II Term-II",
                          "Level-III Term-I",
                          "Level-III Term-II",
                          "Level-IV Term-I",
                          "Level-IV Term-II",
                        ];

                        // Level IV Term II
                        final evenGradient = [
                          Color(0xFF4A4BB5),
                          Color(0xFF3D42A8),
                        ];

                        final oddGradient = [
                          Color.fromARGB(255, 174, 150, 64),
                          Color.fromARGB(255, 134, 111, 56),
                        ];

                        final gradient = (i % 2 == 0)
                            ? evenGradient
                            : oddGradient;

                        return SemesterCard(
                          semester: semesterNames[i],
                          gradient: gradient,
                        );
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
