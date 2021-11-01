import 'package:dio/dio.dart';

class RegexLibraries {
  static RegExp get emailPattern => RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  static RegExp get whiteSpaceOnStart => RegExp(r"^\s{0,}");
}

class CourseRating {
  static Future<void> markAttandence() async {}
}
