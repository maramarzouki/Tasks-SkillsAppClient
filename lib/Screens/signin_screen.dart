import 'package:flutter/material.dart';
import 'package:planning_and_skills_app_client/Screens/home_screen.dart';
import 'package:planning_and_skills_app_client/Screens/navbar.dart';
import 'package:planning_and_skills_app_client/Screens/reset%20password%20screens/email_input_screen.dart';
import 'package:planning_and_skills_app_client/Screens/signup_screen.dart';
import 'package:planning_and_skills_app_client/Widgets/custom_textfield_widget.dart';
import 'package:planning_and_skills_app_client/models/user.dart';
import 'package:planning_and_skills_app_client/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SigninScreen extends StatefulWidget {
  static const routeName = '/';
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final signinFormGlobalKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  dynamic response;
  String? emailError;
  String? passwordError;

  Future<void> login() async {
    User user = User(
        email: emailController.text.trim(),
        password: passwordController.text.trim());
    if (signinFormGlobalKey.currentState!.validate()) {
      debugPrint(emailController.text);
      debugPrint(passwordController.text);
      try {
        final token = await UserService.login(user);
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('token', token);
        debugPrint("TOEN: ${prefs.getString('token')}");
        Navigator.of(context).pushNamed(Navbar.routeName);
        debugPrint("Login success, token: $token");
      } catch (e) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        setState(() {
          emailError = errorMsg;
          passwordError = null;
        });
        debugPrint("Login error: $errorMsg");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xff2A3143),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Form(
              key: signinFormGlobalKey,
              child: Column(
                children: [
                  SizedBox(
                    height: screenHeight * 0.09,
                  ),
                  const Text(
                    "Welcome",
                    style: TextStyle(
                        fontSize: 50, color: Color(0xffF9F9F9), height: 1),
                    softWrap: true,
                  ),
                  SizedBox(
                    height: screenHeight * 0.07,
                  ),
                  CustomTextfieldWidget(
                    textInputType: TextInputType.emailAddress,
                    width: screenWidth * 0.815,
                    hint: "Email",
                    prefixIcon: Icons.email_outlined,
                    controller: emailController,
                    validatorMsg: 'Email is required!',
                  ),
                  if (emailError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        emailError!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  CustomTextfieldWidget(
                    width: screenWidth * 0.815,
                    hint: "Password",
                    obsucreText: true,
                    prefixIcon: Icons.lock_outlined,
                    controller: passwordController,
                    validatorMsg: 'Password is required!',
                  ),
                  if (passwordError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        passwordError!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                              color: Color(0xffF9F9F9),
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                              decorationColor: Color(0xffF9F9F9),
                              fontStyle: FontStyle.italic),
                        ),
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(EmailInputScreen.routeName);
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  ElevatedButton(
                    key: const Key("signin button"),
                    onPressed: () {
                      login();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6F61),
                      minimumSize:
                          Size(screenWidth * 0.45, screenHeight * 0.06),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Don\'t have an account?',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero, // Removes extra padding
                          minimumSize:
                              Size(0, 0), // Ensures no additional spacing
                        ),
                        child: const Text(
                          ' Sign up!',
                          style: TextStyle(
                            color: Color(0xFFF9F9F9),
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                            decorationColor: Color(0xFFF9F9F9),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(Signupscreen.routeName);
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
