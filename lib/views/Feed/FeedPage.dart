import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:schatty/views/Feed/BuildContent.dart';
import 'package:schatty/views/Feed/Post.dart';
import 'package:schatty/views/NewSearch.dart';
import 'package:schatty/widgets/widget.dart';

import '../Authenticate/AuthHome.dart';
import '../Settings/SettingsView.dart';
import '../Settings/editProfile.dart';

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
  String selectedTag = "Sci-Fi";
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

  Widget bottomNavBar(context, darkThemeData) {
    return Consumer<DarkThemeProvider>(
      builder: (BuildContext context, value, Widget child) {
        return AnimatedBottomNavigationBar(
          icons: [Icons.chat, Icons.home],
          backgroundColor:
              darkThemeData.darkTheme ? Color(0xff373A36) : Color(0xFF7ED9F1),
          activeIndex: _page,
          activeColor: Colors.white,
          splashColor: Color(0xFFFFFFFF),
          notchAndCornersAnimation: animation,
          splashSpeedInMilliseconds: 300,
          gapLocation: GapLocation.center,
          notchSmoothness: NotchSmoothness.smoothEdge,
          leftCornerRadius: 0,
          rightCornerRadius: 0,
          onTap: (index) => setState(() => navigationTapped(index)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final darkTheme = Provider.of<DarkThemeProvider>(context);
    return ChangeNotifierProvider<DarkThemeProvider>(
      create: (_) {
        return themeChangeProvider;
      },
      child: Consumer<DarkThemeProvider>(
        builder: (BuildContext context, value, Widget child) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Schatty"),
              centerTitle: true,
              actions: [],
            ),
            drawer: Theme(data: Theme.of(context), child: mainDrawer(context)),
            floatingActionButton: _page != 2
                ? FloatingActionButton(
                    elevation: 8,
                    backgroundColor: Color(0xff373A36),
                    child: _page == 0
                        ? Icon(Icons.search, size: 35, color: Color(0xffffffff))
                        : Icon(
                            Icons.add,
                            size: 35,
                            color: Color(0xffffffff),
                          ),
                    onPressed: () {
                      if (_page == 0) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewSearch(
                                isPost: false,
                              ),
                            ));
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PostContent(
                                      isDark: isDark,
                                      username: username,
                                      profileUrl: url,
                                    )));
                      }
                    },
                  )
                : null,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: bottomNavBar(context, darkTheme),
            body: PageView(
              controller: pageController,
              onPageChanged: onPageChanged,
              pageSnapping: true,
              children: [
                ChatRoom(),
                FeedBody(darkTheme),
//                Container(
//                  child: Center(
//                    child: Text(
//                      "Will Trend Soon!",
//                      style: TextStyle(
//                        fontSize: 40,
//                      ),
//                    ),
//                  ),
//                )
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
  }

  logOut(BuildContext context) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    await databaseMethods.updateToken("", user.uid);
    Preferences.saveUserLoggedInSharedPreference(false);
    Preferences.saveUserNameSharedPreference(null);
    Preferences.saveUserEmailSharedPreference(null);
    Preferences.saveUserImageURL(null);
    if (await Preferences.getIsGoogleUser()) {
      authMethods.signOutGoogle();
      print('Is Google');
    } else {
      authMethods.signOut();
      print('Is not google');
    }
    Preferences.saveIsGoogleUser(null);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => AuthHome()));
  }

  Widget mainDrawer(BuildContext context) {
    return Drawer(
      elevation: 4,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Column(
              children: <Widget>[
                CircleAvatar(
                  radius: 50,
                  child: ClipOval(
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: url != null
                          ? CachedNetworkImage(
                              imageUrl: url,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              "assets/images/username.png",
                              fit: BoxFit.fill,
                            ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 40,
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: Constants.ownerName != null
                        ? FittedBox(
                            child: Text(
                              Constants.ownerName,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 22,
                              ),
                            ),
                          )
                        : Text("Error"),
                  ),
                )
              ],
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          EditProfile(Constants.ownerName, uid)));
            },
            title: Text("Edit profile",
                style: TextStyle(
                  fontSize: 20,
                )),
            trailing: Icon(Icons.edit),
          ),
//          ListTile(
//            onTap: () {
//              Navigator.pop(context);
//              Navigator.pushReplacement(
//                  context, MaterialPageRoute(builder: (context) => ChatRoom()));
//            },
//            title: Text(
//              'Refresh',
//              style: TextStyle(
//                fontSize: 20,
//              ),
//            ),
//            trailing: Icon(Icons.refresh),
//          ),
          ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsView(),
                  ));
            },
            title: Text(
              'Settings',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            trailing: Icon(Icons.settings),
          ),
          ListTile(
              //Logout Tile
              onTap: () {
                logOut(context);
              },
              title: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              trailing: Icon(Icons.exit_to_app)),
          ListTile(
            //About Tile
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "Schatty",
                applicationVersion: '1.0.5 (Beta)',
                applicationIcon: SchattyIcon(),
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  Text("Developed by: Krishna Teja J"),
                  SizedBox(
                    height: 10,
                  ),
                  Text("Designed by: D Sai Sandeep")
                ],
              );
            },
            title: Text(
              'About',
              style: TextStyle(fontSize: 20),
            ),
            trailing: Icon(Icons.info),
          ),
