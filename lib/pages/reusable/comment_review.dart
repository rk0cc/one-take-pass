import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:one_take_pass_remake/api/userdata/comment.dart';
import 'package:one_take_pass_remake/themes.dart';

class CommentReview extends StatefulWidget {
  final String targetPhone;

  CommentReview({this.targetPhone});

  @override
  State<StatefulWidget> createState() => _CommentReview();
}

class _CommentReview extends State<CommentReview> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OTPComment>>(
        future: UserComments(widget.targetPhone).commentList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.hasData) {
              return snapshot.data.isNotEmpty
                  ? ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, count) => Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.all(15),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 1.5, color: OTPColour.mainTheme)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "User: " + snapshot.data[count].username,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(snapshot.data[count].content),
                              ],
                            ),
                          ))
                  : Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      alignment: Alignment.center,
                      child: Text("You have no comments right now"),
                    );
            } else {
              return Center(
                child: Column(
                  children: [
                    Icon(
                      CupertinoIcons.xmark_circle,
                      size: 120,
                    ),
                    Text("Unable to get comments")
                  ],
                ),
              );
            }
          }
        });
  }
}

class CommentReviewPage extends StatelessWidget {
  final String targetPhone;

  CommentReviewPage({this.targetPhone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text((targetPhone == null) ? "Your comments" : "His/Her comments"),
        centerTitle: true,
      ),
      body: CommentReview(
        targetPhone: targetPhone,
      ),
    );
  }
}
