import 'package:achievement_view/achievement_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schatty/helper/constants.dart';
import 'package:schatty/provider/DarkThemeProvider.dart';
import 'package:schatty/services/DatabaseManagement.dart';
import 'package:schatty/views/Chatroom/TargetUserInfo.dart';
import 'package:schatty/views/Feed/CommentsPage.dart';
import 'package:schatty/views/FeedAd.dart';
import 'package:schatty/widgets/widget.dart';

class BuildPost extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final url;
  final username;
  final topic;
  final caption;
  final isDark;
  final postUid;
  final likes;
  final time;
  final nsfw;
  final title;

  // ignore: non_constant_identifier_names
  const BuildPost({
    @required this.url,
    @required this.username,
    @required this.topic,
    @required this.isDark,
    @required this.time,
    @required this.caption,
    @required this.postUid,
    @required this.likes,
    @required this.nsfw,
    @required this.title,
  });

  @override
  _BuildPostState createState() => _BuildPostState();
}

class _BuildPostState extends State<BuildPost> {
  bool isLiked = false;
  bool isDisliked = false;

  DatabaseMethods databaseMethods = new DatabaseMethods();

  String profileUrl;
  CollectionReference selectedTagRef;

  @override
  void initState() {
    // TODO: implement initState
    profileUrl = null;
    super.initState();
//    getUserProfileUrl();
  }

