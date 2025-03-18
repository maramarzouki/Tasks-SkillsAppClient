import 'package:flutter/material.dart';

class ModulesScreen extends StatelessWidget {
  static const routeName = '/modulesscreen';
  const ModulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return const Scaffold(
      backgroundColor: Color(0xfff1f2f6),
      body: SafeArea(child: Text('modules page')),
    );
  }
}
