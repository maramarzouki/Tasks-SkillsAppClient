import 'package:flutter/material.dart';

class CustomTextfieldWidget extends StatelessWidget {
  final String? hint;
  final Function(String)? onDone;
  final double? width;
  final TextInputType? textInputType;
  final String? validatorMsg;
  final TextEditingController? controller;
  final bool? obsucreText;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final IconData? suffixIcon;

  const CustomTextfieldWidget(
      {super.key,
      this.hint,
      this.onDone,
      this.width,
      this.textInputType,
      this.validatorMsg,
      this.controller,
      this.obsucreText,
      this.validator,
      this.prefixIcon,
      this.suffixIcon});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xff2B3349), // Background color
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.3,
            ), // Shadow color
            blurRadius: 8, // Spread of the shadow
            offset: const Offset(2, 4), // Position of the shadow
          ),
        ],
      ),
      child: TextFormField(
        keyboardType: textInputType,
        validator: validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return validatorMsg;
              }
              return null;
            },
        controller: controller,
        obscureText: obsucreText ?? false,
        style: TextStyle(color: Color(0xffD9D9D9)),
        cursorColor: Color(0xffD9D9D9),
        decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            hintText: hint,
            fillColor: Colors.transparent, // Prevents double background
            filled: true,
            contentPadding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.01, horizontal: screenWidth * 0.01),
            hintStyle: TextStyle(
                color: Color(0xffD9D9D9), fontSize: screenWidth * 0.03455),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: Color(0xffD9D9D9),
                    size: screenWidth * 0.055,
                  )
                : null,
            suffix: suffixIcon != null
                ? Icon(
                    suffixIcon,
                    color: Color(0xffD9D9D9),
                    size: 0.055,
                  )
                : null),
        onSaved: (value) => onDone?.call(value!),
      ),
    );
  }
}
