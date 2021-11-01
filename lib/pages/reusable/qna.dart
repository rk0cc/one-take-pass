import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:one_take_pass_remake/api/elearning/questions.dart';
import 'package:one_take_pass_remake/api/url/localapiurl.dart';
import 'package:one_take_pass_remake/api/userdata/login_request.dart'
    show UserTokenLocalStorage;
import 'package:one_take_pass_remake/themes.dart';

final Color _adjustedRed = colourPicker(200, 120, 120);

///Question handler between API and App
///
class QuestionPageHandler {
  final int mode;
  QuestionPageHandler({@required this.mode});

  Future<List<Question>> _loadQuestion() async {
    var dio = Dio();
    var _qHttp = await dio.get(APISitemap.getAns(mode).toString());
    List<dynamic> _qR = _qHttp.data;
    //print(_qR);
    List<Question> _qOs = [];
    switch (mode) {
      case 0:
        //Text only
        _qR.forEach((q) {
          _qOs.add(TextQuestion.fromJSON(q));
        });
        break;
      case 1:
        //Symbol only
        _qR.forEach((q) {
          _qOs.add(SymbolQuestion.fromJSON(q));
        });
        break;
      case 2:
        //Combine & mock
        _qR.forEach((q) {
          _qOs.add(Question.autoParseFromJSON(q));
        });
    }
    return _qOs;
  }

  ///Instance start with API handler
  static void start(BuildContext context, int mode, bool isMock) {
    new QuestionPageHandler(mode: mode)._loadQuestion().then((qL) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => QuestionPage(
                    questions: qL,
                    mockMode: isMock,
                  )));
    });
  }
}

///The page that displaying questions
class QuestionPage extends StatefulWidget {
  final List<Question> questions;

  ///Mock exam mode
  final bool mockMode;

  QuestionPage({@required this.questions, @required this.mockMode});

  @override
  State<StatefulWidget> createState() =>
      mockMode ? _MockExamQuestion() : _PractiseQuestion();
}

///UI of QuestionPage
abstract class _QuestionPage extends State<QuestionPage> {
  static bool _isTesting = true;
  Queue<Question> _qS;
  Question _q;
  int correctCount = 0, totalQuestion;

  ///Toggle next question
  void _nextQuestion() {
    try {
      _q = _qS.removeFirst();
    } catch (ended) {
      _q = null;
    }
    setState(() {});
  }

  ///Question number
  int get _questionNo {
    return totalQuestion - _qS.length;
  }

  @override
  void initState() {
    _qS = Queue.from(widget.questions);
    totalQuestion = widget.questions.length;
    super.initState();
    _nextQuestion();
  }

  ///When user ask correct answer
  void onCorrect();

  ///When user ask wrong answer with [actualAnswer]
  void onWrong(String actualAnswer);

  ///Display data on this test when all question is asked
  Widget allDonePage();

  ///Ask question
  Widget _showQuestion(Question q) {
    _isTesting = true;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
            child: Container(
                alignment: Alignment.center,
                child: Text(
                  "Question " +
                      _questionNo.toString() +
                      " / " +
                      widget.questions.length.toString(),
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w300),
                ))),
        q.interface(onCorrect, onWrong)
      ],
    );
  }

  Scaffold _getScaffold(Widget inner) {
    return Scaffold(
      backgroundColor: OTPColour.light2,
      body: Center(child: inner),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: _getScaffold((_q == null) ? allDonePage() : _showQuestion(_q)),
        onWillPop: () async {
          if (!_isTesting) {
            return true;
          }
          bool _exit = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          child: Text("Yes")),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: Text("No")),
                    ],
                    title: Text("Stop the mock test?"),
                    content: Text("Your record will be wiped"),
                  ));
          return _exit;
        });
  }
}

///A question page that for practise purpose with showing is picked correct answer
class _PractiseQuestion extends _QuestionPage {
  ///To listen the behaviour of answer review page
  void _ansReviewedListener(bool terminate) {
    if (terminate) {
      _QuestionPage._isTesting = false;
      Navigator.pop(context);
    } else {
      _nextQuestion();
    }
  }

  @override
  void onCorrect() {
    correctCount++;
    Navigator.push(
            context, MaterialPageRoute(builder: (context) => _CorrectAns()))
        .then((isExit) {
      _ansReviewedListener(isExit as bool);
    });
  }

  @override
  void onWrong(String actualAnswer) {
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => _IncorrectAns(actual: actualAnswer)))
        .then((isExit) {
      _ansReviewedListener(isExit as bool);
    });
  }

  @override
  Widget allDonePage() {
    _QuestionPage._isTesting = false;
    return Container(
        margin: EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "You asked",
                  style: TextStyle(fontSize: 36),
                )),
            Container(
                width: MediaQuery.of(context).size.width,
                child: Text(
                  totalQuestion.toString() + " questions",
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 28),
                )),
            Divider(),
            Text(
                "and answered " +
                    correctCount.toString() +
                    " question" +
                    ((correctCount == 1) ? " is" : "s are") +
                    " correct",
                style: TextStyle(fontSize: 18)),
            Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.all(30),
                child: MaterialButton(
                  color: OTPColour.dark2,
                  padding: EdgeInsets.all(7),
                  child: Text(
                    "Exit",
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ))
          ],
        ));
  }
}

