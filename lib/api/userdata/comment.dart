import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:one_take_pass_remake/api/url/localapiurl.dart';
import 'package:one_take_pass_remake/api/userdata/login_request.dart';

class OTPComment {
  final String username, content;
  OTPComment({this.username, this.content});

  factory OTPComment.fromJson(Map<String, dynamic> json) =>
      OTPComment(username: json["username"], content: json["content"]);
}

class UserComments {
  String _targetPhone;
  UserComments([String targetPhone]) {
    this._targetPhone = targetPhone;
  }

  Future<List<OTPComment>> get commentList async {
    var req = {};
    List<OTPComment> cL = [];
    req["refresh_token"] = await UserTokenLocalStorage.getToken();
    bool hasPhone = _targetPhone?.isNotEmpty ?? false;
    if (hasPhone) {
      req["phoneno"] = _targetPhone;
    }
    //print(jsonEncode(req));
    var dio = Dio();
    dio.options.headers["Content-Type"] = "application/json";
    var resp;
    try {
      resp = await dio.post(APISitemap.userComment.toString(),
          data: jsonEncode(req));
      (resp.data as List<dynamic>).forEach((cObj) {
        cL.add(OTPComment.fromJson(cObj));
      });
      return cL;
    } on DioError catch (e) {
      if (e.response.data["msg"] == "The user was not commented on") {
        return [];
      } else {
        throw e;
      }
    }
  }
}
