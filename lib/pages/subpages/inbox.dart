import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:one_take_pass_remake/api/url/localapiurl.dart';
import 'package:one_take_pass_remake/api/userdata/login_request.dart';
import 'package:one_take_pass_remake/pages/reusable/chatting.dart';
import 'package:one_take_pass_remake/pages/reusable/indentity_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

final String contentKey = "otp_chat_name";

class OTPInbox extends StatefulWidget with IdentityWidget {
  StreamController<List<dynamic>> contactStream =
      StreamController<List<dynamic>>();

  OTPInbox(UserREST rest) {
    this.currentIdentity = rest;
  }

  @override
  State<StatefulWidget> createState() => _OTPInbox();

  bool get isStudent => roleName == "student";
}

class _OTPInbox extends State<OTPInbox> {
  Timer t;
  @override
  void initState() {
    super.initState();
    var dio = Dio();
    dio.options.headers["Content-Type"] = "application/json";
    t = Timer.periodic(Duration(seconds: 1), (timer) async {
      dio
          .post(APISitemap.chatControl("get_contact").toString(),
              data: jsonEncode(
                  {"refresh_token": (await UserTokenLocalStorage.getToken())}))
          .then((resp) {
        if (!widget.contactStream.isClosed && resp.data != null) {
          widget.contactStream.sink.add(resp.data);
        }
      }).onError((error, stackTrace) {});
    });
  }

  @override
  void dispose() {
    t.cancel();
    widget.contactStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
        stream: widget.contactStream.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, count) => MaterialButton(
                    padding: EdgeInsets.all(15),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person,
                            size: 48,
                          ),
                          Text(
                            snapshot.data[count]["name"],
                            style: TextStyle(fontSize: 16),
                          )
                        ]),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatComm(
                                  pickedRESTResult: snapshot.data[count],
                                  isStudent: widget.isStudent)));
                    }));
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    (widget.isStudent ? "Instructors" : "Students") +
                        " will be appeared when you found and started chatting",
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            );
          }
        });
  }
}
