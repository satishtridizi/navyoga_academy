import 'package:flutter/material.dart';
import 'package:navyoga_academy/screens/myclasses.dart';

class AppRoutes {
  static const myClasses = '/my-classes';

  static Map<String, WidgetBuilder> routes = {
    myClasses: (context) => const MyClassesScreen(),
  };
}
