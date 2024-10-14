

import 'package:app_7_11/screen/Sevenmap.dart';
import 'package:app_7_11/screen/Usermap.dart';
import 'package:app_7_11/screen/shoppingcart.dart';
import 'package:app_7_11/screen/testmap.dart';
import 'package:app_7_11/screen/user_sevenmap.dart';

class AppRouter {
  // Router mapkey

  static const String shoppingcart = 'shoppingcart';
  static const String testmap = 'testmap';
  static const String usermap = 'usermap';
  static const String sevenmap = 'sevenmap';
  static const String usersevenmap = 'usersevenmap';

  static get route => {
        shoppingcart: (context) => const Shoppingcart(),
        testmap: (context) => const Testmap(),
        usermap: (context) => const Usermap(),
        sevenmap: (context) => const Sevenmap(),
        usersevenmap: (context) => const UserSevenmap(),

      };
}