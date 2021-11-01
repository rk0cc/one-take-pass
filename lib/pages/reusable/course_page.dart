import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:one_take_pass_remake/api/calendar/calendar.dart';
import 'package:one_take_pass_remake/api/url/localapiurl.dart';
import 'package:one_take_pass_remake/api/userdata/login_request.dart';

class CourseDetailPage extends StatelessWidget {
  final OwnedCoursesCalendar course;
  CourseDetailPage({@required this.course});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(course.title),
          centerTitle: true,
        ),
        body: Container(
          margin: EdgeInsets.all(10),
          child: Stack(children: [
            Container(
              margin: EdgeInsets.only(bottom: 130),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: ListView(children: [
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Vehicle Type: ",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w500),
                      ),
                      Text(course.vehicleType)
                    ],
                  ),
                ),
                Divider(),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Student phone number: ",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w500),
                      ),
                      Text(course.studentPhone)
                    ],
                  ),
                ),
                Divider(),
              ]),
            ),
            Positioned(
                height: 50,
                bottom: 5,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: MaterialButton(
                    onPressed: () async {
                      bool cont = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: Text(
                                    "The course will been deleted, continue?"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, true);
                                      },
                                      child: Text(
                                        "Yes",
                                        style: TextStyle(color: Colors.red),
                                      )),
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, false);
                                      },
                                      child: Text("No")),
                                ],
                              ));
                      if (cont) {
                        var dio = Dio();
                        dio.options.headers["Content-Type"] =
                            "application/json";
                        var doClose = await dio
                            .post(APISitemap.courseControl("delete").toString(),
                                data: jsonEncode({
                                  "refresh_token":
                                      (await UserTokenLocalStorage.getToken()),
                                  "course_id": course.id
                                }))
                            .then((_) async {
                          return await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: Text("Course has been deleted"),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, true);
                                          },
                                          child: Text("OK"))
                                    ],
                                  ));
                        }).onError((_, __) async {
                          return await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: Text("Delete failed"),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, false);
                                          },
                                          child: Text("OK"))
                                    ],
                                  ));
                        });
                        if (doClose) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: Text("Delete course"),
                    color: Colors.red,
                  ),
                ))
          ]),
        ));
  }
}
