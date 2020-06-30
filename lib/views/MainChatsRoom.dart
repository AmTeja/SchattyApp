import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:path/path.dart';
import 'package:schatty/enums/globalcolors.dart';
import 'package:schatty/helper/NavigationService.dart';
import 'package:schatty/helper/constants.dart';
import 'package:schatty/helper/preferencefunctions.dart';
import 'package:schatty/services/AuthenticationManagement.dart';
import 'package:schatty/services/DatabaseManagement.dart';
import 'package:schatty/services/encryptionservice.dart';
import 'package:schatty/views/Authenticate/AuthHome.dart';
import 'package:schatty/views/MainChatScreenInstance.dart';
import 'package:schatty/views/NewSearch.dart';
import 'package:schatty/views/SettingsView.dart';
import 'package:schatty/views/editProfile.dart';
import 'package:schatty/widgets/widget.dart';

import 'TargetUserInfo.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  NavigationService navigationService = new NavigationService();
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  EncryptionService encryptionService = new EncryptionService();
  GlobalColors gc = new GlobalColors();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

//  final StorageReference storageRef = FirebaseStorage.instance.ref().child(fileName);
  BuildContext newContext;
  final String fileName =
      Constants.ownerName + Random().nextInt(10000).toString() + '.$extension';
  Stream chatRoomsStream;

  bool newMessageReceived = false;
  bool isLoading = false;

  var imageUrl;

  String url;
  String uid;

  @override
  void initState() {
    super.initState();
    setState(() {
//      isLoading = true;
    });
    uploadToken();
    configureFirebaseListeners();
    getUserInfo();
//    setupEncrpytion();
  }

  @override
  Widget build(BuildContext context) {
    newContext = context;
    return !isLoading
        ? Scaffold(
            drawer: Theme(data: Theme.of(context), child: mainDrawer(context)),
            appBar: AppBar(
              title: Text(
                "SCHATTY",
//              style: GoogleFonts.odibeeSans(fontSize: 28),
              ),
              elevation: 3,
            ),
            body: Container(
//                decoration: BoxDecoration(
//                    gradient: LinearGradient(colors: [
//                      Color.fromARGB(255, 0, 0, 0),
//                      Color.fromARGB(100, 39, 38, 38)
//                    ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
////                    image: DecorationImage(
////                        colorFilter: ColorFilter.mode(
////                            Colors.black.withOpacity(0.2),
////                            BlendMode.darken),
////                        image: ExactAssetImage(
////                          "assets/images/background.png",
////                        ),
////                        fit: BoxFit.cover)
//                ),
              child: chatRoomList(),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(
                Icons.search,
                size: 30,
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => NewSearch()));
              },
            ),
          )
        : Scaffold(
            backgroundColor: Colors.black, body: loadingScreen("Hold on"));
  }

  configureAdMob() {
    FirebaseAdMob.instance
        .initialize(appId: "ca-app-pub-1304691467262814~7353905593");
  }

  configureFirebaseListeners() {
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage: $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch: $message');
        await sendToChatScreen(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print('OnResume: $message');
        await sendToChatScreen(message);
      },
    );
  }

  sendToChatScreen(Map<String, dynamic> message) async {
    String chatRoomID;
    var data = message["data"];
    String sentUser = await data["sentUser"];
    String toUser = await data["toUser"];
    String roomID1 = getChatRoomID(sentUser, toUser);
    try {
      await Firestore.instance
          .collection("ChatRoom")
          .where("chatRoomId", isEqualTo: roomID1)
          .getDocuments()
          .then((docs) async {
        chatRoomID = await docs.documents[0].data["chatRoomId"];
        print(chatRoomID);
      });
      String username =
      chatRoomID.replaceAll("_", "").replaceAll(Constants.ownerName, "");
      await Navigator.push(
          newContext,
          MaterialPageRoute(
              builder: (newContext) => ChatScreen(chatRoomID, username)));
    } catch (e) {
      print(e);
    }
  }

  uploadToken() async {
    String token;
    token = await firebaseMessaging.getToken();
    print(token);
    databaseMethods.updateToken(token);
  }

  getChatRoomID(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  getUserInfo() async {
    Constants.ownerName = await Preferences.getUserNameSharedPreference();
    try {
      databaseMethods.getChatRooms(Constants.ownerName).then((val) {
        setState(() {
          chatRoomsStream = val;
        });
      });
      await firebaseAuth.currentUser().then((docs) {
        uid = docs.uid;
      });
      url = await databaseMethods.getProfileUrl();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("getUserInfo: $e");
    }
  }

  setupEncryption() async {
    try {
      print("Encryption Setting up");
      encryptionService.futureKeyPair = encryptionService.getKeyPair();
      encryptionService.keyPair = await encryptionService.futureKeyPair;
      Map<String, dynamic> keyMap = {
        "privateKey": encryptionService.keyPair.privateKey,
      };

      await Firestore.instance
          .collection('users')
          .where('uid', isEqualTo: uid)
          .getDocuments()
          .then((docs) async {
        await Firestore.instance
            .document('/users/${docs.documents[0].documentID}')
            .updateData(keyMap);
      });

      var privateString = await encryptionService
          .getPrivatekeyInPlain(encryptionService.keyPair);
      var publicString = await encryptionService
          .getPublicKeyInPlain(encryptionService.keyPair);
      print("Private: $privateString");
      print("Public: $publicString");
    } catch (e) {
      print("Encryption Error: $e");
    }
  }

  logOut(BuildContext context) async {
//    bool isGoogleUser = false;
//
//    isGoogleUser = await HelperFunctions.getIsGoogleUser();
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user.providerId != "Google") {
      authMethods.signOut();
      print("not google :)");
    } else {
      authMethods.signOutGoogle();
    }
    Preferences.saveUserLoggedInSharedPreference(false);
    Preferences.saveUserNameSharedPreference(null);
    Preferences.saveUserEmailSharedPreference(null);
    Preferences.saveUserImageURL(null);
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
//                  backgroundColor: Colors.blue,
                  child: ClipOval(
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: url != null
                          ? CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.cover,)
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
//            decoration: BoxDecoration(
//              color: Colors.black,
//            ),
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
          ListTile(
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => ChatRoom()));
            },
            title: Text(
              'Refresh',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            trailing: Icon(Icons.refresh),
          ),
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
                applicationVersion: '0.1 (Beta)',
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
          )
        ],
      ),
    );
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

  Widget chatRoomList() {
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
            reverse: false,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) {
              return ChatRoomTile(
                snapshot.data.documents[index].data["chatRoomId"]
                    .toString()
                    .replaceAll("_", "")
                    .replaceAll(Constants.ownerName, ""),
                snapshot.data.documents[index].data["chatRoomId"],
                snapshot.data.documents[index].data["photoURLS"],
                snapshot.data.documents[index].data["users"],
              );
            })
            : suchEmpty(context);
      },
    );
  }
}

