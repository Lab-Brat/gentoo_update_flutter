import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavBar extends StatefulWidget {
  final Function(int) onTabTapped;
  final int currentIndex;

  BottomNavBar({required this.onTabTapped, required this.currentIndex});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
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
