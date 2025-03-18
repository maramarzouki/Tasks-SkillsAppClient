import 'package:flutter/material.dart';
import 'package:planning_and_skills_app_client/Screens/calendar_screen.dart';
import 'package:planning_and_skills_app_client/Screens/home_screen.dart';
import 'package:planning_and_skills_app_client/Screens/modules_screen.dart';
import 'package:planning_and_skills_app_client/Screens/timers_screen.dart';

class Navbar extends StatefulWidget {
  static const routeName = '/navbar';
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    CalendarScreen(),
    ModulesScreen(),
    TimersScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: false,

      //display the selected page
      body: _pages[_currentIndex],

      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     showModalBottomSheet(
      //       context: context,
      //       // This helps to create rounded corners at the top
      //       shape: const RoundedRectangleBorder(
      //         borderRadius: BorderRadius.only(
      //           topLeft: Radius.circular(24),
      //           topRight: Radius.circular(24),
      //         ),
      //       ),
      //       // If you want the background color of the modal itself to be transparent,
      //       // you can do:
      //       // backgroundColor: Colors.transparent,
      //       builder: (BuildContext context) {
      //         return _buildBottomModalContent();
      //       },
      //     );
      //   },
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.only(
      //       topLeft: Radius.circular(50),
      //       topRight: Radius.circular(50),
      //       bottomRight: Radius.circular(50),
      //       bottomLeft: Radius.circular(50),
      //     ),
      //   ),
      //   backgroundColor: const Color(0xFFFF6F61),
      //   child: const Icon(
      //     Icons.add,
      //     color: Color(0xfff5f5f5),
      //   ),
      // ),

      // 3. Bottom navigation bar
      bottomNavigationBar: ClipRRect(
        // borderRadius: BorderRadius.all(Radius.elliptical(0, 0)),
        borderRadius: BorderRadius.all(Radius.circular(15)),
        child: Container(
          height: screenHeight * 0.075,
          width: screenWidth * 0.07,
          alignment: Alignment.center,
          child: BottomAppBar(
            // notchMargin: 8.0,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            color: const Color.fromARGB(204, 0, 14, 43),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.home_rounded,
                    color:
                        _currentIndex == 0 ? Color(0xFFFF6F61) : Colors.white,
                    size: _currentIndex == 0
                        ? (screenWidth * 0.08)
                        : (screenWidth * 0.07),
                  ),
                  onPressed: () => _onItemTapped(0),
                ),
                IconButton(
                  icon: Icon(
                    Icons.calendar_month_rounded,
                    color:
                        _currentIndex == 1 ? Color(0xFFFF6F61) : Colors.white,
                    size: _currentIndex == 1
                        ? (screenWidth * 0.07)
                        : (screenWidth * 0.06),
                  ),
                  onPressed: () => _onItemTapped(1),
                ),

                // SizedBox(
                //   width: screenWidth * 0.15,
                // ),

                IconButton(
                  icon: Icon(
                    Icons.book_rounded,
                    color:
                        _currentIndex == 2 ? Color(0xFFFF6F61) : Colors.white,
                    size: _currentIndex == 2
                        ? (screenWidth * 0.065)
                        : (screenWidth * 0.055),
                  ),
                  onPressed: () => _onItemTapped(2),
                ),
                IconButton(
                  icon: Icon(
                    Icons.timer_outlined,
                    color:
                        _currentIndex == 3 ? Color(0xFFFF6F61) : Colors.white,
                    size: _currentIndex == 3
                        ? (screenWidth * 0.07)
                        : (screenWidth * 0.06),
                  ),
                  onPressed: () => _onItemTapped(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
//   Widget _buildBottomModalContent() {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;
//     return Container(
//       height: screenHeight * 0.3, // Adjust as needed
//       decoration: const BoxDecoration(
//         color: Color(0xff2A3143),
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(24),
//           topRight: Radius.circular(24),
//         ),
//       ),
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // "New Task" button
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 InkWell(
//                   onTap: () {
//                     showDialog(
//                       context: context,
//                       builder: (BuildContext context) {
//                         return const CreateTaskForm();
//                       },
//                     );
//                   },
//                   child: Container(
//                     width: screenWidth * 0.3,
//                     height: screenHeight * 0.08,
//                     decoration: const BoxDecoration(
//                       color: Color(0xFFFF6F61), // Orange color
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.note_add,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: screenHeight * 0.01),
//                 const Text(
//                   'New task',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ],
//             ),

//             SizedBox(
//               width: screenWidth * 0.2,
//             ),
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 InkWell(
//                   onTap: () {
//                     showDialog(
//                       context: context,
//                       builder: (BuildContext context) {
//                         return Dialog(
//                           child: AddReminderWidget(),
//                         );
//                       },
//                     );
//                   },
//                   child: Container(
//                     width: screenWidth * 0.3,
//                     height: screenHeight * 0.08,
//                     decoration: const BoxDecoration(
//                       color: Color(0xFFFF6F61),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.alarm,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: screenHeight * 0.01),
//                 const Text(
//                   'New reminder',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
