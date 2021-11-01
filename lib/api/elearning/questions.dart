import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:one_take_pass_remake/api/url/localapiurl.dart';
import 'package:one_take_pass_remake/themes.dart';

///A [Question] that will be shown on app
abstract class Question {
  String _question;
  List<AnswerChoice> _choice;

  ///Setter for [question]
  void setQuestion(String question) {
    this._question = question;
  }

  ///Setter for a list of answer [choice]
  void setChoice(List<AnswerChoice> choice) {
    this._choice = choice;
  }

  ///An abstract method for rendering UI
  Widget interface(Function onCorrect, Function onWrong);

  String get question {
    return _question;
  }

  List<AnswerChoice> get choice {
    return _choice;
  }

  ///Automated generating [Question] classes by
  ///
  ///[json] from API
  static Question autoParseFromJSON(Map<String, dynamic> json) {
    if (json.containsKey("image") && json["image"] != null) {
      //If the response has image key
      return SymbolQuestion.fromJSON(json);
    }
    //When image is not provided
    return TextQuestion.fromJSON(json);
  }
}

class TextQuestion extends Question {
  TextQuestion(String question, List<AnswerChoice> choice) {
    this.setQuestion(question);
    this.setChoice(choice);
  }
  @override
  Widget interface(Function onCorrect, Function onWrong) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Column(children: [
        Text(
          question,
          style: TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
        Padding(padding: EdgeInsets.all(10)),
        Container(
            height: 275,
            margin: EdgeInsets.all(5),
            child: Center(
                child: ListView.builder(
                    itemCount: choice.length,
                    itemBuilder: (context, qNo) => MaterialButton(
                          onPressed: () async {
                            var dio = Dio();
                            dio.options.headers["Content-Type"] =
                                "application/json";
                            var ansObj = await dio.post(
                                APISitemap.postAns.toString(),
                                data: jsonEncode({
                                  "question": question,
                                  "answer": choice[qNo].answerString
                                }));
                            APIAnsResp respAns =
                                APIAnsResp.fromJSON(ansObj.data);
                            respAns.correct
                                ? onCorrect()
                                : onWrong(respAns.answer);
                          },
                          child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                choice[qNo].answerString,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              )),
                          color: OTPColour.dark1,
                        )))),
      ]),
    );
  }

  factory TextQuestion.fromJSON(Map<String, dynamic> json) {
    return TextQuestion(json["question"], [
      AnswerChoice(answerString: json["A0"]),
      AnswerChoice(answerString: json["A1"]),
      AnswerChoice(answerString: json["A2"])
    ]);
  }
}

class SymbolQuestion extends Question {
  String symbol;
  SymbolQuestion(String symbol, String question, List<AnswerChoice> choice) {
    this.symbol = symbol;
    this.setQuestion(question);
    this.setChoice(choice);
  }
  @override
  Widget interface(Function onCorrect, Function onWrong) {
    return Container(
      child: Column(children: [
        Text(
          question,
          style: TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
        Padding(padding: EdgeInsets.all(20)),
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(
                    APISitemap.customPath(symbol).toString(),
                  ),
                  fit: BoxFit.contain)),
        ),
        Container(
            height: 275,
            margin: EdgeInsets.all(5),
            child: Center(
                child: ListView.builder(
                    itemCount: choice.length,
                    itemBuilder: (context, qNo) => MaterialButton(
                          onPressed: () async {
                            var dio = Dio();
                            dio.options.headers["Content-Type"] =
                                "application/json";
                            var ansObj = await dio.post(
                                APISitemap.postAns.toString(),
                                data: jsonEncode({
                                  "image": symbol,
                                  "answer": choice[qNo].answerString
                                }));
                            APIAnsResp respAns =
                                APIAnsResp.fromJSON(ansObj.data);
                            respAns.correct
                                ? onCorrect()
                                : onWrong(respAns.answer);
                          },
                          child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                choice[qNo].answerString,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              )),
                          color: OTPColour.dark1,
                        )))),
      ]),
    );
  }

  factory SymbolQuestion.fromJSON(Map<String, dynamic> json) {
    return SymbolQuestion(json["image"], json["question"], [
      AnswerChoice(answerString: json["A0"]),
      AnswerChoice(answerString: json["A1"]),
      AnswerChoice(answerString: json["A2"])
    ]);
  }
}

class AnswerChoice {
  final String answerString;
  AnswerChoice({@required this.answerString});
}

class APIAnsResp {
  final bool correct;
  final String answer;

  APIAnsResp({@required this.correct, @required this.answer});

  factory APIAnsResp.fromJSON(Map<String, dynamic> json) {
    return APIAnsResp(correct: json['correct'], answer: json['answer']);
  }

  Map<String, dynamic> toJSON() => {"correct": correct, "answer": answer};
}
