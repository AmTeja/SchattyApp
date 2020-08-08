import 'package:achievement_view/achievement_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:schatty/helper/constants.dart';
import 'package:schatty/services/DatabaseManagement.dart';
import 'package:schatty/views/Chatroom/Profile.dart';
import 'package:schatty/views/Feed/CommentsPage.dart';
import 'package:schatty/views/NewSearch.dart';
import 'package:schatty/widgets/FeedVideoPlayer.dart';
import 'package:schatty/widgets/widget.dart';

class BuildPost extends StatefulWidget {
  bool isDark;
  String url;
  String username;
  String topic;
  String caption;
  String postUid;
  final likes;
  final dislikes;
  final time;
  bool nsfw;
  String title;
  bool loop;
  final numLikes;
  final numDislikes;
  bool isVideo;

  // ignore: non_constant_identifier_names
  BuildPost({
    this.isDark,
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

  String firstHalf;
  String secondHalf;
  bool readMore = false;
  bool zoomOut = false;
  bool viewDetails = true;
  bool isReported = false;

  PageController pageController;

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
    return isReported
        ? Center(
            child: Text("Thank you for reporting."),
          )
        : GestureDetector(
            onTap: () {
              setState(() {
                viewDetails = !viewDetails;
              });
            },
            child: Stack(
              children: [
                widget.isVideo ?? false
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            viewDetails = !viewDetails;
                          });
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.height,
                          alignment: Alignment.center,
                          child: Container(
                            height: 300,
                            child: FeedVideoPlayer(
                              url: widget.url,
                              key: Key(widget.url),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        height: MediaQuery.of(context).size.height,
                        child: CachedNetworkImage(
                          height: double.infinity,
                          width: double.infinity,
                          progressIndicatorBuilder: (context, _, progress) =>
                              Center(
                            child: CircularProgressIndicator(),
                          ),
                          imageUrl: widget.url,
                          fit: zoomOut ? BoxFit.contain : BoxFit.cover,
                          filterQuality: FilterQuality.high,
                        )),
                Positioned(
                    bottom: 10,
                    right: 0,
                    left: 0,
                    child: AnimatedOpacity(
                      opacity: viewDetails ? 0.66 : 0.0,
                      duration: Duration(milliseconds: 400),
                      child: DetailCard(),
                    )),
              ],
            ),
          );
  }

  Widget DetailCard() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.25,
      color: !widget.isDark ? Colors.white : Colors.black,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    TargetUserInfo(widget.username)));
                      },
                      child: UserAvatar(profileUrl, 25.0)),
                ),
                Container(
                  child: Expanded(
                    child: Text(
                      widget.caption == "" || widget.caption == null
                          ? widget.title ?? ""
                          : widget.caption,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                )
              ],
            ),
          ),
          viewDetails
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              _liked();
                            },
                            icon: isLiked
                                ? Icon(Icons.star)
                                : Icon(Icons.star_border),
                            iconSize: 26,
                          ),
                          Text(
                            "${widget.numLikes}",
                            style: TextStyle(fontSize: 18),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CommentsPage(
                                            postUID: widget.caption,
                                            postOwnerUsername: widget.username,
                                            tag: widget.topic,
                                          )));
                            },
                            icon: Icon(Icons.comment),
                            iconSize: 26,
                          ),
//                    Text(
//                      "1",
//                      style: TextStyle(fontSize: 18),
//                    )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: IconButton(
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
                                      )));
                        },
                        icon: Icon(Icons.send_rounded),
                        iconSize: 26,
                      ),
                    ),
                    !widget.isVideo
                        ? Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  zoomOut = !zoomOut;
                                });
                              },
                              icon: zoomOut
                                  ? Icon(Icons.zoom_in)
                                  : Icon(Icons.zoom_out),
                              iconSize: 26,
                            ),
                          )
                        : Container(),
                  ],
                )
              : Container(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFF707070),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${widget.topic}",
                ),
              ),
              isReported
                  ? Container()
                  : Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: IconButton(
                        onPressed: () {
                          if (widget.username == Constants.ownerName) {
                            deletePost();
                          } else {
                            reportPost();
                          }
                        },
                        icon: widget.username == Constants.ownerName
                            ? Icon(Icons.delete)
                            : Icon(Icons.report),
                        iconSize: 26,
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  setLikeAndDislike() async {
    if (await widget.likes.indexOf("${Constants.ownerName}") != -1) {
      isLiked = true;
    } else {
      isLiked = false;
    }
    if (await widget.dislikes.indexOf("${Constants.ownerName}") != -1) {
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

  List reportedPostsList;

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
      print(uid);
      await Firestore.instance
          .collection('users')
          .where('uid', isEqualTo: uid)
          .getDocuments()
          .then((docs) async {
        print('Found user: $uid');
        reportedPostsList = await docs.documents[0].data["reportedPosts"];
        reportedPostsList.add("${widget.postUid}");
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

  var likesList;
  var dislikesList;
  var likes;
  var dislikes;

  updateLike(bool newVal) async {
    try {
      await Firestore.instance
          .collection('Posts')
          .document('Public')
          .collection(widget.topic)
          .where('postUid', isEqualTo: widget.postUid)
          .getDocuments()
          .then((docs) async {
        likesList = await docs.documents[0].data['likes'];
        likes = await docs.documents[0].data["numLikes"];
        if (newVal) {
          print('true');
          likesList.add("${Constants.ownerName.toLowerCase()}");
          likes = likes + 1;
        } else {
          print('false');
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

  getUserProfileUrl() async {
    profileUrl = await databaseMethods.getProfileUrlByName(widget.username);
    if (mounted) {
      setState(() {});
    }
  }
}
