import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:one_take_pass_remake/api/calendar/calendar.dart';
import 'package:one_take_pass_remake/api/url/localapiurl.dart';
import 'package:one_take_pass_remake/api/userdata/login_request.dart';
import 'package:one_take_pass_remake/themes.dart';

class CourseEventPage extends StatefulWidget {
  final bool isStudent;
  final PersonalCourseEvent event;
  CourseEventPage({@required this.event, this.isStudent = false});

  @override
  State<StatefulWidget> createState() => _CourseEventPage();
}

class _CourseEventPage extends State<CourseEventPage> {
  TextEditingController _pin;

  Container _infoContainer(List<Widget> infoWidget) {
    return Container(
      margin: EdgeInsets.only(top: 5, bottom: 5),
      padding: EdgeInsets.all(7.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(3)),
        color: OTPColour.light2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: infoWidget,
      ),
    );
  }

  void Function() get btnEvent => widget.isStudent
      ? () async {
          var token = await UserTokenLocalStorage.getToken();
          var dio = Dio();
          dio.options.headers["Content-Type"] = "application/json";
          dio
              .post(APISitemap.attendEvent.toString(),
                  data: jsonEncode(
                      {"refresh_token": token, "cal_id": widget.event.id}))
              .then((resp) {
            dio.post(APISitemap.chatControl("send_msg").toString(),
                data: jsonEncode({
                  "refresh_token": token,
                  "msg": "The code of '" +
                      widget.event.title +
                      "' on " +
                      DateFormat("d MMMM yyyy").format(
                          widget.event.range.parsedToDateTime["start"]) +
                      " is:\n\n" +
                      resp.data["code"],
                  "to": widget.event.insPhono
                }));
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => AlertDialog(
                      title: Text("The course is started"),
                      content: Column(
                        children: [
                          Text("Please show this code to the instructor:"),
                          Text(
                            resp.data["code"],
                            style: TextStyle(
                                fontSize: 36, fontWeight: FontWeight.w400),
                          )
                        ],
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Close"))
                      ],
                    )).then((_) {
              Navigator.pop(context);
            });
          }).catchError(() {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => AlertDialog(
                      title: Text("Unable to send course start request"),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Close"))
                      ],
                    ));
          });
        }
      : () async {
          if (_pin.text.isNotEmpty) {
            var dio = Dio();
            dio.options.headers["Content-Type"] = "application/json";
            dio
                .post(APISitemap.attendEvent.toString(),
                    data: jsonEncode({
                      "refresh_token": (await UserTokenLocalStorage.getToken()),
                      "cal_id": widget.event.id,
                      "id_code": _pin.text
                    }))
                .then((_) {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text("Starting course confirmed"),
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
            }).onError((_, __) {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text("Starting course failed"),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("OK"))
                        ],
                      ));
            });
          }
        };

  @override
  void initState() {
    super.initState();
    _pin = TextEditingController();
  }

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> view = <Widget>[
      _infoContainer([
        Text("Date:",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500)),
        Text(
          DateFormat("EEEE, d MMMM yyyy")
              .format(widget.event.range.parsedToDateTime["start"]),
          style: TextStyle(fontSize: 18),
        )
      ]),
      _infoContainer([
        Text("Time:",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500)),
        Text(
          (DateFormat.Hm()
                  .format(widget.event.range.parsedToDateTime["start"]) +
              " - " +
              DateFormat.Hm()
                  .format(widget.event.range.parsedToDateTime["stop"])),
          style: TextStyle(fontSize: 18),
        )
      ]),
      _infoContainer([
        Text((widget.isStudent ? "Instructor" : "Student") + "'s phone number:",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
        Text(
          widget.isStudent ? widget.event.insPhono : widget.event.stdPhono,
          style: TextStyle(fontSize: 18),
        )
      ]),
      Divider(
        height: 10,
        thickness: 2.5,
      )
    ];
    if (!widget.isStudent) {
      view.add(TextField(
        controller: _pin,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        maxLines: 1,
        decoration: InputDecoration(labelText: "Course start code"),
      ));
    }
    view.add(Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(7.5),
      child: MaterialButton(
        padding: EdgeInsets.all(12),
        color: OTPColour.light1,
        child: Text(
          "Start course",
          style: TextStyle(fontSize: 24),
        ),
        onPressed: (widget.event.status == "not start") ? btnEvent : null,
      ),
    ));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.title),
        centerTitle: true,
      ),
      body: Container(
        margin: EdgeInsets.all(5),
        child: ListView(children: view),
      ),
    );
  }
}
