import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('mobile_token');
  
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: token != null ? const HomeScreen() : const AuthScreen(),
    ),
  );
}