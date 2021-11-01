import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:one_take_pass_remake/api/calendar/calendar.dart';
import 'package:one_take_pass_remake/api/url/localapiurl.dart';
import 'package:one_take_pass_remake/api/userdata/login_request.dart';
import 'package:one_take_pass_remake/api/userdata/users.dart';
import 'package:one_take_pass_remake/pages/reusable/chatting.dart';
import 'package:one_take_pass_remake/pages/reusable/comment_review.dart';
import 'package:one_take_pass_remake/pages/subpages/export.dart';
import 'package:one_take_pass_remake/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

///A page about instructor
class InstructorInfo extends StatelessWidget {
  final Instructor instructor;

  InstructorInfo({@required this.instructor});

  ///Heading definitions
  Widget _heading(BuildContext context) {
    Widget _img(String url) {
      if (url != "") {
        return CircleAvatar(
          backgroundImage: NetworkImage(url),
          maxRadius: 36,
        );
      }
      return Container(
        child: Icon(
          CupertinoIcons.person,
          size: 48,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _img(""),
        Padding(padding: EdgeInsets.only(right: 10)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              instructor.name,
              style: TextStyle(fontSize: 24),
            ),
            //InstructorRating(context: context, rate: instructor.rating)
          ],
        )
      ],
    );
  }

  ///Show details of instructor
  Widget _details() {
    return Container(
      //color: OTPColour.light2,
      margin: EdgeInsets.only(top: 10, bottom: 5),
      padding: EdgeInsets.all(7.5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(7.5)),
          color: OTPColour.light2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Description: " + instructor.desc,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24)),
          Text("Personality: " + PersonalityGetter(instructor.personality).str,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
          /*Text(
              "Language: " +
                  SpeakingLanguageGetter(instructor.speakingLanguage).str,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300)),*/
          Text("District: " + HKDistrictGetter(instructor.hkDistrict).str,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300)),
          Text("Vehicles: " + instructor.vehicles,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(instructor.name),
      ),
      body: ListView(
        padding: EdgeInsets.only(left: 10, right: 10, top: 10),
        children: [
          _heading(context),
          _details(),
          Divider(color: colourPicker(128, 128, 128, 120)),
          Container(
            margin: EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width,
            child: MaterialButton(
              color: OTPColour.light1,
              onPressed: () async {
                var token = await UserTokenLocalStorage.getToken();

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatComm(
                              pickedRESTResult: {
                                "refresh_token": token,
                                "name": instructor.name,
                                "userPhoneNumber": instructor.userPhoneNumber
                              },
                              isStudent: true,
                            )));
              },
              child: Text("Open chat"),
            ),
          ),
          Container(
            margin: EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width,
            child: MaterialButton(
              color: OTPColour.light1,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CommentReviewPage(
                              targetPhone: instructor.userPhoneNumber,
                            )));
              },
              child: Text("His/Her comments"),
            ),
          ),
          Container(
            margin: EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width,
            child: MaterialButton(
              color: OTPColour.light1,
              onPressed: () {
                //Nothing now
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            CourseList(phoneNo: instructor.userPhoneNumber)));
              },
              child: Text("Get course"),
            ),
          )
        ],
      ),
    );
  }
}

class CourseList extends StatefulWidget {
  final String phoneNo;

  CourseList({@required this.phoneNo});

  Future<List<OwnedCoursesCalendar>> get coursesList async {
    List<OwnedCoursesCalendar> buffer = [];
    var dio = Dio();
    dio.options.headers["Content-Type"] = "application/json";
    var resp = await dio.post(APISitemap.courseControl("get").toString(),
        data: jsonEncode({
          "refresh_token": (await UserTokenLocalStorage.getToken()),
          "phoneno": phoneNo
        }));
    (resp.data as List<dynamic>).forEach((jsonObj) {
      buffer.add(OwnedCoursesCalendar.fromJson(jsonObj));
    });
    return buffer;
  }

  Future<void> applyCourses(OwnedCoursesCalendar courses) async {
    var dio = Dio();
    dio.options.headers["Content-Type"] = "application/json";
    await dio.post(APISitemap.courseControl("join").toString(),
        data: jsonEncode({
          "refresh_token": (await UserTokenLocalStorage.getToken()),
          "course_id": courses.id
        }));
  }

