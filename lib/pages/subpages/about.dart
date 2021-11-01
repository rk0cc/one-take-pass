import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:one_take_pass_remake/api/url/localapiurl.dart';
import 'package:one_take_pass_remake/api/userdata/gender.dart';
import 'package:one_take_pass_remake/api/userdata/login_request.dart';
import 'package:one_take_pass_remake/main.dart' show routeObserver;
import 'package:one_take_pass_remake/pages/index.dart' show UserIdentify;
import 'package:one_take_pass_remake/pages/login.dart';
import 'package:one_take_pass_remake/pages/reusable/comment_review.dart';
import 'package:one_take_pass_remake/pages/reusable/indentity_widget.dart';
//import 'package:one_take_pass_remake/pages/reusable/link_google.dart';
import 'package:one_take_pass_remake/themes.dart';

class OTPAbout extends StatefulWidget with IdentityWidget {
  OTPAbout(UserREST identity) {
    this.currentIdentity = identity;
  }

  @override
  State<StatefulWidget> createState() => _OTPAbout();
}

///Get current username from server, [UserIdentify] just verify is user existed
Future<String> get _currentUsername async {
  return (await UserAPIHandler.getUserRest(
          await UserTokenLocalStorage.getToken()))
      .fullName;
}

class _OTPAbout extends State<OTPAbout> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    setState(() {});
  }

  //_GoogleLink _gl = new _GoogleLink();
  //bool _status = true;
  @override
  Widget build(BuildContext context) {
    final List<Widget> content = [
      Padding(padding: EdgeInsets.only(top: 10)),
      Expanded(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: 120,
            ),
            FutureBuilder<String>(
              future: _currentUsername,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    snapshot.data,
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w300),
                  );
                } else {
                  //Return nothing if failed
                  return Text("",
                      style:
                          TextStyle(fontSize: 36, fontWeight: FontWeight.w300));
                }
              },
            )
          ],
        ),
      )),
    ];
    if (widget.roleName == "student") {
      content.add(Container(
        width: MediaQuery.of(context).size.width - 10,
        child: MaterialButton(
          padding: EdgeInsets.all(10),
          color: OTPColour.mainTheme,
          child: Text("Your comments",
              style: TextStyle(fontSize: 16, color: Colors.white)),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => CommentReviewPage()));
          },
        ),
      ));
    }
    content.addAll([
      Container(
        width: MediaQuery.of(context).size.width - 10,
        child: MaterialButton(
          padding: EdgeInsets.all(10),
          color: OTPColour.mainTheme,
          child: Text("Edit profile",
              style: TextStyle(fontSize: 16, color: Colors.white)),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => EditProfile()));
          },
        ),
      ),
      Container(
        width: MediaQuery.of(context).size.width - 10,
        child: MaterialButton(
          padding: EdgeInsets.all(10),
          color: OTPColour.mainTheme,
          child: Text("Logout",
              style: TextStyle(fontSize: 16, color: Colors.white)),
          onPressed: () {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                      title: Text("Logout"),
                      content: Text("Do you want to logout?"),
                      actions: <Widget>[
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
                            child: Text("No"))
                      ],
                    )).then((doLogout) {
              //Check returned data that is required logout
              if (doLogout) {
                UserTokenLocalStorage.clearToken().then((_) {
                  requireLogin(ModalRoute.of(context), context);
                });
              }
            });
          },
        ),
      )
    ]);
    return Center(child: Column(children: content));
  }
}

/*class _GoogleLink {
  bool _islinked = false;
  bool get status {
    return _islinked;
  }
}*/

class EditProfile extends StatefulWidget {
  bool _canEdit = false;

  ///To signal that can be editable
  void setEditable() {
    _canEdit = true;
  }

  @override
  State<StatefulWidget> createState() => _EditProfile();
}

