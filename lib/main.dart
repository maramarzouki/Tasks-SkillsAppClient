import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planning_and_skills_app_client/screens/calendar_screen.dart';
import 'package:planning_and_skills_app_client/screens/home_screen.dart';
import 'package:planning_and_skills_app_client/screens/modules_screen.dart';
import 'package:planning_and_skills_app_client/screens/navbar.dart';
import 'package:planning_and_skills_app_client/screens/timer_screen.dart';
import 'package:planning_and_skills_app_client/screens/reset%20password%20screens/code_input_screen.dart';
import 'package:planning_and_skills_app_client/screens/reset%20password%20screens/email_input_screen.dart';
import 'package:planning_and_skills_app_client/screens/reset%20password%20screens/reset_password_screen.dart';
import 'package:planning_and_skills_app_client/screens/signin_screen.dart';
import 'package:planning_and_skills_app_client/screens/signup_screen.dart';
import 'package:planning_and_skills_app_client/screens/timers_screen.dart';
import 'package:planning_and_skills_app_client/providers/time_provider.dart';
import 'package:planning_and_skills_app_client/services/notifications_helper.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await NotificationHelper.initializeNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TimeProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            textTheme: GoogleFonts.rubikTextTheme()),
        initialRoute: '/',
        routes: {
          '/': (context) => SigninScreen(),
          Signupscreen.routeName: (context) => Signupscreen(),
          Navbar.routeName: (context) => const Navbar(),
          CodeInputScreen.routeName: (context) => const CodeInputScreen(),
          EmailInputScreen.routeName: (context) => const EmailInputScreen(),
          ResetPasswordScreen.routeName: (context) =>
              const ResetPasswordScreen(),
          CalendarScreen.routeName: (context) => const CalendarScreen(),
          HomeScreen.routeName: (context) => HomeScreen(),
          ModulesScreen.routeName: (context) => ModulesScreen(),
          TimersScreen.routeName: (context) => TimersScreen(),
        },
      ),
    );
  }
}
