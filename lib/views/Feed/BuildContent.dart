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
  final postUid;
  final likes;
  final dislikes;
  final time;
  final nsfw;
  final title;
  final loop;

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
    this.loop,
    this.dislikes,
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


  @override
  void initState() {
    // TODO: implement initState
    profileUrl = null;
    setLikeAndDislike();
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
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(23)),
                      child: widget.nsfw ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    viewImage(widget.url, context,
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
                                    "NSFW", style: TextStyle(fontSize: 40,),),
                                ),
                                Text("May contain inappropriate content",
                                  style: TextStyle(fontSize: 16,),),
                                Text(
                                    "Tap to view if you are above 18 years old",
                                    style: TextStyle(fontSize: 16,)),
                              ],
                            ),
                          ),),
                      ) : GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    viewImage(widget.url, context,
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
    likesLength = widget.likes.length;
    dislikesLength = widget.likes.length;
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
          Container(
            margin: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            child: Text(
              "${widget.caption}",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          ListTile(
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("${widget.likes.length - widget.dislikes.length}",
                    style: TextStyle(
                        fontSize: 20
                    ),),
                  IconButton(
                    icon: Icon(Icons.thumb_up),
                    color: isLiked != null && isLiked
                        ? Color(0xffFF8F8F)
                        : null,
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
        ],
      ),
    );
  }

  setLikeAndDislike() async
  {
    if (await widget.likes[("${Constants.ownerName}")] == "${Constants.ownerName}") {
      isLiked = true;
    }
    else {
      isLiked = false;
    }
    if (await widget.dislikes[widget
        .dislikes("${Constants.ownerName}")] == "${Constants.ownerName}") {
      isDisliked = true;
    }
    else {
      isLiked = false;
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
    if(temp)
      {
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
    if(temp)
    {
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

  var likesList;
  var dislikesList;

  updateLike(bool newVal) async
  {
    print('Called update like');
    await selectedTagRef
        .where('postUid', isEqualTo: widget.postUid)
        .getDocuments().then((docs) async {
      likesList = await docs.documents[0].data["likes"];
      if (newVal) {
        likesList.add("${Constants.ownerName.toLowerCase()}");
      }
      else {
        likesList.removeAt(
            likesList.indexOf("${Constants.ownerName.toLowerCase()}"));
      }
      Map<String, dynamic> likeListMap = {
        'likes': likesList,
      };
      await selectedTagRef.document(docs.documents[0].documentID).updateData(
          likeListMap);
    });
  }

  updateDislike(bool newVal) async
  {
    await selectedTagRef
        .where('postUid', isEqualTo: widget.postUid)
        .getDocuments().then((docs) async {
      dislikesList = await docs.documents[0].data["dislikes"];
      if (newVal && isDisliked) {
        dislikesList.add("${Constants.ownerName.toLowerCase()}");
      }
      else {
        if (!newVal) {
          dislikesList.removeAt(
              dislikesList.indexOf("${Constants.ownerName.toLowerCase()}"));
        }
        else {

        }
      }
      Map<String, dynamic> dislikeListMap = {
        'dislikes': dislikesList,
      };
      await selectedTagRef.document(docs.documents[0].documentID).updateData(
          dislikeListMap);
    });
  }


  getUserProfileUrl() async {
    profileUrl = await databaseMethods.getProfileUrlByName(widget.username);
    if (mounted) {
      setState(() {

      });
    }
  }
}
