import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:planning_and_skills_app_client/Screens/signin_screen.dart';
import 'package:planning_and_skills_app_client/Widgets/custom_textfield_widget.dart';
import 'package:planning_and_skills_app_client/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResetPasswordScreen extends StatefulWidget {
  static const routeName = '/resetpassword';
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  String errorMessage = "";
  String errorMsg = "";

  Future<void> resetPassword() async {
    final email = ModalRoute.of(context)!.settings.arguments as String;

    if (formKey.currentState!.validate()) {
      try {
        final result = await UserService.resetPassword(
          email,
          passwordController.text,
        );

        Navigator.of(context).pushNamed(SigninScreen.routeName);
        print("Success: $result");
      } catch (e) {
        setState(() {
          errorMsg = e.toString().replaceAll('Exception: ', '');
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: screenHeight * 0.09,
                      ),
                      Text(
                        "Reset your password",
                        style: TextStyle(
                            fontSize: screenWidth * 0.08,
                            color: Color(0xffF9F9F9),
                            height: 1),
                        softWrap: true,
                      ),
                      SizedBox(
                        height: screenHeight * 0.07,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomTextfieldWidget(
                            width: screenWidth * 0.815,
                            hint: "Password",
                            obsucreText: true,
                            prefixIcon: Icons.lock_outlined,
                            controller: passwordController,
                            validatorMsg: 'Password is required!',
                          ),
                          SizedBox(
                            height: screenHeight * 0.02,
                          ),
                          CustomTextfieldWidget(
                            width: screenWidth * 0.815,
                            hint: "Confirm password",
                            obsucreText: true,
                            prefixIcon: Icons.lock_outlined,
                            controller: confirmPasswordController,
                            validatorMsg: 'Confirm password is required!',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Confirm password is required!';
                              } else if (value != passwordController.text) {
                                return 'Passwords do not match!';
                              }
                              return null;
                            },
                          ),
                          if (errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                errorMsg!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          SizedBox(
                            height: screenHeight * 0.03,
                          ),
                          ElevatedButton(
                            key: const Key("reset pwd btn"),
                            onPressed: () {
                              resetPassword();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6F61),
                              minimumSize:
                                  Size(screenWidth * 0.3, screenHeight * 0.05),
                            ),
                            child: const Text(
                              'Reset',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ]),
              ),
            ),
          ),
        ));
  }
}
