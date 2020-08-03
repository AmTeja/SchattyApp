import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:schatty/views/Feed/PostUI.dart';
import 'package:share_extend/share_extend.dart';

Widget appBarMain(BuildContext context) {
  return AppBar();
}

InputDecoration textFieldInputDecoration(String hintText) {
  return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.black26,
      ),
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
        color: Colors.blue,
      )),
      enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
        color: Colors.black,
      )));
}

compareTime(String timeInDM) {
  var time = timeInDM.split(':');
  int sentDay = int.parse(time[0]);
  int sentMonth = int.parse(time[1]);
  int sentYear = int.parse(time[2]);

  var currentTime = DateFormat('dd:M:y').format(DateTime.now()).split(':');
  int currentDay = int.parse(currentTime[0]);
  int currentMonth = int.parse(currentTime[1]);
  int currentYear = int.parse(currentTime[2]);

  if (currentYear >= sentYear) {
    if (currentMonth >= sentMonth) {
      if (currentDay > sentDay) {
        return true;
      }
      if (currentDay == sentDay) {
        return false;
      }
    }
  }
  return true;
}

TextStyle simpleTextStyle() {
  return TextStyle(
    color: Colors.white,
    fontSize: 18,
  );
}

Widget viewImage(String url, BuildContext context, String message, Object tag) {
  return Scaffold(
    appBar: AppBar(
      title: message != null && message != ""
          ? FittedBox(child: Text(message))
          : Text(""),
      actions: [
        IconButton(
          icon: Icon(Icons.share),
          onPressed: () {
            share(context, url, true);
          },
        )
      ],
    ),
    backgroundColor: Colors.transparent,
    body: Center(
      child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Hero(
            tag: tag,
            child: PhotoView(
              imageProvider: CachedNetworkImageProvider(url),
            ),
          )),
    ),
  );
}

viewPostInChat(String postUid, String topic, BuildContext context) async {
  var docs;
  if (postUid != null) {
    await Firestore.instance
        .collection('Posts')
        .document('Public')
        .collection(topic)
        .where('postUid', isEqualTo: postUid)
        .getDocuments()
        .then((documents) {
      docs = documents.documents[0];
    });
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => viewPost(docs, topic),
        ));
  }
}

Widget viewPost(docs, topic) {
  return Scaffold(
    appBar: AppBar(
      title: Text("Schatty"),
      centerTitle: true,
    ),
    body: ListView(
      children: [
        MakePost(
          loop: false,
          time: docs.data['time'],
          url: docs.data["url"],
          username: docs.data["username"],
          topic: topic,
          caption: docs.data["caption"],
          postUid: docs.data["postUid"] ?? "null",
          likes: docs.data['likes'],
          dislikes: docs.data['dislikes'],
          nsfw: docs.data["NSFW"] ?? false,
          title: docs.data["title"],
          numLikes: docs.data["numLikes"],
          numDislikes: docs.data["numDislikes"],
          isVideo: docs.data["isVideo"] ?? false,
        ),
      ],
    ),
  );
}

void share(BuildContext context, String message, bool isImage) {
  ShareExtend.share(message, "text");
}

// ignore: non_constant_identifier_names
Widget SchattyIcon() {
  return Image(
    image: AssetImage('assets/icon/icon.png'),
  );
}

Widget loadingScreen(String text) {
  return Scaffold(
    body: Center(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                text,
                style: TextStyle(fontSize: 40),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: LinearProgressIndicator(
                backgroundColor: Colors.black,
              ),
            )
          ],
        ),
      ),
    ),
  );
}

// ignore: non_constant_identifier_names
Widget UserAvatar(String profileURL, double radius) {
  return CircleAvatar(
    radius: radius,
    child: ClipOval(
      child: profileURL != null
          ? CachedNetworkImage(
              width: radius * 2,
              height: radius * 2,
              imageUrl: profileURL,
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Image.asset(
              "assets/images/username.png",
              fit: BoxFit.fill,
            ),
    ),
  );
}