class _EditProfile extends State<EditProfile> {
  String _recentUsername;
  TextEditingController _nameController;
  Map<String, TextEditingController> _npwdInputCtrl, _phoneCtrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _npwdInputCtrl = {
      "password": TextEditingController(),
      "confirm": TextEditingController()
    };
    _phoneCtrl = {
      "oldNum": TextEditingController(),
      "newNum": TextEditingController()
    };
  }

  @override
  void dispose() {
    _nameController.dispose();
    _npwdInputCtrl.forEach((_, value) {
      value.dispose();
    });
    _phoneCtrl.forEach((_, value) {
      value.dispose();
    });
    super.dispose();
  }

  Widget optionUI(UserREST receivedInfo) {
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10, top: 5),
      child: ListView(
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: "Name"),
            maxLines: 1,
            maxLength: 255,
            enableSuggestions: false,
            autocorrect: false,
          ),
          Divider(),
          Text(
            "Change Password",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
          ),
          TextField(
            controller: _npwdInputCtrl["password"],
            decoration: InputDecoration(labelText: "New password"),
            maxLines: 1,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
          ),
          Padding(padding: EdgeInsets.only(top: 10, bottom: 10)),
          TextField(
            controller: _npwdInputCtrl["confirm"],
            decoration: InputDecoration(labelText: "Confirm new password"),
            maxLines: 1,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
          ),
          Container(
              width: MediaQuery.of(context).size.width,
              height: 120,
              child: MaterialButton(
                child: Text("Change phone number request"),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => SimpleDialog(
                            title: Text("Change phone number request"),
                            children: [
                              Padding(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  child: Text(
                                      "Please provide old phone number and the new number will be used for login, our customer service will handle your request as soon as possible.")),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: TextField(
                                  controller: _npwdInputCtrl["oldNum"],
                                  decoration: InputDecoration(
                                      hintText: "Old phone number"),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: TextField(
                                  controller: _npwdInputCtrl["newNum"],
                                  decoration: InputDecoration(
                                      hintText: "New phone number"),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                ),
                              )
                            ],
                          ));
                },
              ))
          /*
          Container(
            margin: EdgeInsets.only(top: 100),
            width: MediaQuery.of(context).size.width,
            child: MaterialButton(
              color: Colors.red,
              padding: EdgeInsets.all(10),
              child: Text(
                "Long press to delete account",
                style: TextStyle(fontSize: 18),
              ),
              onPressed: () {},
              onLongPress: () async {
                bool _confirmDelete = false;

                void doPop(BuildContext context) {
                  Navigator.pop(context);
                }

                void onYes(BuildContext context) {
                  _confirmDelete = true;
                  doPop(context);
                }

                void onNo(BuildContext context) {
                  _confirmDelete = false;
                  doPop(context);
                }

                await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: Text("Delete Account"),
                          content: Text("Ensure to delete account?"),
                          actions: [
                            TextButton(
                                onPressed: () => onYes(context),
                                child: Text(
                                  "Yes",
                                  style: TextStyle(color: Colors.red),
                                )),
                            TextButton(
                                onPressed: () => onNo(context),
                                child: Text("No"))
                          ],
                        ));

                if (_confirmDelete) {
                  await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text("Delete Account"),
                            content: Text(
                                "Your data will not be recovered after deleted, continue?"),
                            actions: [
                              TextButton(
                                  onPressed: () => onYes(context),
                                  child: Text(
                                    "Yes",
                                    style: TextStyle(color: Colors.red),
                                  )),
                              TextButton(
                                  onPressed: () => onNo(context),
                                  child: Text("No"))
                            ],
                          ));
                  if (_confirmDelete) {
                    String currentToken =
                        await UserTokenLocalStorage.getToken();
                    try {
                      var dio = Dio();
                      dio.options.headers["Content-Type"] = "application/json";
                      var resp = await dio.post(
                          APISitemap.deleteUser.toString(),
                          data: jsonEncode({
                            "refresh_token": currentToken,
                            "userPhoneNumber": receivedInfo.phoneNo
                          }));
                      if (resp.statusCode >= 400) {
                        throw "HTTP error";
                      }
                      await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: Text("You account has been deleted"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text("OK"))
                                ],
                              )).then((_) {
                        UserTokenLocalStorage.clearToken().then((_) {
                          requireLogin(ModalRoute.of(context), context);
                        });
                      });
                    } catch (e) {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: Text("Delete Account failed"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text("OK"))
                                ],
                              ));
                    }
                  }
                }
              },
            ),
          ),*/
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Edit profile"),
          centerTitle: true,
          actions: [
            TextButton(
                onPressed: () async {
                  Future<Map<String, dynamic>> getInputData() async {
                    bool errByMismatchedPwd = false;
                    final reqBody = {
                      "refresh_token": "",
                    };
                    if (_npwdInputCtrl["password"].text.isNotEmpty &&
                        _npwdInputCtrl["confirm"].text.isNotEmpty) {
                      errByMismatchedPwd = (_npwdInputCtrl["password"].text !=
                          _npwdInputCtrl["confirm"].text);
                      if (errByMismatchedPwd) {
                        await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Text("Password mismatched"),
                                  content: Text(
                                      "Please confirm you are entered the same password in confirm field."),
                                ));
                        return null;
                      } else {
                        reqBody["password"] = _npwdInputCtrl["password"].text;
                      }
                    }
                    if (_nameController.text.isNotEmpty &&
                        _nameController.text != _recentUsername) {
                      reqBody["name"] = _nameController.text;
                    }
                    return reqBody;
                  }

                  var actualresp = "";

                  String token = await UserTokenLocalStorage.getToken();
                  final Map<String, dynamic> _editedForm = await getInputData();
                  if (_editedForm != null) {
                    _editedForm["refresh_token"] = token;
                    var dio = Dio();
                    dio.options.headers['Content-Type'] = "application/json";

                    try {
                      await dio.post(APISitemap.updateInfo.toString(),
                          data: jsonEncode(_editedForm));
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: Text("Your record has been updated"),
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
                    } catch (err) {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: Text("Update failed"),
                                content:
                                    Text("Try again later.\n" + actualresp),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text("OK"))
                                ],
                              ));
                    }
                  }
                },
                child: Text(
                  "Save",
                  style: TextStyle(color: OTPColour.dark1),
                ))
          ],
        ),
        body: FutureBuilder<UserREST>(
          future: (<UserREST>() async {
            return await UserAPIHandler.getUserRest(
                await UserTokenLocalStorage.getToken());
          })(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _recentUsername = _nameController.text = snapshot.data.fullName;
              return optionUI(snapshot.data);
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  children: [
                    Icon(CupertinoIcons.xmark_circle, size: 120),
                    Text(
                      "We can not get your data right now,\ntry again later",
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              );
            } else {
              return Container();
            }
          },
        ));
  }
}
