import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:schatty/helper/constants.dart';
import 'package:schatty/helper/preferencefunctions.dart';
import 'package:schatty/provider/DarkThemeProvider.dart';
import 'package:schatty/services/AuthenticationManagement.dart';
import 'package:schatty/services/DatabaseManagement.dart';
import 'package:schatty/views/Chatroom/MainChatsRoom.dart';
import 'package:tiktoklikescroller/tiktoklikescroller.dart';

import 'BuildContent.dart';
import 'Post.dart';

PageController pageController;

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage>
    with SingleTickerProviderStateMixin {
  var _page = 0; //default index of first screen

  //Class Calls
  ChatRoom chatRoom = new ChatRoom();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  AuthMethods authMethods = new AuthMethods();

  //Instances
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  DarkThemeProvider themeChangeProvider = new DarkThemeProvider();

  //Vars
  String uid;
  String url;
  String selectedTag = "Memes";
  String username;
  String streamOrder = "time";
  String sortingMethod = "New";

  bool isDark = false;
  bool dev = true;
  bool error = false;
  bool descendingOrder = true;

  List reportedPosts;

  AnimationController _animationController;
  final feedListController = ScrollController();
  RefreshController _refreshController2 =
      RefreshController(initialRefresh: false);

  Animation<double> animation;
  CurvedAnimation curve;

  Stream postStream;
  Stream tagStream;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DarkThemeProvider>(
      create: (_) {
        return themeChangeProvider;
      },
      child: Consumer<DarkThemeProvider>(
        builder: (BuildContext context, value, Widget child) {
          return Scaffold(
            extendBody: true,
            body: PageView(
              controller: pageController,
              onPageChanged: onPageChanged,
              pageSnapping: true,
              children: [
                ChatRoom(),
                SafeArea(top: false, child: newBody()),
              ],
            ),
          );
        },
      ),
    );
  }

  getThemePreference() async {
    themeChangeProvider.darkTheme = await Preferences.getThemePreference();
  }

  getUserInfo() async {
    print('Called');
    await firebaseAuth.currentUser().then((docs) {
      uid = docs.uid;
    });
    username = Constants.ownerName.toLowerCase();
    url = await databaseMethods.getProfileUrlByName(username);
    await Firestore.instance
        .collection('users')
        .document(uid)
        .get()
        .then((docs) {
      reportedPosts = docs.data['reportedPosts'];
    });
    setState(() {});
  }

  getReportedList() async {
    await Firestore.instance
        .collection('users')
        .document(uid)
        .get()
        .then((docs) {
      reportedPosts = docs.data['reportedPosts'];
    });
  }

  @override
  void initState() {
    super.initState();
    error = false;
    getThemePreference();
    getUserInfo();
    setupAnimations();
    setTagStream(selectedTag, descendingOrder);
    setTagsStream();
    pageController = new PageController(initialPage: 0, keepPage: true);
    Constants.pageController = pageController;
  }

  void navigationTapped(int page) {
    pageController.animateToPage(page,
        duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  Widget newBody() {
    return Stack(
      children: [
        Container(
          child: StreamBuilder(
              stream: postStream,
              builder: (context, snapshot) {
                return snapshot.hasData
                    && snapshot.data.documents.length != 0
                    ? TikTokStyleFullPageScroller(
                    contentSize: snapshot.data.documents.length,
                    swipeThreshold: 0.4,
                    swipeVelocityThreshold: 2000,
                    animationDuration: Duration(milliseconds: 300),
                    builder: (BuildContext context, int index) {
                      return BuildPost(
                        isDark: isDark,
                        loop: false,
                        isVideo: snapshot
                            .data.documents[index].data["isVideo"] ??
                            false,
                        time: snapshot.data.documents[index].data['time'],
                        url: snapshot.data.documents[index].data["url"],
                        username:
                        snapshot.data.documents[index].data["username"],
                        topic: selectedTag,
                        caption:
                        snapshot.data.documents[index].data["caption"],
                        postUid: snapshot
                            .data.documents[index].data["postUid"] ??
                            "null",
                        likes: snapshot.data.documents[index].data['likes'],
                        dislikes:
                        snapshot.data.documents[index].data['dislikes'],
                        nsfw: snapshot.data.documents[index].data["NSFW"] ??
                            false,
                        title: snapshot.data.documents[index].data["title"],
                        numLikes: snapshot
                            .data.documents[index].data["numLikes"] ??
                            0,
                        numDislikes: snapshot.data.documents[index]
                            .data["numDislikes"] ??
                            0,
                      );
                    })
                    : Center(
                  child: Text("No posts"),
                );
              }),
        ),
        Positioned(
            left: 20,
            top: MediaQuery
                .of(context)
                .padding
                .top + 3,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    Constants.pageController.animateToPage(
                        0, duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  },
                  iconSize: 25,
                ),
                IconButton(
                  icon: Icon(Icons.add_box_outlined),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) =>
                            PostContent(isDark: isDark,
                              profileUrl: url,
                              username: username,)));
                  },
                  iconSize: 25,
                ),
              ],
            )),
        Positioned(
            right: 10,
            top: MediaQuery.of(context).padding.top + 3,
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: DropdownButton<String>(
                    value: sortingMethod,
                    onChanged: (val) {
                      _sort(val);
                    },
                    items: [
                      DropdownMenuItem(
                        value: "New",
                        child: Text(
                          "New",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Likes",
                        child: Text(
                          "Likes",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {
                    showTags();
                  },
                  iconSize: 25,
                ),
              ],
            ))
      ],
    );
  }

  showTags() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Select tag"),
            content: Container(
              color: Colors.transparent,
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.55,
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.7,
              child: StreamBuilder(
                stream: tagStream,
                builder: (context, snap) {
                  return snap.hasData ? ListView.builder(
                      itemCount: snap.data.documents.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return showTag(snap.data.documents[index].data['tag']);
                      }
                  ) : Container();
                },
              ),
            ),
          );
        }
    );
  }

  // ignore: non_constant_identifier_names
