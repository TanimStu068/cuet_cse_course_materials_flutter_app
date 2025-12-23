import 'package:csematerials_app/features/home/widgets/home_nav_bar.dart';
import 'package:flutter/material.dart';

// Import your screens
import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/course/course_list_screen.dart';
import '../../features/course/material_list_screen.dart';
import '../../features/course/material_detail_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/bookmarks/bookmarks_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/ai/ai_recommendation_screen.dart';
import '../../features/questions/previous_questions_screen.dart';
import '../../features/editprofile/edit_profile_screen.dart';
import '../../features/aboutapp/about_app_screen.dart';
import '../../features/change_password/change_password_screen.dart';
import '../../features/admin_panel/admin_panel_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';

  static const String courseList = '/course-list';
  static const String materialList = '/material-list';
  static const String materialDetails = '/material-details';

  static const String search = '/search';
  static const String bookmarks = '/bookmarks';
  static const String profile = '/profile';
  static const String aiRecommendation = '/ai-recommendation';
  static const String prevQuestions = '/previous-questions';
  static const String editProfile = '/edit-profile';
  static const String aboutApp = '/about-app';
  static const changePassword = '/changePassword';
  static const adminPanel = '/adminPanel';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    home: (context) => const HomeNavBar(),

    AppRoutes.courseList: (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return CourseListScreen(semesterId: args['semesterId']);
    },
    materialList: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      return MaterialListScreen(
        semesterId: args?['semesterId'] ?? 'Unknown Semester',
        courseCode: args?['courseCode'] ?? 'Unknown Code',
      );
    },

    materialDetails: (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

      return MaterialDetailScreen(
        title: args['title'] ?? 'Unknown Title',
        type: args['type'] ?? 'Unknown Type',
        courseCode: args['courseCode'] ?? 'Unknown Course',
        courseName: args['courseName'] ?? 'Unknown Name',
        semester: args['semester'] ?? 'Unknown Semester',
        description: args['description'] ?? '',
        pdfUrl: args['pdfUrl'],
      );
    },

    search: (context) => const SearchScreen(),
    bookmarks: (context) => const BookmarksScreen(),
    profile: (context) => const ProfileScreen(),
    aiRecommendation: (context) => const AIRecommendationScreen(),
    prevQuestions: (context) => const PreviousQuestionsScreen(),
    editProfile: (context) => const EditProfileScreen(),
    aboutApp: (context) => const AboutAppScreen(),
    changePassword: (context) => const ChangePasswordScreen(),
    adminPanel: (context) => const AdminPanelScreen(),
  };
}
