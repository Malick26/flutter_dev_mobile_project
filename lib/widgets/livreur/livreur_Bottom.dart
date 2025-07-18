import 'package:flutter/material.dart';
import '../../screens/home/chats_page.dart';
import '../../screens/livreur/history.dart';
import '../../screens/home/homeScreen.dart';
import '../../color.dart';
class LivreurBottomBar extends StatefulWidget {
  @override
  State<LivreurBottomBar> createState() => _LivreurBottomBarState();
}

class _LivreurBottomBarState extends State<LivreurBottomBar> {
  int myIndex = 0;

  List<Widget> widgetList = const [
    HomePage(),
    Livreur(),
    SettingPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        children: widgetList,
        index: myIndex,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: 20,
        iconSize: 20,
        selectedIconTheme: IconThemeData(color: AppColors.quatre, size: 40),
        selectedItemColor: AppColors.quatre,
        unselectedIconTheme: IconThemeData(color: AppColors.three),
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        backgroundColor: AppColors.one,
        onTap: (index) {
          setState(() {
            myIndex = index;
          });
        },
        currentIndex: myIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_toggle_off),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Reglage',
          ),
        ],
      ),
    );
  }
}
