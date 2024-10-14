// ignore_for_file: prefer_typing_uninitialized_variables
import 'package:app_7_11/app_router.dart';
import 'package:app_7_11/utility.dart';
import 'package:flutter/material.dart';


// กำหนดตัวแปร initialRoute ให้กับ MaterialApp
var initialRoute;

void main() async {
  // ต้องเรียกใช้ WidgetsFlutterBinding.ensureInitialized()
  // เพื่อให้สามารถเรียกใช้ SharedPreferences ได้
  WidgetsFlutterBinding.ensureInitialized();

  // เรียกใช้ SharedPreferences
  await Utility.initSharedPrefs();

  initialRoute = AppRouter.usermap;



  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: AppRouter.route,
    );
  }
}