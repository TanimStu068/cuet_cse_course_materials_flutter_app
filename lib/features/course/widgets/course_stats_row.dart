import 'package:flutter/material.dart';

class CourseStatsRow extends StatelessWidget {
  final int materialsCount;
  final String views;
  final int downloads;

  const CourseStatsRow({
    super.key,
    required this.materialsCount,
    required this.views,
    required this.downloads,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard(
          icon: Icons.insert_drive_file_outlined,
          iconColor: Colors.blueAccent,
          value: materialsCount.toString(),
          label: 'Materials',
        ),
        _buildStatCard(
          icon: Icons.remove_red_eye_outlined,
          iconColor: Colors.greenAccent.shade400,
          value: views,
          label: 'Views',
        ),
        _buildStatCard(
          icon: Icons.download_rounded,
          iconColor: Colors.pinkAccent,
          value: downloads.toString(),
          label: 'Downloads',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      width: 100,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 26),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