class ChatRoomTile extends StatelessWidget {
  final String userName;
  final String chatRoomId;
  final urls;
  final users;

  ChatRoomTile(this.userName, this.chatRoomId, this.urls, this.users);

  final SlidableController slidableController = SlidableController();

  @override
  Widget build(BuildContext context) {
    String targetUrl;
    if (users[1] == userName) {
      targetUrl = urls[1];
    } else {
      targetUrl = urls[0];
    }
//    return GestureDetector(
//      onTap: () {
//        Navigator.push(
//            context,
//            MaterialPageRoute(
//                builder: (context) => ChatScreen(chatRoomId, userName)));
//      },
//      onLongPress: () {
//        Navigator.push(context,
//            MaterialPageRoute(builder: (context) => TargetUserInfo(userName)));
//      },
//      child: Container(
//        decoration: BoxDecoration(
////          borderRadius: BorderRadius.circular(23),
//          color: Color.fromARGB(40, 0, 0, 0),
//          border: Border(
//              bottom: BorderSide(
//                  color: Color.fromARGB(255, 141, 133, 133), width: 0.1)),
//        ),
//        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
//        margin: EdgeInsets.symmetric(vertical: 1),
//        child: Row(
//          mainAxisAlignment: MainAxisAlignment.start,
//          crossAxisAlignment: CrossAxisAlignment.center,
//          children: [
//            targetUrl == null
//                ? Container(
//              //Letter in the circle Container
//              height: 60,
//              width: 60,
//              alignment: Alignment.center,
//              decoration: BoxDecoration(
//                color: Colors.black,
//                borderRadius: BorderRadius.circular(40),
//              ),
//              child: Text(
//                "${userName.substring(0, 1).toUpperCase()}",
//                style: TextStyle(
//                  color: Colors.white,
//                  fontSize: 18,
//                ),
//              ),
//            )
//                : ClipOval(
//              child: CachedNetworkImage(
//                imageUrl: targetUrl,
//                height: 60,
//                width: 60,
//                fit: BoxFit.cover,
//              ),
//            ),
//            SizedBox(
//              width: 12,
//            ),
//            Text(
//              userName,
//              style: TextStyle(
//                fontSize: 20,
//                color: Colors.white,
//              ),
//            ),
//          ],
//        ),
//      ),
//    );

    return Slidable(
      key: Key("slidable"),
      controller: slidableController,
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => ChatScreen(chatRoomId, userName))
          );
        },
        child: Container(
//        color: Colors.white,
          height: 90,
          alignment: Alignment.center,
          child: ListTile(
            leading: InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (context) => TargetUserInfo(userName)));
              },
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.indigoAccent,
                child: Container(
                  child: targetUrl != null ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: targetUrl,
                      fit: BoxFit.cover,
                    ),
                  ) : Text("${userName.substring(0, 1).toUpperCase()}",),
                ),
                foregroundColor: Colors.white,
              ),
            ),
            title: Text('$userName',
              style: TextStyle(
                fontSize: 20,
              ),),
          ),
        ),
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Archive',
          color: Colors.black45,
          icon: Icons.archive,
          onTap: () {},
        ),
        IconSlideAction(
          caption: 'Info',
          color: Color(0xff509ece),
          icon: Icons.info,
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(
                    builder: (context) => TargetUserInfo(userName)));
          },
        ),
      ],
    );
  }
}
