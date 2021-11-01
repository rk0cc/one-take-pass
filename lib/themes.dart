import 'package:flutter/cupertino.dart' show CupertinoThemeData;
import 'package:flutter/cupertino.dart' show CupertinoColors;
import 'package:flutter/cupertino.dart' show CupertinoTextThemeData;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

///Customize which colour do you want
Color colourPicker(int r, int g, int b, [int alpha = 255]) {
  if (!_validColourRange(r) ||
      !_validColourRange(g) ||
      !_validColourRange(b) ||
      !_validColourRange(alpha))
    throw ("The RGBA range must be around 0 to 255");

  return Color.fromARGB(alpha, r, g, b);
}

///Verify does user follow 0 to 255 in [value]
bool _validColourRange(int value) {
  return value >= 0 && value <= 255;
}

class OTPColour {
  static final Color light1 = Color(0xff73a942);
  static final Color light2 = Color(0xffaad576);
  static final Color mainTheme = Color(0xff245501);
  static final Color dark1 = Color(0xff1a4301);
  static final Color dark2 = Color(0xff143601);
}

abstract class OTPThemeSetup {
  dynamic getInstanct();
  final String fontName = "NotoSans";
  static OTPThemeSetup apply() {
    throw ("This method should be called on sub class");
  }
}

class OTPMaterialTheme extends OTPThemeSetup {
  @override
  getInstanct() {
    return ThemeData(
        primaryColor: OTPColour.light1,
        accentColor: OTPColour.light2,
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        fontFamily: super.fontName);
  }

  static OTPThemeSetup apply() {
    return new OTPMaterialTheme();
  }
}

class OTPCupertinoTheme extends OTPThemeSetup {
  @override
  getInstanct() {
    return CupertinoThemeData(
        primaryColor: OTPColour.light1,
        brightness: Brightness.light,
        scaffoldBackgroundColor: CupertinoColors.white,
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(fontFamily: super.fontName),
        ));
  }

  static OTPThemeSetup apply() {
    return new OTPCupertinoTheme();
  }
}
