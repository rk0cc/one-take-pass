import 'dart:convert';

import 'package:dio/dio.dart';
//import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:one_take_pass_remake/api/url/localapiurl.dart';
import 'package:one_take_pass_remake/api/url/types.dart';
import 'package:one_take_pass_remake/api/userdata/login_request.dart';
import 'package:one_take_pass_remake/pages/reusable/qna.dart';
import 'package:one_take_pass_remake/themes.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

///E-Learning interface
///
class OTPELearning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: ListView(
        children: [
          _writtenTest(context),
          Padding(
              padding: EdgeInsets.only(top: 10, bottom: 2.5),
              child: Divider(color: colourPicker(128, 128, 128, 120))),
          _roadTest(context),
          Padding(padding: EdgeInsets.only(top: 10, bottom: 10)),
        ],
      ),
    );
  }
}

///Make sub-title
Text _subTitle(String title) {
  return Text(title,
      style: TextStyle(decoration: TextDecoration.underline, fontSize: 24));
}

///A completed module of the button
///
///Define [icon] symbol, then show button text in [label] and define functions in [onclick]
MaterialButton _elButton(IconData icon, String label, Function onclick) {
  return MaterialButton(
      padding: EdgeInsets.all(5),
      color: OTPColour.light1,
      child: Row(
        children: [
          Icon(icon, size: 24),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              label,
              style: TextStyle(fontSize: 20),
            ),
          )
        ],
      ),
      onPressed: onclick);
}

Future<List<dynamic>> getMarks() async {
  var dio = Dio();
  dio.options.headers['Content-Type'] = "application/json";
  var resp;
  try {
    resp = await dio.post(APISitemap.recentMockMark.toString(),
        data: jsonEncode(
            {"refresh_token": (await UserTokenLocalStorage.getToken())}));
  } on DioError catch (e) {
    if (e.response.data["msg"] == "The user did not submit a score before") {
      return [];
    } else {
      throw "Error from HTTP";
    }
  }

  return resp.data;
}

///Entire module of written test
Column _writtenTest(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _subTitle("Written Test"),
      //Text-only questions
      _elButton(FontAwesomeIcons.wordpressSimple, "Text-only Questions", () {
        QuestionPageHandler.start(context, 0, false);
      }),
      //End text-only question
      Padding(padding: EdgeInsets.all(10)),
      //Symbol questions
      _elButton(FontAwesomeIcons.road, "Symbol Questions", () {
        QuestionPageHandler.start(context, 1, false);
      }),
      //End symbol questions
      Padding(padding: EdgeInsets.all(10)),
      //Combine questions
      _elButton(FontAwesomeIcons.chartBar, "Combine Questions", () {
        QuestionPageHandler.start(context, 2, false);
      }),
      //End combine questions
      Padding(padding: EdgeInsets.all(10)),
      //Mock written test
      _elButton(FontAwesomeIcons.pencilRuler, "Mock Written Test", () {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  content: FutureBuilder<List<dynamic>>(
                      future: getMarks(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  child: Text(
                                    "Getting your last mock exam result",
                                    textAlign: TextAlign.center,
                                  ),
                                  padding: EdgeInsets.all(15),
                                ),
                                CircularProgressIndicator()
                              ],
                            ),
                          );
                        } else {
                          if (snapshot.hasData) {
                            int maxMark = 0;
                            snapshot.data.forEach((n) {
                              int c = 0;
                              //I can't belive this list contains integer ans string at the same time
                              try {
                                c = int.tryParse(n) ?? n;
                              } catch (isInt) {
                                c = n;
                              }
                              if (c > maxMark) {
                                maxMark = c;
                              }
                            });
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  (snapshot.data.isNotEmpty
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                              Padding(
                                                child: Text(
                                                  "Your best result is:",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      fontSize: 24),
                                                  textAlign: TextAlign.center,
                                                ),
                                                padding: EdgeInsets.all(15),
                                              ),
                                              Center(
                                                child: Text(
                                                  maxMark.toString(),
                                                  style:
                                                      TextStyle(fontSize: 36),
                                                  textAlign: TextAlign.center,
                                                ),
                                              )
                                            ])
                                      : Padding(
                                          child: Text(
                                              "This is your first time of the mock test",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 24),
                                              textAlign: TextAlign.center),
                                          padding: EdgeInsets.all(15),
                                        )),
                                ],
                              ),
                            );
                          } else {
                            return Center(
                              child: Padding(
                                child: Text(
                                  "Failed to get your mock text marks",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 24),
                                  textAlign: TextAlign.center,
                                ),
                                padding: EdgeInsets.all(15),
                              ),
                            );
                          }
                        }
                      }),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.red),
                        )),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: Text("Start mock test"))
                  ],
                )).then((startMock) {
          if (startMock) {
            QuestionPageHandler.start(context, 2, true);
          }
        });
      })
      //End mock written test
    ],
  );
}

Column _roadTest(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _subTitle("Road Test"),
      //Driving skill videos
      _elButton(FontAwesomeIcons.prayingHands, "Driving Skill Video", () {
        URLType.website.exec(
            "yuutube.com/playlist?list=1", // Replace it to youtube
            true);
      }),
      //End driving skill video
      Padding(padding: EdgeInsets.all(10)),
      //Road exam video
      _elButton(FontAwesomeIcons.car, "Road Exam Video", () {
        URLType.website.exec(
            "yuutube.com/playlist?list=2", // Replace it to youtube
            true);
      })
      //End road exam video
    ],
  );
}