//  Widget FeedBody(darkTheme) {
//    return !error
//        ? GestureDetector(
//            onTap: () {
//              FocusScope.of(context).unfocus();
//            },
//            child: StreamBuilder(
//                stream: postStream,
//                builder: (context, snapshot) {
//                  return snapshot.hasData
//                      ? SmartRefresher(
//                          enablePullDown: true,
//                          enablePullUp: false,
//                          header: BezierCircleHeader(
//                            circleColor: darkTheme.darkTheme
//                                ? Colors.white
//                                : Color(0xFF7ED9F1),
//                          ),
//                          controller: _refreshController2,
//                          onRefresh: _onRefresh,
//                          onLoading: _onLoading,
//                          child: SingleChildScrollView(
//                            physics: ScrollPhysics(),
//                            child: Column(
//                              children: [
//                                Container(
//                                    alignment: Alignment.center,
//                                    padding:
//                                        EdgeInsets.symmetric(vertical: 9.0),
//                                    child: Text(
//                                      "Discover",
//                                      style: TextStyle(
//                                        fontSize: 50,
//                                        fontWeight: FontWeight.bold,
//                                      ),
//                                    )),
//                                Row(
//                                  mainAxisAlignment: MainAxisAlignment.center,
//                                  crossAxisAlignment: CrossAxisAlignment.center,
//                                  mainAxisSize: MainAxisSize.max,
//                                  children: [
//                                    Text("Sort by: "),
//                                    Container(
//                                      margin: EdgeInsets.symmetric(
//                                          vertical: 2, horizontal: 4),
//                                      child: DropdownButton(
//                                        value: sortingMethod,
//                                        onChanged: (val) => _sort(val),
//                                        items: [
//                                          DropdownMenuItem(
//                                            child: Text("New"),
//                                            value: "New",
//                                          ),
//                                          DropdownMenuItem(
//                                              child: Text("Likes"),
//                                              value: "Likes"),
//                                          DropdownMenuItem(
//                                              child: Text("Dislikes"),
//                                              value: "Dislikes"),
//                                        ],
//                                      ),
//                                    ),
//                                    IconButton(
//                                      icon: Icon(Icons.search),
//                                      onPressed: () {
//                                        Navigator.push(
//                                            context,
//                                            MaterialPageRoute(
//                                              builder: (context) => NewSearch(
//                                                isPost: false,
//                                                topic: selectedTag,
//                                              ),
//                                            ));
//                                      },
//                                    )
//                                  ],
//                                ),
//                                Container(
//                                  margin: EdgeInsets.symmetric(vertical: 20),
//                                  height: 40,
//                                  width: MediaQuery.of(context).size.width,
//                                  child: ListView(
//                                    scrollDirection: Axis.horizontal,
//                                    children: [
//                                      StreamBuilder(
//                                        stream: tagStream,
//                                        builder: (context, snap) {
//                                          return snap.hasData
//                                              ? ListView.builder(
//                                                  shrinkWrap: true,
//                                                  physics:
//                                                      NeverScrollableScrollPhysics(),
//                                                  scrollDirection:
//                                                      Axis.horizontal,
//                                                  itemCount: snap
//                                                      .data.documents.length,
//                                                  itemBuilder:
//                                                      (context, index) {
//                                                    return showTag(snap
//                                                        .data
//                                                        .documents[index]
//                                                        .data['tag']);
//                                                  })
//                                              : Container(
//                                                  child: Center(
//                                                    child: Text("OOF"),
//                                                  ),
//                                                );
//                                        },
//                                      )
//                                    ],
//                                  ),
//                                ),
//                                ListView.builder(
//                                  physics: NeverScrollableScrollPhysics(),
//                                  cacheExtent:
//                                      snapshot.data.documents.length / 2,
//                                  controller: feedListController,
//                                  shrinkWrap: true,
//                                  itemCount: snapshot.data.documents.length,
//                                  itemBuilder: (context, index) {
//                                    var ref = snapshot.data.documents[index];
//                                    return snapshot.hasData &&
//                                            snapshot.data.documents.length != 0
//                                        ? reportedPosts.indexOf(
//                                                        ref.data['postUid']) ==
//                                                    -1 &&
//                                                reportedPosts.indexOf(
//                                                        ref.data['postUid']) !=
//                                                    null
//                                            ? MakePost(
//                                                isVideo: snapshot
//                                                        .data
//                                                        .documents[index]
//                                                        .data["isVideo"] ??
//                                                    false,
//                                                time: snapshot
//                                                    .data
//                                                    .documents[index]
//                                                    .data['time'],
//                                                url: snapshot
//                                                    .data
//                                                    .documents[index]
//                                                    .data["url"],
//                                                username: snapshot
//                                                    .data
//                                                    .documents[index]
//                                                    .data["username"],
//                                                topic: selectedTag,
//                                                caption: snapshot
//                                                    .data
//                                                    .documents[index]
//                                                    .data["caption"],
//                                                postUid: snapshot
//                                                        .data
//                                                        .documents[index]
//                                                        .data["postUid"] ??
//                                                    "null",
//                                                likes: ref.data['likes'],
//                                                dislikes: ref.data['dislikes'],
//                                                nsfw: snapshot
//                                                        .data
//                                                        .documents[index]
//                                                        .data["NSFW"] ??
//                                                    false,
//                                                title: snapshot
//                                                    .data
//                                                    .documents[index]
//                                                    .data["title"],
//                                                numLikes: snapshot
//                                                        .data
//                                                        .documents[index]
//                                                        .data["numLikes"] ??
//                                                    0,
//                                                numDislikes: snapshot
//                                                        .data
//                                                        .documents[index]
//                                                        .data["numDislikes"] ??
//                                                    0,
//                                              )
//                                            : SizedBox.shrink()
//                                        : Container(
//                                            child: Center(
//                                              child: Text("No Posts"),
//                                            ),
//                                          );
//                                  },
//                                ),
//                              ],
//                            ),
//                          ),
//                        )
//                      : Container(
//                          child: Center(
//                            child: Text("No Posts"),
//                          ),
//                        );
//                }),
//          )
//        : Container(
//            child: Center(
//              child: Text("Error"),
//            ),
//          );
//  }

  _sort(value) {
    print('Called sort');
    sortingMethod = value;
    if (sortingMethod == "New") {
      streamOrder = 'time';
      descendingOrder = true;
    } else if (sortingMethod == "Likes") {
      streamOrder = 'numLikes';
      descendingOrder = true;
    } else if (sortingMethod == "Dislikes") {
      streamOrder = 'numDislikes';
      descendingOrder = true;
    }
    setTagStream(selectedTag, descendingOrder);
    if (mounted) {
      setState(() {});
    }
  }

  void onPageChanged(int page) async {
    isDark = await Preferences.getThemePreference();
    setState(() {
      this._page = page;
      print(page);
    });
  }

  void selectTag(String tag) {
    setState(() {
      selectedTag = tag;
      setTagStream(selectedTag, descendingOrder);
      Navigator.pop(context);
    });
  }

  setTagStream(String selectedTag, bool descendingOrder) async {
    try {
      postStream = Firestore.instance
          .collection("Posts")
          .document('Public')
          .collection(selectedTag)
          .orderBy(streamOrder, descending: descendingOrder)
          .snapshots();
      if (postStream == null) {
        error = true;
        print(error);
        setState(() {});
      }
    } catch (e) {
      print('PostStream Error: $e');
    }
  }

  setTagsStream() {
    tagStream = Firestore.instance
        .collection('Posts')
        .document('Public')
        .collection('Tags')
        .orderBy('posts', descending: true)
        .snapshots();
    setState(() {});
  }

  setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    curve = CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.5,
        1.0,
        curve: Curves.fastOutSlowIn,
      ),
    );
    animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(curve);
    _animationController.forward();
  }

  Widget showTag(String tag) {
    return GestureDetector(
      onTap: () {
        selectTag(tag);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Container(
          height: 30,
          width: 80,
          decoration: BoxDecoration(
              color: selectedTag == tag ? Color(0xFF7ED9F1) : null,
              borderRadius: BorderRadius.circular(23)),
          child: Center(
            child: Text(
              tag,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    setState(() {});
    _refreshController2.loadComplete();
  }

  void _onRefresh() async {
    // monitor network fetch
    setTagStream(selectedTag, descendingOrder);
    setTagsStream();
    getReportedList();
    await Future.delayed(Duration(milliseconds: 1000));
    setState(() {});
    // if failed,use refreshFailed()
    _refreshController2.refreshCompleted();
  }
}
