import 'package:get/get.dart';
import 'package:ranyacity/Pages/Admin/Auth/Pages/login_screen.dart';
import 'package:ranyacity/Pages/Admin/Auth/Pages/signup_screen.dart';
import 'package:ranyacity/Pages/Admin/Form/new_place_screen.dart';
import 'package:ranyacity/Pages/home_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
  static const newPlace = '/newPlace';

  static final routes = [
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: signup, page: () => SignupScreen()),
    GetPage(name: home, page: () => HomeScreen()),
    GetPage(name: newPlace, page: () => NewPlaceScreen()),
  ];
}