  @override
  Widget build(BuildContext context) {
    getUserProfileUrl();
    selectedTagRef = Firestore.instance
        .collection('Posts')
        .document('Public')
        .collection(widget.topic);
    if (widget.url == "Advert") {
      print('Called with ${widget.time}');
    }
    return Consumer<DarkThemeProvider>(
      builder: (BuildContext context, value, Widget child) {
        return widget.url != "Advert"
            ? Container(
                decoration: BoxDecoration(color: Colors.transparent),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Header(),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 30.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(23)),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                          MaterialPageRoute(
                            builder: (context) => viewImage(widget.url, context,
                                widget.caption, widget.caption),
                          ));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(23),
                      child: Hero(
                        tag: widget.caption,
                        child: CachedNetworkImage(
                          imageUrl: widget.url,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                ),
                Footer(),
              ],
            )) : FeedAd();
      },
    );
  }

  // ignore: non_constant_identifier_names
  Widget Header() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TargetUserInfo(widget.username),
            ));
      },
      child: Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
        ),
        height: 70,
        child: ListTile(
            leading: CircleAvatar(
              child: ClipOval(
                child: profileUrl != null
                    ? CachedNetworkImage(
                  width: 60,
                  height: 60,
                  imageUrl: profileUrl,
                  fit: BoxFit.cover,
                )
                    : Image.asset(
                  "assets/images/username.png",
                  fit: BoxFit.fill,
                ),
              ),
            ),
            title: widget.username != null
                ? Text(widget.username)
                : Center(
              child: CircularProgressIndicator(),
            ),
            subtitle: widget.title != null ? Text(widget.title) : null,
            trailing: PopupMenuButton(
              onSelected: (val) => _selected(val, context),
              icon: Icon(Icons.expand_more),
              itemBuilder: (BuildContext build) {
                return [
                  PopupMenuItem(
                    height: 30,
                    value: "Report",
                    child: Text("Report"),
                  )
                ];
              },
            )
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget Footer() {
    double splashRadius = 25.0;
    return Container(
//      height: 80,
      decoration: BoxDecoration(
//        color: widget.isDark ? Colors.black : Colors.white,
//        borderRadius: BorderRadius.circular(23)
          border: Border(
              bottom: BorderSide(
                color: Colors.black,
              ))),
      child: Flex(
        direction: Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.thumb_up),
                    color: isLiked ? Color(0xffFF8F8F) : null,
                    splashRadius: splashRadius,
                    onPressed: () => _liked(),
                  ),
                  Text(
                    widget.likes == 0 || widget.likes == null ? "" : "${widget
                        .likes}",
                    style: TextStyle(
                        fontSize: 20
                    ),),
//                  IconButton(
//                    icon: Icon(Icons.thumb_down),
//                    color: isDisliked ? Color(0xffFF8F8F) : null,
//                    splashRadius: splashRadius,
//                    onPressed: () => _disliked(),
//                  ),
                  IconButton(
                    icon: Icon(Icons.comment),
                    splashRadius: splashRadius,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) =>
                              CommentsPage(
                                postUID: widget.postUid, tag: widget.topic,)
                      ));
                    },
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
            child: Text(
              "${widget.caption}",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _liked() {
    bool newVal = true;
    if (isLiked) {
      newVal = false;
    } else {
      newVal = true;
      isDisliked = !newVal;
    }
    updateLike(newVal);
    if (mounted) {
      setState(() {
        isLiked = newVal;
      });
    }
  }

  _selected(val, context) {
    if (val == "Report") {
      reportPost();
    }
  }

  showReportDialog() {
    TextEditingController reportTEC = new TextEditingController();
    var checkBox;
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Report"),
            content: Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.70,
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.2,
              child: Column(
                children: [
                  CheckboxListTile(
                    onChanged: (val) => _changed,
                    value: checkBox,
                    title: Text("Hate speech"),
                    subtitle: Text("Sexual content"),
                    tristate: true,
                  ),
//                  TextFormField(
//                    autofocus: true,
//                    style: TextStyle(
//                        fontSize: 20
//                    ),
//                    decoration: InputDecoration(
//                        contentPadding: EdgeInsets.all(16),
//                        border: OutlineInputBorder(
//                            borderRadius: BorderRadius.circular(23)
//                        )
//                    ),
//                    textCapitalization: TextCapitalization.sentences,
//                    controller: reportTEC,
//                    maxLines: 3,
//                    maxLength: 150,
//                  ),
                ],
              ),
            ),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Container(
                    alignment: Alignment.center,
                    child: Text("Cancel")),
              ),
              FlatButton(
                onPressed: () {
                  reportPost();
                  Navigator.pop(context);
                },
                child: Container(
                    alignment: Alignment.center,
                    child: Text("Add")),
              )
            ],
          );
        }
    );
  }

  _changed() {

  }

  reportPost() async
  {
    Map<String, dynamic> reportPostMap = {
      'reportedBy': Constants.ownerName.toLowerCase(),
      'postId': widget.postUid,
      'tag': widget.topic,
      'title': widget.title,
    };

    await Firestore.instance.collection('Reported')
        .document('Posts')
        .collection('ReportedPosts')
        .add(reportPostMap);
    setState(() {
      AchievementView(
        context,
        title: "Reported",
        duration: Duration(seconds: 1, milliseconds: 500),
        subTitle: "The post has been reported. Thank you!",
        icon: Icon(Icons.report),
        color: Color(0xff3B3B3B),
      )
        ..show();
    });
  }

  int newLikeAmount;
  int newDislikeAmount;

  updateLike(bool newVal) async
  {
    await selectedTagRef
        .where('postUid', isEqualTo: widget.postUid)
        .getDocuments().then((docs) async {
      newLikeAmount = await docs.documents[0].data["likes"];
      if (newVal == true) {
        newLikeAmount++;
      } else {
        newLikeAmount--;
      }
      Map<String, dynamic> likeMap = {
        "likes": newLikeAmount,
      };
      await selectedTagRef.document(docs.documents[0].documentID).updateData(
          likeMap);
    });
  }

  updateDislike(bool newVal) async
  {
    await selectedTagRef
        .where('postUid', isEqualTo: widget.postUid)
        .getDocuments().then((docs) async {
      newDislikeAmount = await docs.documents[0].data["dislikes"];
      if (newVal == true) {
        newDislikeAmount--;
      } else {
        newDislikeAmount++;
      }
      Map<String, dynamic> disLikeMap = {
        "dislikes": newDislikeAmount,
      };
      await selectedTagRef.document(docs.documents[0].documentID).updateData(
          disLikeMap);
    });
  }

  _disliked() {
    bool newVal = true;
    if (isDisliked) {
      newVal = false;
    } else {
      newVal = true;
      isLiked = !newVal;
    }
    if (mounted) {
      setState(() {
        isDisliked = newVal;
      });
    }
    updateDislike(newVal);
  }

  getUserProfileUrl() async {
    profileUrl = await databaseMethods.getProfileUrlByName(widget.username);
    if (mounted) {
      setState(() {

      });
    }
  }
}
