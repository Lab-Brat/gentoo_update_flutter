import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavBar extends StatefulWidget {
  final Function(int) onTabTapped;
  final int currentIndex;

  const BottomNavBar({super.key, required this.onTabTapped, required this.currentIndex});

  @override
  BottomNavBarState createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.computer, size: 20),
          label: 'Reports',
        ),
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.circleUser, size: 20),
          label: 'Profile',
        ),
      ],
      fixedColor: Colors.deepPurple,
      currentIndex: widget.currentIndex,
      onTap: widget.onTabTapped,
    );
  }
}
