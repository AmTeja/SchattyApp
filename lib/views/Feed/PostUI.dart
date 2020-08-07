import 'package:achievement_view/achievement_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:schatty/helper/constants.dart';
import 'package:schatty/provider/DarkThemeProvider.dart';
import 'package:schatty/services/DatabaseManagement.dart';
import 'package:schatty/views/Chatroom/Profile.dart';
import 'package:schatty/widgets/FeedVideoPlayer.dart';
import 'package:schatty/widgets/widget.dart';

import '../NewSearch.dart';

class MakePost extends StatefulWidget {
  final postDocs;
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

  const MakePost(
      {Key key,
      this.postDocs,
      this.url,
      this.username,
      this.topic,
      this.caption,
      this.postUid,
      this.likes,
      this.dislikes,
      this.time,
      this.nsfw,
      this.title,
      this.loop,
      this.numLikes,
      this.numDislikes,
      this.isVideo})
      : super(key: key);

  @override
  _MakePostState createState() => _MakePostState();
}

class _MakePostState extends State<MakePost> {
  String profileUrl;

  bool isReported = false;
  bool isLiked = false;
  bool isDisliked = false;

  CollectionReference selectedTagRef;

  var uid;
  var reportedPostsList;

  double likeOpacity = 0;
  double dislikeOpacity = 0;

  var firestoreInstance = Firestore.instance;

  DatabaseMethods databaseMethods = new DatabaseMethods();

  @override
  void initState() {
    // TODO: implement initState
    setLikeAndDislike();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Get users profile picture url
    getUserProfileUrl();
    //Setting tag ref
    selectedTagRef = firestoreInstance
        .collection('Posts')
        .document('Public')
        .collection(widget.topic);

    return Consumer<DarkThemeProvider>(
      //Consumer for dark theme
      builder: (BuildContext context, value, Widget child) {
        return !isReported
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border:
                      Border(top: BorderSide(color: Colors.black, width: 1.50)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Header(),
                    Body(),
                    Footer(),
                  ],
                ),
              )
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
//      height: 70,
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
              : Text(
                  "Username",
                ),
          subtitle: widget.title != null ? Text("${widget.title}") : null,
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget Body() {
    return Container(
        child: widget.nsfw ?? false
            ? GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => viewImage(widget.url, context,
                            widget.caption, widget.caption),
                      ));
                },
                child: Container(
                  color: Colors.transparent,
                  height: 300,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                        Text("Tap to view",
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
                        builder: (context) => viewImage(widget.url, context,
                            widget.caption, widget.caption),
                      ));
                },
                child: widget.isVideo ?? false
                    ? FeedVideoPlayer(
                        url: widget.url,
                        key: new Key(widget.url),
                      )
                    : CachedNetworkImage(
                        imageUrl: widget.url,
                        fit: BoxFit.fill,
                      ),
              ));
  }

  // ignore: non_constant_identifier_names
  Widget Footer() {
    return Container(
      height: 70,
      child: ListTile(
          subtitle: widget.caption != null && widget.caption != ""
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                        child: Text("${widget.caption}",
                            style: TextStyle(fontSize: 16)))
                  ],
                )
              : null,
          title: Row(
            children: [
              Text(
                "${widget.numLikes}",
                style: TextStyle(fontSize: 28, color: Color(0xff93a5cf)),
              ),
              Text(" : ${widget.numDislikes}",
                  style: TextStyle(fontSize: 28, color: Color(0xffff758c)))
            ],
          ),
          isThreeLine: false,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                    color: isLiked ? Color(0xff93a5cf) : Colors.transparent,
                    borderRadius: BorderRadius.circular(23)),
                child: IconButton(
                  icon: Icon(Icons.thumb_up),
                  onPressed: () {
                    _liked();
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                    color: isDisliked ? Color(0xffff758c) : Colors.transparent,
                    borderRadius: BorderRadius.circular(23)),
                child: IconButton(
                  icon: Icon(Icons.thumb_down),
                  onPressed: () {
                    _disliked();
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                    color: Color(0xFF6CC0F8),
                    borderRadius: BorderRadius.circular(23)),
                child: IconButton(
                  icon: Icon(Icons.send),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewSearch(
                            isVideo: widget.isVideo,
                            profileUrl: profileUrl,
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
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                height: 40,
                width: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Color(0xFFF86C6C),
                    borderRadius: BorderRadius.circular(23)),
                child: IconButton(
                  icon: widget.username != Constants.ownerName
                      ? Icon(Icons.report)
                      : Icon(Icons.delete),
                  color: Colors.white,
                  iconSize: 25,
                  onPressed: () {
                    if (widget.username == Constants.ownerName) {
                      deletePost();
                    } else {
                      reportPost();
                    }
                  },
                ),
              ),
            ],
          )),
    );
  }

  reportPost() async {
    uid = await databaseMethods.getUIDByUsername(widget.username);
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

      await Firestore.instance
          .collection('Reported')
          .document('Posts')
          .collection('ReportedPosts')
          .add(reportPostMap);
      await Firestore.instance
          .collection('users')
          .document(uid)
          .get()
          .then((docs) async {
        reportedPostsList = await docs.data["reportedPosts"];
        reportedPostsList.add(widget.postUid);
        await Firestore.instance
            .collection('users')
            .document(uid)
            .updateData({'reportedPosts': reportedPostsList});
      });
    } catch (error) {
      isReported = false;
      print("Error reporting post: $error");
      Fluttertoast.showToast(
          msg: "An error occurred", gravity: ToastGravity.CENTER);
      setState(() {});
    }
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

  deletePost() async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Do you want to delete this post?"),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("No"),
              ),
              FlatButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await selectedTagRef
                      .where('postUid', isEqualTo: widget.postUid)
                      .getDocuments()
                      .then((docs) async {
                    await selectedTagRef
                        .document(docs.documents[0].documentID)
                        .delete();
                    AchievementView(
                      context,
                      title: "Deleted",
                      duration: Duration(
                        seconds: 1,
                      ),
                      subTitle: "The post has been deleted.",
                      icon: Icon(Icons.delete),
                      color: Color(0xff3B3B3B),
                    )..show();
                  }).catchError((onError) {
                    AchievementView(
                      context,
                      title: "Error",
                      duration: Duration(seconds: 1),
                      subTitle: onError,
                      icon: Icon(Icons.error),
                      color: Color(0xff3B3B3B),
                    )..show();
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
                },
                child: Text("Yes"),
              ),
            ],
          );
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

  getUserProfileUrl() async {
    profileUrl = await databaseMethods.getProfileUrlByName(widget.username);
    if (mounted) {
      setState(() {});
    }
  }

  setLikeAndDislike() async {
    if (await widget.likes.indexOf("${Constants.ownerName}") != -1) {
      //Liked the post
      isLiked = true;
      if (mounted) {
        setState(() {});
      }
    } else if (await widget.dislikes.indexOf("${Constants.ownerName}") != -1) {
      //Disliked the post
      isDisliked = true;
      if (mounted) {
        setState(() {});
      }
    } else {
      isLiked = false;
      isDisliked = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  var likesList;
  var dislikesList;
  var likes;
  var dislikes;

  updateLike(bool newVal) async {
    try {
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
        dislikesList.add("${Constants.ownerName.toLowerCase()}");
        dislikes++;
      } else {
        if (!newVal) {
          dislikesList.removeAt(
              dislikesList.indexOf("${Constants.ownerName.toLowerCase()}"));
          dislikes--;
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
}
