import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(
            FontAwesomeIcons.computer,
            size: 20,
          ),
          label: 'Reports',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            FontAwesomeIcons.bolt,
            size: 20,
          ),
          label: 'About',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            FontAwesomeIcons.circleUser,
            size: 20,
          ),
          label: 'Profile',
        ),
      ],
      fixedColor: Colors.deepPurple,
      onTap: (int idx) {
        switch (idx) {
          case 0:
            break;
          case 1:
            Navigator.pushNamed(context, '/about');
            break;
          case 2:
            Navigator.pushNamed(context, '/profile');
            break;
        }
      },
    );
  }
}
