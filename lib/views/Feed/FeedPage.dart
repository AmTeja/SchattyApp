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
import 'package:schatty/views/Feed/BuildContent.dart';
import 'package:schatty/views/Feed/Post.dart';
import 'file:///C:/Users/Dell/AndroidStudioProjects/schatty/lib/views/Chatroom/MainChatsRoom.dart';
import 'package:schatty/views/NewSearch.dart';
import 'package:schatty/widgets/widget.dart';
import '../Authenticate/AuthHome.dart';
import '../Settings/SettingsView.dart';
import '../Settings/editProfile.dart';

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

PageController pageController;

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

  bool isDark = false;
  bool dev = true;
  bool error = false;

  AnimationController _animationController;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Animation<double> animation;
  CurvedAnimation curve;

  Stream postStream;

  @override
  void initState() {
    super.initState();
    error = false;
    getThemePreference();
    getUserInfo();
    setupAnimations();
    setTagStream(selectedTag);
    pageController = new PageController(initialPage: 0, keepPage: true);
  }

  getThemePreference() async {
    themeChangeProvider.darkTheme = await Preferences.getThemePreference();
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
                              builder: (context) => NewSearch(),
                            ));
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostContent(
                                isDark: isDark,
                                username: username,
                                profileUrl: url,
                              ),
                            ));
                      }
                    },
                  )
                : null,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.endDocked,
            bottomNavigationBar: bottomNavBar(context, darkTheme),
            body: PageView(
              controller: pageController,
              onPageChanged: onPageChanged,
              pageSnapping: true,
              children: [
                ChatRoom(),
                newBody(),
                Container(
                  child: Center(
                    child: Text(
                      "Will Trend Soon!",
                      style: TextStyle(
                        fontSize: 40,
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget newBody() {
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
                          header: BezierCircleHeader(),
                          controller: _refreshController,
                          onRefresh: _onRefresh,
                          onLoading: _onLoading,
                          child: SingleChildScrollView(
                            physics: ScrollPhysics(),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Container(
                                        padding: EdgeInsets.only(
                                            top: 20, left: 20, right: 10),
                                        child: Text(
                                          "Discover",
                                          style: TextStyle(
                                            fontSize: 38,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Segoe UI",
                                          ),
                                        )),
                                    Flexible(
                                      flex: 3,
                                      child: Container(
                                        alignment: Alignment.center,
                                        width: 220,
                                        height: 40,
                                        child: TextField(
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          decoration: InputDecoration(
                                              suffixIcon: IconButton(
                                            icon: Icon(Icons.search),
                                            onPressed: () {},
                                          )),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditProfile(username, uid),
                                            ));
                                      },
                                      child: Flexible(
                                        flex: 1,
                                        child: Container(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12.0,
                                                vertical: 8.0),
                                            child: CircleAvatar(
                                              radius: 23,
                                              child: ClipOval(
                                                child: url != null
                                                    ? CachedNetworkImage(
                                                        width: 60,
                                                        height: 60,
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
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 20),
                                  height: 40,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      showTag("Sci-Fi"),
                                      showTag("Tech"),
                                      showTag("Art"),
                                      showTag("Animals"),
                                      showTag("History"),
                                    ],
                                  ),
                                ),
                                ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: snapshot.data.documents.length,
                                  itemBuilder: (context, index) {
                                    return snapshot.hasData
                                        ? BuildPost(
                                            isDark: isDark,
                                            url: snapshot.data.documents[index]
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
                                          )
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

  Widget showTag(String tag) {
    return GestureDetector(
      onTap: () {
        selectTag(tag);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Container(
          height: 30,
          width: 60,
          decoration: BoxDecoration(
              color: selectedTag == tag ? Color(0xFF7ED9F1) : null,
              borderRadius: BorderRadius.circular(23)),
          child: Center(
            child: Text(
              tag,
              style: TextStyle(
                  fontFamily: "Segoe UI",
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
        ),
      ),
    );
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
//                  backgroundColor: Colors.blue,
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
                        ? Text(
                            Constants.ownerName,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 22,
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
                applicationVersion: '0.3 (Beta)',
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

  Widget bottomNavBar(context, darkThemeData) {
    return Consumer<DarkThemeProvider>(
      builder: (BuildContext context, value, Widget child) {
        return AnimatedBottomNavigationBar(
          icons: [Icons.chat, Icons.home, Icons.trending_up],
          backgroundColor:
              darkThemeData.darkTheme ? Color(0xff373A36) : Color(0xFF7ED9F1),
          activeIndex: _page,
          activeColor: Colors.white,
          splashColor: Color(0xFFFFFFFF),
          notchAndCornersAnimation: animation,
          splashSpeedInMilliseconds: 300,
          gapLocation: GapLocation.end,
          notchSmoothness: NotchSmoothness.smoothEdge,
          leftCornerRadius: 0,
          rightCornerRadius: 0,
          onTap: (index) => setState(() => navigationTapped(index)),
        );
      },
    );
  }

  getUserInfo() async {
    await firebaseAuth.currentUser().then((docs) {
      uid = docs.uid;
    });
    url =
        await databaseMethods.getProfileUrl(Constants.ownerName.toLowerCase());
    username = Constants.ownerName.toLowerCase();
    setState(() {});
  }

  setTagStream(String selectedTag) async {
    try {
      postStream = Firestore.instance
          .collection("Posts")
          .document('Public')
          .collection(selectedTag)
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

  logOut(BuildContext context) async {
    dispose();
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user.providerId != "Google") {
      authMethods.signOut();
      print("not google :)");
    } else {
      authMethods.signOutGoogle();
    }
    databaseMethods.updateToken("", Constants.ownerName.toLowerCase());
    Preferences.saveUserLoggedInSharedPreference(false);
    Preferences.saveUserNameSharedPreference(null);
    Preferences.saveUserEmailSharedPreference(null);
    Preferences.saveUserImageURL(null);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => AuthHome()));
  }

  void _onRefresh() async {
    // monitor network fetch
    setTagStream(selectedTag);
    await Future.delayed(Duration(milliseconds: 1000));
    setState(() {});
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void selectTag(String tag) {
    setState(() {
      selectedTag = tag;
      setTagStream(selectedTag);
    });
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    setState(() {});
    _refreshController.loadComplete();
  }

  void navigationTapped(int page) {
    pageController.animateToPage(page,
        duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  void onPageChanged(int page) async {
    isDark = await Preferences.getThemePreference();
    setState(() {
      this._page = page;
    });
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
}
