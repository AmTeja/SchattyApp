import 'package:achievement_view/achievement_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:schatty/helper/constants.dart';
import 'package:schatty/provider/DarkThemeProvider.dart';
import 'package:schatty/services/DatabaseManagement.dart';
import 'package:schatty/views/Chatroom/Profile.dart';
import 'package:schatty/views/Feed/CommentsPage.dart';
import 'package:schatty/views/Feed/Post.dart';
import 'package:schatty/views/NewSearch.dart';
import 'package:schatty/widgets/FeedVideoPlayer.dart';
import 'package:schatty/widgets/widget.dart';

class BuildPost extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final url;
  final username;
  final topic;
  final caption;
  final postUid;
  final likes;
  final dislikes;
  final time;
  final nsfw;
  final title;
  final loop;
  final numLikes;
  final numDislikes;
  final isVideo;

  // ignore: non_constant_identifier_names
  const BuildPost({
    @required this.url,
    @required this.username,
    @required this.topic,
    @required this.time,
    @required this.caption,
    @required this.postUid,
    @required this.likes,
    @required this.nsfw,
    @required this.title,
    @required this.isVideo,
    @required this.loop,
    @required this.dislikes,
    @required this.numLikes,
    @required this.numDislikes,
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

  var likesLength;
  var dislikesLength;
  var uid;
  var firestoreInstance = Firestore.instance;

  bool isReported = false;

  @override
  void initState() {
    // TODO: implement initState
    setLikeAndDislike();
    super.initState();
//    getUserProfileUrl();
  }

  @override
  Widget build(BuildContext context) {
    getUserProfileUrl();
    selectedTagRef = firestoreInstance
        .collection('Posts')
        .document('Public')
        .collection(widget.topic);
    return Consumer<DarkThemeProvider>(
      builder: (BuildContext context, value, Widget child) {
        return widget.url != "Advert"
            ? !isReported
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
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(23)),
                          child: widget.nsfw
                              ? GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => viewImage(
                                              widget.url,
                                              context,
                                              widget.caption,
                                              widget.caption),
                                        ));
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    height: 300,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "NSFW",
                                              style: TextStyle(
                                                fontSize: 40,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "May contain inappropriate content",
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                              "Tap to view if you are above 18 years old",
                                              style: TextStyle(
                                                fontSize: 16,
                                              )),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => viewImage(
                                              widget.url,
                                              context,
                                              widget.caption,
                                              widget.caption),
                                        ));
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(23),
                                    child: widget.isVideo
                                        ? FeedVideoPlayer(
                                            url: widget.url,
                                            key: new Key(widget.url),
                                          )
                                        : CachedNetworkImage(
                                            imageUrl: widget.url,
                                            fit: BoxFit.fill,
                                          ),
                                  ),
                                ),
                        ),
                        Footer(),
                      ],
                    ))
                : SizedBox.shrink()
            : SizedBox();
      },
    );
  }

  // ignore: non_constant_identifier_names
  Widget Header() {
    return GestureDetector(
      onTap: () {
        if (widget.loop == true || widget.loop == null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TargetUserInfo(widget.username),
              ));
        } else {}
      },
      child: Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(),
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
          subtitle: widget.title != null ? Text(widget.title) : Text(""),
          trailing: widget.username != Constants.ownerName
              ? PopupMenuButton(
            onSelected: (val) => _selected(val, context),
            icon: Icon(Icons.expand_more),
            itemBuilder: (BuildContext build) {
              return [
                PopupMenuItem(
                  height: 30,
                  value: "Report",
                  child: Text("Report"),
                ),
              ];
            },
          )
              : PopupMenuButton(
            onSelected: (val) => _selected((val), context),
            icon: Icon(Icons.expand_more),
            itemBuilder: (BuildContext build) {
              return [
                PopupMenuItem(
                  height: 30,
                  value: "Delete",
                  child: Text("Delete"),
                )
              ];
            },
          ),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget Footer() {
    double splashRadius = 25.0;
    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                color: Colors.black,
              ))),
      child: Flex(
        direction: Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            child: widget.caption != null && widget.caption != ""
                ? FittedBox(
              child: Text(
                "${widget.caption}",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            )
                : SizedBox.shrink(),
          ),
          ListTile(
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${widget.numLikes - widget.numDislikes}",
                    style: TextStyle(fontSize: 20),
                  ),
                  IconButton(
                    icon: Icon(Icons.thumb_up),
                    color:
                    isLiked != null && isLiked ? Color(0xffFF8F8F) : null,
                    splashRadius: splashRadius,
                    onPressed: () => _liked(),
                  ),
                  IconButton(
                    icon: Icon(Icons.thumb_down),
                    color: isDisliked != null && isDisliked
                        ? Color(0xffFF8F8F)
                        : null,
                    splashRadius: splashRadius,
                    onPressed: () => _disliked(),
                  ),
                  IconButton(
                    icon: Icon(Icons.comment),
                    splashRadius: splashRadius,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CommentsPage(
                                    postUID: widget.postUid,
                                    tag: widget.topic,
                                    postOwnerUsername: widget.username,
                                  )));
                    },
                  )
                ],
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NewSearch(
                            isVideo: isVideo,
                        isPost: true,
                        postUid: widget.postUid,
                        caption: widget.caption,
                        ownerUsername: widget.username,
                        topic: widget.topic,
                        postUrl: widget.url,
                      ),
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }

  setLikeAndDislike() async {
    if (await widget.likes.indexOf("${Constants.ownerName}") !=
        -1) {
      isLiked = true;
    } else {
      isLiked = false;
    }
    if (await widget.dislikes.indexOf("${Constants.ownerName}") !=
        -1) {
      isDisliked = true;
    } else {
      isDisliked = false;
    }
    setState(() {});
  }

  _liked() {
    bool newVal = true;
    bool temp = isDisliked;
    if (isLiked) {
      newVal = false;
    } else {
      newVal = true;
      isDisliked = !newVal;
    }
    updateLike(newVal);
    if (temp) {
      updateDislike(!newVal);
    }
    if (mounted) {
      setState(() {
        isLiked = newVal;
      });
    }
  }

  _disliked() {
    bool temp = isLiked;
    bool newVal = true;
    if (isDisliked) {
      newVal = false;
    } else {
      newVal = true;
      isLiked = !newVal;
    }
    updateDislike(newVal);
    if (temp) {
      updateLike(!newVal);
    }
    if (mounted) {
      setState(() {
        isDisliked = newVal;
      });
    }
  }

  _selected(val, context) {
    if (val == "Report") {
      reportPost();
    }
    if (val == "Delete") {
      deletePost();
    }
  }

  deletePost() async {
    await selectedTagRef
        .where('postUid', isEqualTo: widget.postUid)
        .getDocuments()
        .then((docs) async {
      await selectedTagRef.document(docs.documents[0].documentID).delete();
      AchievementView(
        context,
        title: "Deleted",
        duration: Duration(
          seconds: 1,
        ),
        subTitle: "The post has been deleted.",
        icon: Icon(Icons.delete),
        color: Color(0xff3B3B3B),
      )
        ..show();
    }).catchError((onError) {
      AchievementView(
        context,
        title: "Error",
        duration: Duration(seconds: 1),
        subTitle: onError,
        icon: Icon(Icons.error),
        color: Color(0xff3B3B3B),
      )
        ..show();
    });
    int posts;
    await updateUserPosts();
    await firestoreInstance
        .collection('Posts')
        .document('Public')
        .collection('Tags')
        .document(widget.topic)
        .get()
        .then((docs) async {
      posts = await docs.data['posts'];
      posts--;
      firestoreInstance
          .collection('Posts')
          .document('Public')
          .collection('Tags')
          .document(widget.topic)
          .updateData({'posts': posts});
    });
  }

  updateUserPosts() async {
    uid = await databaseMethods.getUIDByUsername(widget.username);
    int posts;
    await firestoreInstance
        .collection('users')
        .document(uid)
        .get()
        .then((docs) async {
      posts = await docs.data["numPosts"];
      posts--;
      await firestoreInstance
          .collection('users')
          .document(uid)
          .updateData({'numPosts': posts});
    });
  }

  var reportedPostsList;

  reportPost() async {
    try {
      Map<String, dynamic> reportPostMap = {
        'reportedBy': Constants.ownerName.toLowerCase(),
        'postId': widget.postUid,
        'tag': widget.topic,
        'title': widget.title,
      };
      isReported = true;
      if (mounted) {
        setState(() {});
      }

      await firestoreInstance
          .collection('Reported')
          .document('Posts')
          .collection('ReportedPosts')
          .add(reportPostMap);
      await firestoreInstance
          .collection('users')
          .document(Constants.ownerUid)
          .get()
          .then((docs) async {
        reportedPostsList = await docs.data["reportedPosts"];
        reportedPostsList.add(widget.postUid);
        await firestoreInstance
            .collection('users')
            .document(Constants.ownerUid)
            .updateData({"reportedPosts": reportedPostsList});
      });
      AchievementView(
        context,
        title: "Reported",
        duration: Duration(seconds: 1),
        subTitle: "The post has been reported. Thank you!",
        icon: Icon(Icons.report),
        color: Color(0xff3B3B3B),
      )
        ..show();
    } catch (error) {
      isReported = false;
      Fluttertoast.showToast(
          msg: "An error occurred", gravity: ToastGravity.CENTER);
      setState(() {});
    }
  }

  var likesList;
  var dislikesList;
  var likes;
  var dislikes;

  updateLike(bool newVal) async {
    try {
      print('Called update Like');
      await selectedTagRef
          .where('postUid', isEqualTo: widget.postUid)
          .getDocuments()
          .then((docs) async {
        likesList = await docs.documents[0].data["likes"];
        likes = await docs.documents[0].data["numLikes"];
        if (newVal) {
          likesList.add("${Constants.ownerName.toLowerCase()}");
          likes = likes + 1;
        } else {
          likesList.removeAt(
              likesList.indexOf("${Constants.ownerName.toLowerCase()}"));
          likes = likes - 1;
        }
        Map<String, dynamic> likeListMap = {
          'likes': likesList,
          "numLikes": likes,
        };
        await selectedTagRef
            .document(docs.documents[0].documentID)
            .updateData(likeListMap);
        setState(() {});
      });
    } catch (error) {
      print("UpdateLike error: $error");
    }
  }

  updateDislike(bool newVal) async {
    await selectedTagRef
        .where('postUid', isEqualTo: widget.postUid)
        .getDocuments()
        .then((docs) async {
      dislikesList = await docs.documents[0].data["dislikes"];
      dislikes = await docs.documents[0].data["numDislikes"];

      if (newVal && isDisliked) {
        print('true and true');
        dislikesList.add("${Constants.ownerName.toLowerCase()}");
        dislikes++;
      } else {
        if (!newVal) {
          dislikesList.removeAt(
              dislikesList.indexOf("${Constants.ownerName.toLowerCase()}"));
          dislikes--;
          print('false ');
        } else {}
      }
      Map<String, dynamic> dislikeListMap = {
        'dislikes': dislikesList,
        'numDislikes': dislikes,
      };
      await selectedTagRef
          .document(docs.documents[0].documentID)
          .updateData(dislikeListMap);
    });
    setState(() {});
  }

  getUserProfileUrl() async {
    profileUrl = await databaseMethods.getProfileUrlByName(widget.username);
    if (mounted) {
      setState(() {});
    }
  }
}