  @override
  State<StatefulWidget> createState() => _CourseList();
}

class _CourseList extends State<CourseList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Available courses"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<OwnedCoursesCalendar>>(
        future: widget.coursesList,
        builder: (context, result) {
          if (result.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (result.hasData) {
              return ListView.builder(
                  itemCount: result.data.length,
                  itemBuilder: (context, count) => Container(
                        width: MediaQuery.of(context).size.width,
                        height: 200,
                        margin: EdgeInsets.all(10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            border:
                                Border.all(width: 5, color: OTPColour.dark1)),
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    result.data[count].title,
                                    style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    "Type: " + result.data[count].vehicleType,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ]),
                            Positioned(
                              child: MaterialButton(
                                color: OTPColour.light1,
                                child: Text("Show timetable and apply"),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                            title: Text("Course timetable:"),
                                            content: Container(
                                              margin: EdgeInsets.all(5),
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: 300,
                                              child: ListView.builder(
                                                  itemCount: result.data[count]
                                                      .courseTime.length,
                                                  itemBuilder: (context,
                                                          timeCount) =>
                                                      Container(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text("From: " +
                                                                result
                                                                    .data[count]
                                                                    .courseTime[
                                                                        timeCount]
                                                                    .startTime),
                                                            Text("To: " +
                                                                result
                                                                    .data[count]
                                                                    .courseTime[
                                                                        timeCount]
                                                                    .endTime),
                                                            Divider(
                                                              thickness: 2.5,
                                                              color: OTPColour
                                                                  .dark2,
                                                              height: 5.0,
                                                            )
                                                          ],
                                                        ),
                                                      )),
                                            ),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(
                                                    "Cancel",
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  )),
                                              TextButton(
                                                  onPressed: () async {
                                                    await showDialog(
                                                        context: context,
                                                        barrierDismissible:
                                                            false,
                                                        builder:
                                                            (context) =>
                                                                AlertDialog(
                                                                  title: Text(
                                                                      "Decided to join this courses?"),
                                                                  actions: [
                                                                    TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child:
                                                                            Text(
                                                                          "No",
                                                                          style:
                                                                              TextStyle(color: Colors.red),
                                                                        )),
                                                                    TextButton(
                                                                        onPressed:
                                                                            () async {
                                                                          bool isSuccess = await widget
                                                                              .applyCourses(result.data[count])
                                                                              .then((_) => true)
                                                                              .onError((_, __) => false);
                                                                          if (isSuccess) {
                                                                            showDialog(
                                                                                context: context,
                                                                                builder: (context) => AlertDialog(
                                                                                      title: Text("You joined this course"),
                                                                                      actions: [
                                                                                        TextButton(
                                                                                            onPressed: () {
                                                                                              Navigator.pop(context);
                                                                                            },
                                                                                            child: Text("OK"))
                                                                                      ],
                                                                                    )).then((_) {
                                                                              Navigator.pop(context);
                                                                            });
                                                                          } else {
                                                                            showDialog(
                                                                                context: context,
                                                                                builder: (context) => AlertDialog(
                                                                                      title: Text("Joining course failed"),
                                                                                      actions: [
                                                                                        TextButton(
                                                                                            onPressed: () {
                                                                                              Navigator.pop(context);
                                                                                            },
                                                                                            child: Text("OK"))
                                                                                      ],
                                                                                    ));
                                                                          }
                                                                        },
                                                                        child: Text(
                                                                            "Yes")),
                                                                  ],
                                                                ));
                                                  },
                                                  child: Text("Join"))
                                            ],
                                          ));
                                },
                              ),
                              bottom: 5,
                              right: 5,
                            )
                          ],
                        ),
                      ));
            } else {
              return Center(
                  child: Column(children: [
                Icon(
                  CupertinoIcons.xmark_circle,
                  size: 120,
                ),
                Text("Unable to load instructor's courses")
              ]));
            }
          }
        },
      ),
    );
  }
}
