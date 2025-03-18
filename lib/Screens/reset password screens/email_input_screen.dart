import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:planning_and_skills_app_client/Screens/navbar.dart';
import 'package:planning_and_skills_app_client/Screens/reset%20password%20screens/code_input_screen.dart';
import 'package:planning_and_skills_app_client/Widgets/custom_textfield_widget.dart';
import 'package:planning_and_skills_app_client/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmailInputScreen extends StatefulWidget {
  static const routeName = '/emailinput';
  const EmailInputScreen({super.key});

  @override
  State<EmailInputScreen> createState() => _EmailInputScreenState();
}

class _EmailInputScreenState extends State<EmailInputScreen> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  String errorMessage = '';

  Future<void> sendCode() async {
    if (formKey.currentState!.validate()) {
      try {
        final result =
            await UserService.verifyEmailToResetPassword(emailController.text);

        Fluttertoast.showToast(
          msg: "Code sent to your email!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM, // Options: BOTTOM, TOP, or CENTER
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.of(context).pushNamed(CodeInputScreen.routeName,
            arguments: emailController.text);
        print("Success: $result");
      } catch (e) {
        setState(() {
          errorMessage = e.toString().replaceAll('Exception: ', '');
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
              key: formKey,
              child: Column(
                children: [
                  SizedBox(
                    height: screenHeight * 0.09,
                  ),
                  Text(
                    "Enter your email to receice a code",
                    style: TextStyle(
                        fontSize: screenWidth * 0.09,
                        color: Color(0xffF9F9F9),
                        height: screenHeight * 0.0015),
                    softWrap: true,
                  ),
                  SizedBox(
                    height: screenHeight * 0.07,
                  ),
                  CustomTextfieldWidget(
                    width: screenWidth * 0.815,
                    hint: "Email",
                    prefixIcon: Icons.email_outlined,
                    textInputType: TextInputType.emailAddress,
                    validatorMsg: 'Please enter your email to proceed!',
                    controller: emailController,
                  ),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  ElevatedButton(
                    key: const Key("send code button"),
                    onPressed: () {
                      sendCode();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6F61),
                      minimumSize: Size(screenWidth * 0.1, screenHeight * 0.05),
                    ),
                    child: const Text(
                      'Send code',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
