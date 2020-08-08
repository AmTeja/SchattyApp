import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:schatty/enums/globalcolors.dart';
import 'package:schatty/helper/NavigationService.dart';
import 'package:schatty/helper/constants.dart';
import 'package:schatty/helper/preferencefunctions.dart';
import 'package:schatty/provider/DarkThemeProvider.dart';
import 'package:schatty/services/AuthenticationManagement.dart';
import 'package:schatty/services/DatabaseManagement.dart';
import 'package:schatty/views/Authenticate/AuthHome.dart';
import 'package:schatty/views/Chatroom/MainChatScreenInstance.dart';
import 'package:schatty/views/NewSearch.dart';
import 'package:schatty/views/Settings/SettingsView.dart';
import 'package:schatty/views/Settings/editProfile.dart';
import 'package:schatty/widgets/InAppNotification.dart';
import 'package:schatty/widgets/widget.dart';
import 'package:time_machine/time_machine.dart';

import 'ChatTile.dart';

// ignore: missing_return
Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
  if (message.containsKey('data')) {
// Handle data message
    print("Background Data: $message");
  }

  if (message.containsKey('notification')) {
// Handle notification message
    print("Background notification: $message");
  }

// Or do other work.
}

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom>
    with SingleTickerProviderStateMixin {
  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  NavigationService navigationService = new NavigationService();
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  DarkThemeProvider darkThemeProvider = new DarkThemeProvider();
  GlobalColors gc = new GlobalColors();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

//  final StorageReference storageRef = FirebaseStorage.instance.ref().child(fileName);
  BuildContext newContext;
  String fileName =
      Constants.ownerName + Random().nextInt(10000).toString() + '.$extension';
  Stream chatRoomsStream;

  bool newMessageReceived = false;
  bool isLoading = false;
  bool isChatRoom = true;

  BuildContext scaffoldContext;

  var imageUrl;

  Map<dynamic, dynamic> archivedUsers = {"amteja": false};

  String newMessageUsername;
  String url;
  String uid;

  PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = Constants.pageController;
    timeSetup();
    setState(() {
      isChatRoom = true;
    });
    configureFirebaseListeners();
    getUserInfo();
  }

  timeSetup() async {
    try {
      await TimeMachine.initialize({'rootBundle': rootBundle});
    } catch (e) {
      print("Error in timesetup: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    scaffoldContext = context;
    final darkTheme = Provider.of<DarkThemeProvider>(context);
    newContext = context;
    return !isLoading
        ? Scaffold(
      appBar: AppBar(
        title: Text("Schatty"),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () {
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => NewSearch(isPost: false,)));
          }),
          IconButton(icon: Icon(Icons.arrow_forward_ios), onPressed: () {
            pageController.animateToPage(
                1, duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut);
          })
        ],
      ),
      drawer: Theme(data: Theme.of(context), child: mainDrawer(context)),
      body: Container(
        child: chatRoomList(darkTheme),
      ),
    )
        : Scaffold(
            backgroundColor: Colors.black, body: loadingScreen("Hold on"));
  }

  Widget suchEmpty(BuildContext context) {
    return Center(
        child: Container(
          width: 350,
          height: 300,
          decoration: BoxDecoration(
              color: Color.fromARGB(196, 14, 14, 14),
              borderRadius: BorderRadius.circular(43)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Such Empty",
                  style: TextStyle(color: Colors.white, fontSize: 40),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Find someone using search...",
                  style: TextStyle(color: Colors.white, fontSize: 26),
                ),
              )
            ],
          ),
        ));
  }

  Widget chatRoomList(darkTheme) {
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (context, snapshot) {
        return snapshot.hasData && snapshot.data.documents.length != 0
            ? SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          header: BezierCircleHeader(
            circleColor:
            darkTheme.darkTheme ? Colors.white : Color(0xFF7ED9F1),
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: ListView.builder(
              reverse: false,
              cacheExtent: 5,
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                final lastMessage =
                snapshot.data.documents[index].data["lastMessage"];
                if (lastMessage[0] != "" && lastMessage[1] != "") {
                  return ChatRoomTile(
                    username: snapshot
                        .data.documents[index].data["chatRoomId"]
                        .toString()
                        .replaceAll("_", "")
                        .replaceAll(
                        Constants.ownerName.toLowerCase(), ""),
                    chatRoomId:
                    snapshot.data.documents[index].data["chatRoomId"],
                    urls:
                    snapshot.data.documents[index].data["photoUrls"],
                    displayNames: snapshot
                        .data.documents[index].data["displayNames"],
                    lastMessageDetails: snapshot
                        .data.documents[index].data["lastMessage"] ??
                        null,
                    lastTime:
                    snapshot.data.documents[index].data["lastTime"],
                    seenBy:
                    (snapshot.data.documents[index].data["seenBy"]) ??
                        null,
                    archivedUsers: snapshot.data.documents[index]
                        .data["archivedUsers"] ??
                        null,
                  );
                } else {
                  return Container();
                }
              }),
        )
            : SmartRefresher(
            enablePullDown: true,
            enablePullUp: false,
            header: BezierCircleHeader(
              circleColor:
              darkTheme.darkTheme ? Colors.white : Color(0xFF7ED9F1),
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: suchEmpty(context));
      },
    );
  }

  //Notification functions
  configureFirebaseListeners() {
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        var notification = message['notification'];
        String sentUser = await notification["title"];
        String sentMessage = await notification["body"];

        newMessageReceived = true;
        newMessageUsername = sentUser;

        setState(() {
          print('Called');
        });

        showOverlayNotification((scaffoldContext) {
          return MessageNotification(
            title: sentUser,
            body: sentMessage,
            onReply: () {
              OverlaySupportEntry.of(scaffoldContext).dismiss();
              toast('you checked this message');
            },
          );
        }, duration: Duration(seconds: 2));
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch: $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('OnResume: $message');
        await sendToChatScreen(message);
      },
      onBackgroundMessage: Platform.isIOS ? null : myBackgroundMessageHandler,
    );
  }

  sendToChatScreen(Map<String, dynamic> message) async {
    String chatRoomID;
    var data = message["data"];
    String sentUser = await data["sentUser"];
    String toUser = await data["toUser"];
    String roomID1 =
    getChatRoomID(sentUser.toLowerCase(), toUser.toLowerCase());
    String roomID2 =
    getChatRoomID(toUser.toLowerCase(), sentUser.toLowerCase());
    try {
      await Firestore.instance
          .collection("ChatRoom")
          .where("chatRoomId", isEqualTo: roomID1)
          .getDocuments()
          .then((docs) async {
        chatRoomID = await docs.documents[0].data["chatRoomId"];
      });
      if (chatRoomID == null) {
        await Firestore.instance
            .collection("ChatRoom")
            .where("chatRoomId", isEqualTo: roomID2)
            .getDocuments()
            .then((docs) async {
          chatRoomID = await docs.documents[0].data["chatRoomId"];
        });
      }
      String username = chatRoomID
          .replaceAll("_", "")
          .replaceAll(Constants.ownerName.toLowerCase(), "");
      await Navigator.push(
          newContext,
          MaterialPageRoute(
              builder: (newContext) => ChatScreen(chatRoomID, username)));
    } catch (e) {
      print("Sending To Chat ERROR: $e");
    }
  }

  //Initial functions
  uploadToken() async {
    String token;
    token = await firebaseMessaging.getToken();
    databaseMethods.updateToken(token, uid);
  }

  getChatRoomID(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  getUserInfo() async {
    print('Main Chats room: Get info called');
    Constants.ownerName = await Preferences.getUserNameSharedPreference();
    try {
      databaseMethods
          .getChatRooms(Constants.ownerName.toLowerCase())
          .then((val) {
        setState(() {
          chatRoomsStream = val;
        });
      });
      await firebaseAuth.currentUser().then((docs) {
        uid = docs.uid;
      });
      uploadToken();
      url = await Preferences.getUserImageURL() ??
          await databaseMethods
              .getProfileUrlByName(Constants.ownerName.toLowerCase());
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("getUserInfo: $e");
    }
  }

  //Refresh functions
  void _onRefresh() async {
    print('Refreshed');
    getUserInfo();
    await Future.delayed(Duration(milliseconds: 1000));
    setState(() {});
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {});
    _refreshController.loadComplete();
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
                applicationVersion: '1.0.6 (Beta)',
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
        ],
      ),
    );
  }
}
