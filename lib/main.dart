import 'package:flutter/cupertino.dart' show DefaultCupertinoLocalizations;
import 'package:flutter/material.dart';
import 'package:one_take_pass_remake/pages/index.dart';
import 'package:one_take_pass_remake/themes.dart';

final RouteObserver<MaterialPageRoute> routeObserver =
    new RouteObserver<MaterialPageRoute>();

///Rebuild version of one take pass for fitting chatting functions
void main() {
  runApp(OneTakePass());
}

class OneTakePass extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'One Take Pass',
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate, //Remain iOS theme there
        DefaultWidgetsLocalizations.delegate
      ],
      theme: OTPMaterialTheme.apply().getInstanct(),
      home: OTPIndex(),
      navigatorObservers: [routeObserver],
    );
  }
}
