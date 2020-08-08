import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:schatty/views/Feed/BuildContent.dart';
import 'package:tiktoklikescroller/tiktoklikescroller.dart';

class SwipeTest extends StatefulWidget {
  @override
  _SwipeTestState createState() => _SwipeTestState();
}

class _SwipeTestState extends State<SwipeTest> {
  Stream postStream;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setStream();
  }

  setStream() async {
    postStream = Firestore.instance
        .collection('Posts')
        .document('Public')
        .collection('Memes')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).padding.top);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        top: true,
        child: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height,
              child: StreamBuilder(
                  stream: postStream,
                  builder: (context, snapshot) {
                    return snapshot.hasData
                        ? TikTokStyleFullPageScroller(
                            contentSize: snapshot.data.documents.length,
                            swipeThreshold: 0.4,
                            swipeVelocityThreshold: 2000,
                            animationDuration: Duration(milliseconds: 300),
                            builder: (BuildContext context, int index) {
                              return BuildPost(
                                loop: false,
                                isVideo: snapshot.data.documents[index]
                                        .data["isVideo"] ??
                                    false,
                                time:
                                    snapshot.data.documents[index].data['time'],
                                url: snapshot.data.documents[index].data["url"],
                                username: snapshot
                                    .data.documents[index].data["username"],
                                topic: "Memes",
                                caption: snapshot
                                    .data.documents[index].data["caption"],
                                postUid: snapshot.data.documents[index]
                                        .data["postUid"] ??
                                    "null",
                                likes: snapshot
                                    .data.documents[index].data['likes'],
                                dislikes: snapshot
                                    .data.documents[index].data['dislikes'],
                                nsfw: snapshot
                                        .data.documents[index].data["NSFW"] ??
                                    false,
                                title: snapshot
                                    .data.documents[index].data["title"],
                                numLikes: snapshot.data.documents[index]
                                        .data["numLikes"] ??
                                    0,
                                numDislikes: snapshot.data.documents[index]
                                        .data["numDislikes"] ??
                                    0,
                              );
                            },
                          )
                        : SizedBox();
                  }),
            ),
            Positioned(
              child: Opacity(
                  opacity: 0.7,
                  child: Icon(
                    Icons.add_box_outlined,
                    size: 40,
                  )),
              left: 20,
              top: 20,
            ),
          ],
        ),
      ),
    );
  }
}
