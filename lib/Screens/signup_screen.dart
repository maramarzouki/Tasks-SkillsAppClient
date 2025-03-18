import 'package:flutter/material.dart';
import 'package:planning_and_skills_app_client/Screens/signin_screen.dart';
import 'package:planning_and_skills_app_client/Widgets/custom_textfield_widget.dart';
import 'package:planning_and_skills_app_client/models/user.dart';
import 'package:planning_and_skills_app_client/services/user_service.dart';

class Signupscreen extends StatefulWidget {
  static const routeName = '/signup';
  const Signupscreen({super.key});

  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
  final signupFormGlobalKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? emailErrorMsg;

  String? response;

  Future<void> register() async {
    User user = User(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      email: emailController.text,
      password: passwordController.text,
    );
    if (signupFormGlobalKey.currentState!.validate()) {
      try {
        final result = await UserService.register(user);

        Navigator.of(context).pushNamed(SigninScreen.routeName);
        print("Success: $result");
      } catch (e) {
        setState(() {
          emailErrorMsg = e.toString().replaceAll('Exception: ', '');
        });
        print("Error: $e");
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
              key: signupFormGlobalKey,
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center, // Center the column
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: screenHeight * 0.09,
                  ),
                  Text(
                    "Let's get started!",
                    style: TextStyle(
                        fontSize: screenWidth * 0.15,
                        color: Color(0xffF9F9F9),
                        height: 1),
                    softWrap: true,
                  ),
                  SizedBox(
                    height: screenHeight * 0.07,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomTextfieldWidget(
                        width: screenWidth * 0.4,
                        hint: "First name",
                        validatorMsg: 'First name is required!',
                        prefixIcon: Icons.person_outline_rounded,
                        controller: firstNameController,
                      ),
                      SizedBox(
                        width: screenWidth * 0.015,
                      ),
                      CustomTextfieldWidget(
                        width: screenWidth * 0.4,
                        hint: "Last name",
                        validatorMsg: 'Last name is required!',
                        prefixIcon: Icons.person_outline_rounded,
                        controller: lastNameController,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  CustomTextfieldWidget(
                    textInputType: TextInputType.emailAddress,
                    width: screenWidth * 0.815,
                    hint: "Email",
                    validatorMsg: 'Email is required!',
                    prefixIcon: Icons.email_outlined,
                    controller: emailController,
                  ),
                  if (emailErrorMsg != null) // Show error message if it exists
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        emailErrorMsg!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  CustomTextfieldWidget(
                    width: screenWidth * 0.815,
                    hint: "Password",
                    obsucreText: true,
                    validatorMsg: 'Password is required!',
                    prefixIcon: Icons.lock_outlined,
                    controller: passwordController,
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  CustomTextfieldWidget(
                    width: screenWidth * 0.815,
                    hint: "Confirm password",
                    validatorMsg: 'This field is required!',
                    obsucreText: true,
                    prefixIcon: Icons.lock_outlined,
                    controller: confirmPasswordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirm password is required!';
                      } else if (value != passwordController.text) {
                        return 'Passwords do not match!';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  ElevatedButton(
                    key: const Key("Register button"),
                    onPressed: () {
                      register();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6F61),
                      minimumSize: Size(200, 45),
                    ),
                    child: const Text(
                      'Register',
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
                        'Have an account already?',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero, // Removes extra padding
                          minimumSize:
                              Size(0, 0), // Ensures no additional spacing
                        ),
                        child: const Text(
                          ' Sign in!',
                          style: TextStyle(
                            color: Color(0xFFF9F9F9),
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                            decorationColor: Color(0xFFF9F9F9),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(SigninScreen.routeName);
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
