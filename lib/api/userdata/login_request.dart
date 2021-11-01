import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:one_take_pass_remake/api/url/localapiurl.dart';
import 'package:shared_preferences/shared_preferences.dart';

///User data from REST
class UserREST {
  final String phoneNo;
  final String roles;
  final String fullName;

  UserREST({this.phoneNo, this.roles, this.fullName});

  factory UserREST.fromJSON(Map<String, dynamic> json) {
    return UserREST(
        phoneNo: json['phoneNo'],
        roles: json['type'],
        fullName: json['u_name']);
  }

  Map<String, dynamic> toJson() =>
      {'phoneNo': phoneNo, 'type': roles, 'u_name': fullName};
}

class UserInfoHandler {
  String _phone;
  String _pwd;

  UserInfoHandler(String phone, String pwd) {
    this._phone = phone;
    this._pwd = pwd;
  }

  Future<UserREST> getUserRest() async {
    try {
      //Get token from server
      String _token =
          await UserAPIHandler.getToken({'phoneno': _phone, 'password': _pwd});
      try {
        //Save to shared prefs first, it will be clear if not
        await UserTokenLocalStorage.saveToken(_token);
        var uresp = await UserAPIHandler.getUserRest(_token);
        return uresp; //Auto convert from json to object
      } catch (nouser) {
        return UserREST(phoneNo: "", roles: "errors_user", fullName: "");
      }
    } catch (e) {
      return UserREST(fullName: "", phoneNo: "", roles: "errors_server");
    }
  }
}

///A handler that getting API data
class UserAPIHandler {
  ///Get token
  static Future<String> getToken(Map<String, dynamic> jsonLogin) async {
    var dio = Dio();
    dio.options.headers['Content-Type'] = "application/json";
    var r = await dio.post(APISitemap.signin.toString(), //Token response
        data: jsonEncode(jsonLogin));
    if (r.statusCode >= 400) {
      throw "Server error";
    }
    return r.data['server_token'];
  }

  ///User user info
  static Future<UserREST> getUserRest(String token) async {
    var dio = Dio();
    dio.options.headers['Content-Type'] = "application/json";
    var r = await dio.post(APISitemap.fetchUserViaToken.toString(),
        data: jsonEncode({"refresh_token": token}));
    if (r.statusCode >= 400) {
      throw "Server error";
    }
    return UserREST.fromJSON(r.data);
  }
}

///Local storage controller for managing token
class UserTokenLocalStorage {
  ///Key name for definition
  static final String _define = "otp_user_token";

  ///Save the token string
  static Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_define, token);
  }

  ///Get the token string
  static Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_define);
  }

  ///Wipe token string
  static Future<void> clearToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(_define);
  }
}