///A page that disabled reviewing answer and look like a exam
class _MockExamQuestion extends _QuestionPage {
  @override
  void onCorrect() {
    correctCount++;
    _nextQuestion();
  }

  @override
  void onWrong(String _) {
    _nextQuestion();
  }

  @override
  Widget allDonePage() {
    Widget displayResult(bool hasFailed) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            height: 250,
            margin: EdgeInsets.all(25),
            child: Text(
              "You " + (hasFailed ? "failed" : "passed") + " this mock exam",
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.w300),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Result:",
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  correctCount.toString() + " / " + totalQuestion.toString(),
                  style: TextStyle(fontSize: 24),
                )
              ],
            ),
          ),
          Container(
              alignment: Alignment.center,
              height: 150,
              margin: EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Your result is:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    correctCount.toString() + " / " + totalQuestion.toString(),
                    style: TextStyle(fontSize: 48),
                    textAlign: TextAlign.center,
                  )
                ],
              )),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.all(20),
              child: MaterialButton(
                child: Text("Exit",
                    style: TextStyle(fontSize: 24, color: Colors.white)),
                padding: EdgeInsets.all(15),
                onPressed: () {
                  Navigator.pop(context);
                },
                color: OTPColour.dark2,
              ),
            ),
          )
        ],
      ));
    }

    Widget passedExam() {
      //changeBgColour = OTPColour.light1;
      return displayResult(false);
    }

    Widget failedExam() {
      //changeBgColour = _adjustedRed;
      return displayResult(true);
    }

    return FutureBuilder<bool>(future: (() async {
      String tokenId = await UserTokenLocalStorage.getToken();
      //Submit answer first
      var dio = Dio();
      dio.options.headers["Content-Type"] = "application/json";
      var submit = await dio.post(APISitemap.submitMockMark.toString(),
          data: {"refresh_token": tokenId, "mark": correctCount.toString()});
      return submit.data["user_pass"] as bool;
    })(), builder: (context, isPassed) {
      if (isPassed.connectionState == ConnectionState.waiting) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Submitting your mark...", style: TextStyle(fontSize: 24)),
              Padding(
                  padding: EdgeInsets.all(30),
                  child: CircularProgressIndicator())
            ],
          ),
        );
      } else {
        if (isPassed.hasData) {
          return (isPassed.data ? passedExam() : failedExam());
        } else if (isPassed.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                    "Oops... your mark is not submitted to server due to errors",
                    style: TextStyle(fontSize: 24)),
                Icon(
                  CupertinoIcons.xmark_circle,
                  size: 120,
                )
              ],
            ),
          );
        }
        return Container();
      }
    });
  }
}

// ignore: must_be_immutable
abstract class _ReviewAnswer extends StatelessWidget {
  ///To listen the pop behaviour is come from button on the app or back button
  bool _triggerByButton = false;
  Color bgColour();
  String response();

  ///Predefine style of action button
  Container _actionBtn(
      BuildContext context, String btnTxt, Color bg, Function onPressed) {
    return Container(
      margin: EdgeInsets.only(top: 25, bottom: 25),
      width: MediaQuery.of(context).size.width - 10,
      height: 50,
      child: MaterialButton(
        child:
            Text(btnTxt, style: TextStyle(fontSize: 18, color: Colors.white)),
        color: bg,
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: bgColour(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                response(),
                style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
                textAlign: TextAlign.center,
              ),
              Padding(padding: EdgeInsets.only(top: 100)),
              _actionBtn(context, "Next", OTPColour.mainTheme, () {
                _triggerByButton = true;
                Navigator.pop(context, false);
              }),
              _actionBtn(context, "Give Up", Colors.redAccent, () {
                _triggerByButton = true;
                Navigator.pop(context, true);
              })
            ],
          ),
        ),
      ),
      onWillPop: () async => _triggerByButton,
    );
  }
}

// ignore: must_be_immutable
class _CorrectAns extends _ReviewAnswer {
  @override
  Color bgColour() => OTPColour.light2;

  @override
  String response() => "Correct!";
}

// ignore: must_be_immutable
class _IncorrectAns extends _ReviewAnswer {
  ///Actual answer
  final String actual;
  _IncorrectAns({@required this.actual}) : super();

  @override
  Color bgColour() => _adjustedRed;

  @override
  String response() => "Incorrect!\nThe correct answer is:\n" + actual;
}