//          ListTile(
//            onTap: () {
//              Navigator.push(
//                  context,
//                  MaterialPageRoute(
//                      builder: (context) =>
//                          CrashPage()));
//            },
//            title: Text("Crash",
//                style: TextStyle(
//                  fontSize: 20,
//                )),
//            trailing: Icon(Icons.error_outline),
//          ),
        ],
      ),
    );
  }

  void navigationTapped(int page) {
    pageController.animateToPage(page,
        duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  Widget FeedBody(darkTheme) {
    return !error
        ? GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: StreamBuilder(
          stream: postStream,
          builder: (context, snapshot) {
            return snapshot.hasData
                ? SmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              header: BezierCircleHeader(
                circleColor: darkTheme.darkTheme
                    ? Colors.white
                    : Color(0xFF7ED9F1),
              ),
              controller: _refreshController2,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              child: SingleChildScrollView(
                physics: ScrollPhysics(),
                child: Column(
                  children: [
                    Container(
                        alignment: Alignment.center,
                        padding:
                        EdgeInsets.symmetric(vertical: 9.0),
                        child: Text(
                          "Discover",
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text("Sort by: "),
                        Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 2, horizontal: 4),
                          child: DropdownButton(
                            value: sortingMethod,
                            onChanged: (val) => _sort(val),
                            items: [
                              DropdownMenuItem(
                                child: Text("New"),
                                value: "New",
                              ),
                              DropdownMenuItem(
                                  child: Text("Likes"),
                                  value: "Likes"),
                              DropdownMenuItem(
                                  child: Text("Dislikes"),
                                  value: "Dislikes"),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      NewSearch(
                                        isPost: false,
                                      ),
                                ));
                          },
                        )
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 20),
                      height: 40,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          StreamBuilder(
                            stream: tagStream,
                            builder: (context, snap) {
                              return snap.hasData
                                  ? ListView.builder(
                                  shrinkWrap: true,
                                  physics:
                                  NeverScrollableScrollPhysics(),
                                  scrollDirection:
                                  Axis.horizontal,
                                  itemCount: snap
                                      .data.documents.length,
                                  itemBuilder:
                                      (context, index) {
                                    return showTag(snap
                                        .data
                                        .documents[index]
                                        .data['tag']);
                                  })
                                  : Container(
                                child: Center(
                                  child: Text("OOF"),
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      cacheExtent:
                      snapshot.data.documents.length / 2,
                      controller: feedListController,
                      shrinkWrap: true,
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index) {
                        var ref = snapshot.data.documents[index];
                        return snapshot.hasData
                            ? reportedPosts.indexOf(
                            ref.data['postUid']) ==
                            -1 &&
                            reportedPosts.indexOf(
                                ref.data['postUid']) !=
                                null
                            ? BuildPost(
                          isVideo: snapshot.data.documents[index]
                              .data["isVideo"] ?? false,
                          time: snapshot
                              .data
                              .documents[index]
                              .data['time'],
                          url: snapshot
                              .data
                              .documents[index]
                              .data["url"],
                          username: snapshot
                              .data
                              .documents[index]
                              .data["username"],
                          topic: selectedTag,
                          caption: snapshot
                              .data
                              .documents[index]
                              .data["caption"],
                          postUid: snapshot
                              .data
                              .documents[index]
                              .data["postUid"] ??
                              "null",
                          likes: ref.data['likes'],
                          dislikes: ref.data['dislikes'],
                          nsfw: snapshot
                              .data
                              .documents[index]
                              .data["NSFW"] ??
                              false,
                          title: snapshot
                              .data
                              .documents[index]
                              .data["title"],
                          numLikes: snapshot
                              .data
                              .documents[index]
                              .data["numLikes"] ??
                              0,
                          numDislikes: snapshot
                              .data
                              .documents[index]
                              .data["numDislikes"] ??
                              0,
                        )
                            : SizedBox.shrink()
                            : Container(
                          child: Center(
                            child: Text("No Posts"),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
                : Container(
              child: Center(
                child: Text("No Posts"),
              ),
            );
          }),
    )
        : Container(
      child: Center(
        child: Text("Error"),
      ),
    );
  }

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
    setState(() {});
  }

  void onPageChanged(int page) async {
    isDark = await Preferences.getThemePreference();
    setState(() {
      this._page = page;
    });
  }

  void selectTag(String tag) {
    setState(() {
      selectedTag = tag;
      setTagStream(selectedTag, descendingOrder);
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
      duration: Duration(seconds: 1),
      vsync: this,
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
