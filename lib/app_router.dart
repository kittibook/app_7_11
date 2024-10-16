

import 'package:app_7_11/screen/Sevenmap.dart';
import 'package:app_7_11/screen/Usermap.dart';
import 'package:app_7_11/screen/cart.dart';
import 'package:app_7_11/screen/shoppingcart.dart';
import 'package:app_7_11/screen/user_sevenmap.dart';

class AppRouter {
  // Router mapkey

  static const String shoppingcart = 'shoppingcart';
  static const String cart = 'cart';
  static const String usermap = 'usermap';
  static const String sevenmap = 'sevenmap';
  static const String usersevenmap = 'usersevenmap';

  static get route => {
        shoppingcart: (context) => const Shoppingcart(),
        cart: (context) => const Cart(),
        usermap: (context) => const Usermap(),
        sevenmap: (context) => const Sevenmap(),
        usersevenmap: (context) => const UserSevenmap(),

      };
}