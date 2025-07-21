import 'dart:convert';
import 'package:dev_mobile/screens/auth/loginScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dev_mobile/widgets/livreur/livreur_bottom.dart';
import 'package:dev_mobile/widgets/navbar_bottom.dart';

class InitScreen extends StatefulWidget {
  @override
  _InitScreenState createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userString = prefs.getString('user');

    if (token != null && userString != null) {
      final user = jsonDecode(userString);
      final role = user['role'];

      if (role == 'livreur') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LivreurBottomBar()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => bottomBar()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
