import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:one_take_pass_remake/api/url/localapiurl.dart';
import 'package:one_take_pass_remake/api/userdata/login_request.dart';
import 'package:one_take_pass_remake/pages/index.dart';
import 'package:one_take_pass_remake/api/misc.dart' show RegexLibraries;

class OTPLogin extends StatelessWidget {
  ///Check does user is doing login
  static bool _isLogin = true;

  ///Check authencation
  Future<String> _authUser(LoginData lD) async {
    _isLogin = true;
    UserInfoHandler uih = new UserInfoHandler(lD.name, lD.password);
    UserREST restData = await uih.getUserRest();
    switch (restData.roles) {
      case "errors_user":
        return "User not found or wrong password"; //When user not found
      case "errors_server":
        return "There is an error from server, please try again later"; //When server malfunction
      case "student":
      case "privateDrivingInstructor":
        return null; //Use null for success according to API reference
      case "staff":
        await UserTokenLocalStorage.clearToken();
        return "Staff account is not allowed to login the mobile app";
    }
    return "Unexpected role";
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
        title: "One Take Pass",
        onLogin: _authUser,
        onSignup: (lD) async {
          //Variable
          // ignore: avoid_init_to_null
          String errMsg = null;
          //int stage = 0;
          int gender = -1; //0 = male, 1 = female
          int role = -1; //0 = students, 1 = instructor
          String uname = ""; //Username
          //Methods
          ///Parse filled data to API
          Future<bool> doSignUp(String phoneNo, String pwd, int gender,
              int role, String uname) async {
            //int code to str placeholder
            String genderInStr;
            String roleInStr;

            //Convert int code to string
            //Gender
            switch (gender) {
              case 0:
                genderInStr = "M";
                break;
              case 1:
                genderInStr = "F";
                break;
            }
            //Roles
            switch (role) {
              case 0:
                roleInStr = "student";
                break;
              case 1:
                roleInStr = "privateDrivingInstructor";
                break;
            }

            //API caller
            var dio = Dio();
            dio.options.headers["Content-Type"] = "application/json";
            var signUpResp = await dio.post(APISitemap.signup.toString(),
                data: jsonEncode({
                  "phoneno": phoneNo,
                  "password": pwd,
                  "username": uname,
                  "gender": genderInStr,
                  "type": roleInStr
                }));
            if (signUpResp.statusCode >= 400) {
              return false;
            }
            //Should be more handler
            return true;
          }

          //Function behaviours
          await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => SimpleDialog(
                    title: Text("Gender"),
                    children: [
                      SimpleDialogOption(
                        child: Text("Male"),
                        onPressed: () {
                          gender = 0;
                          Navigator.pop(context);
                        },
                      ),
                      SimpleDialogOption(
                        child: Text("Female"),
                        onPressed: () {
                          gender = 1;
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ));
          await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => SimpleDialog(
                    title: Text("Roles"),
                    children: [
                      SimpleDialogOption(
                        child: Text("Student"),
                        onPressed: () {
                          role = 0;
                          Navigator.pop(context);
                        },
                      ),
                      SimpleDialogOption(
                        child: Text("Instructor"),
                        onPressed: () {
                          role = 1;
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ));
          await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                final _unameIbxCtrl = TextEditingController();
                return SimpleDialog(
                  title: Text("Username"),
                  children: [
                    Container(
                      margin: EdgeInsets.all(10),
                      child: TextField(
                        controller: _unameIbxCtrl,
                        textAlign: TextAlign.left,
                        minLines: 1,
                        maxLines: 1,
                        decoration: InputDecoration(hintText: "Username"),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.all(5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            child: Text("Submit"),
                            onPressed: () {
                              uname = _unameIbxCtrl.text ?? "";
                              //Ignore space from start
                              uname.replaceAll(
                                  RegexLibraries.whiteSpaceOnStart, "");
                              Navigator.pop(context);
                            },
                          )
                        ],
                      ),
                    )
                  ],
                );
              });
          _isLogin = false;
          //When user incompleted sign up required infos
          if (gender == -1 || role == -1 || uname == "") {
            errMsg = "Please complete all selections of the dialogs";
            return errMsg;
          }
          // When user filled all
          return (await doSignUp(lD.name, lD.password, gender, role, uname))
              ? null
              : "There is an error when submitting to server";
        },
        onSubmitAnimationCompleted: () {
          if (_isLogin) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => OTPIndex()));
          } else {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title:
                          Text("Your account has been created successfully!"),
                      actions: [
                        TextButton(
                            onPressed: () {
                              requireLogin(ModalRoute.of(context), context);
                            },
                            child: Text("Back to login page"))
                      ],
                    ));
          }
        },
        onRecoverPassword: (_) {
          Future<String> getMsg() async {
            return Future.delayed(Duration(seconds: 1)).then((_) =>
                "Currently we may not handle forget password function, please content customer service if encounter login problems.");
          }

          return getMsg();
        },
        messages: LoginMessages(
          usernameHint: "Phone No.",
        ),
        emailValidator: (phoneNo) =>
            _isPhoneNum(phoneNo) ? null : "Please enter valid phone number");
  }
}

///Trigger login if user is not login yet
void requireLogin(Route currentRoute, BuildContext context) {
  OTPIndex.showCommentDialog = true;
  //Naviaate
  Navigator.replace(context,
      oldRoute: currentRoute,
      newRoute: MaterialPageRoute(builder: (context) => OTPLogin()));
}

///Verify [input] which email originally is insert phone number
bool _isPhoneNum(String input) {
  if (input == null) {
    return false;
  } else if (input.length < 8) {
    return false;
  }
  int intPhoneNo = int.tryParse(input);
  if (intPhoneNo != null) {
    if (intPhoneNo >= 0) {
      return true;
    }
  }
  return false;
}
