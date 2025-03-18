import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pinput/pinput.dart';
import 'package:planning_and_skills_app_client/Screens/reset%20password%20screens/reset_password_screen.dart';
import 'package:planning_and_skills_app_client/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CodeInputScreen extends StatefulWidget {
  static const routeName = '/codeinput';
  const CodeInputScreen({super.key});

  @override
  State<CodeInputScreen> createState() => _CodeInputScreenState();
}

class _CodeInputScreenState extends State<CodeInputScreen> {
  String errorMessage = '';
  int code = 0;

  Future<void> verifyCode() async {
    final email = ModalRoute.of(context)!.settings.arguments as String;

    try {
      print("dkhalna f try");
      print(code);
      final responseMessage = await UserService.verifyCode(email, code);

      if (responseMessage == "Code is correct!") {
        print("wselna lenna");
        // If the code is verified, navigate to the ResetPasswordScreen.
        Navigator.of(context)
            .pushNamed(ResetPasswordScreen.routeName, arguments: email);
      } else {
        print("wala lenna");
        // If the response indicates an issue, display the error.
        setState(() {
          errorMessage = responseMessage;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final defaultPinTheme = PinTheme(
      width: screenWidth * 0.5,
      height: screenHeight * 0.08,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color(0xffF9F9F9),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF9D9AB1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );
    return Scaffold(
      backgroundColor: const Color(0xff2A3143),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.07),
        child: Container(
          margin: EdgeInsets.only(top: screenWidth * 0.4),
          width: double.infinity,
          child: Column(
            children: [
              Text(
                "Verification",
                style: TextStyle(
                  color: Color(0xffF9F9F9),
                  fontSize: screenWidth * 0.07,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: screenWidth * 0.1),
                child: Text(
                  "Enter the code sent to your email",
                  style: TextStyle(
                    color: Color(0xFF9D9AB1),
                    fontSize: screenWidth * 0.045,
                  ),
                ),
              ),
              Pinput(
                length: 6,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    border: Border.all(color: const Color(0xFFFF6F61)),
                  ),
                ),
                onCompleted: (pin) => code = int.parse(pin),
              ),
              if (errorMessage.isNotEmpty) // Show error message if it exists
                Padding(
                  padding: EdgeInsets.only(top: screenWidth * 0.009),
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              SizedBox(
                height: screenHeight * 0.04,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6F61),
                    minimumSize: Size(screenWidth * 0.1, screenHeight * 0.05),
                  ),
                  onPressed: () {
                    verifyCode();
                  },
                  child: const Text(
                    'Verify',
                    style: TextStyle(color: Color(0xffF9F9F9)),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
