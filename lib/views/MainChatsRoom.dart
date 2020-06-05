import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:schatty/helper/NavigationService.dart';
import 'package:schatty/helper/constants.dart';
import 'package:schatty/helper/preferencefunctions.dart';
import 'package:schatty/services/AuthenticationManagement.dart';
import 'package:schatty/services/DatabaseManagement.dart';
import 'package:schatty/views/Authenticate/AuthHome.dart';
import 'package:schatty/views/MainChatScreenInstance.dart';
import 'package:schatty/views/NewSearch.dart';
import 'package:schatty/views/TargetUserInfo.dart';
import 'package:schatty/views/editProfile.dart';
import 'package:schatty/widgets/widget.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {

  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  NavigationService navigationService = new NavigationService();
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

//  final StorageReference storageRef = FirebaseStorage.instance.ref().child(fileName);

  final String fileName =
      Constants.ownerName + Random().nextInt(10000).toString() + '.$extension';
  Stream chatRoomsStream;
  bool newMessageReceived = false;
  var imageUrl;
  String url;

  logOut(BuildContext context) async {
    bool isGoogleUser = false;
    isGoogleUser = await HelperFunctions.getIsGoogleUser();
    if (isGoogleUser) {
      authMethods.signOut();
    } else {
      authMethods.signOutGoogle();
    }
    HelperFunctions.saveUserLoggedInSharedPreference(false);
    HelperFunctions.saveUserNameSharedPreference(null);
    HelperFunctions.saveUserEmailSharedPreference(null);
    HelperFunctions.saveUserImageURL(null);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) =>
        AuthHome()));
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
                      child: url != null ? (Image.network(url,
                        fit: BoxFit.cover,)) : Image.asset(
                        "assets/images/username.png",
                        fit: BoxFit.fill,),
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
                        color: Colors.white,
                      ),
                    )
                        : Text("Error"),
                  ),
                )
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.black,
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => EditProfile(Constants.ownerName)
              ));
            },
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                    "Edit profile",
                    style: TextStyle(
                      fontSize: 16,
                    )),
                Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.edit),
                )
              ],
            ),
          ),
          ListTile(
              onTap: () {
                logOut(context);
              },
              title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text('Logout',
                      style: TextStyle(
                        fontSize: 16,
                      ),),
                    Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.exit_to_app)
                    ),
                  ])),
          ListTile(
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (context) => ChatRoom()
                ));
              },
              title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text('Refresh',
                      style: TextStyle(
                        fontSize: 16,
                      ),),
                    Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.refresh)),
                  ]))
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
                  snapshot.data.documents[index].data["chatRoomId"]);
            })
            : suchEmpty(context);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getToken();
    getUserInfo();
    assignURL();
    uploadToken();
  }

  uploadToken() async
  {
    String token;
    token = await firebaseMessaging.getToken();
    print(token);
    databaseMethods.updateToken(token);
  }

  assignURL() async
  {
    url = await databaseMethods.getProfileUrl();
    setState(() {});
  }

  getUserInfo() async {
    Constants.ownerName = await HelperFunctions.getUserNameSharedPreference();
    try {
      databaseMethods.getChatRooms(Constants.ownerName).then((val) {
        setState(() {
          chatRoomsStream = val;
        });
      });
    } catch (e) {
      print("getUserInfo: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: mainDrawer(context),
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black26,
        title: Text("Schatty"),
        elevation: 3,
      ),
      body: Container(
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Color.fromARGB(255, 0, 0, 0),
                    Color.fromARGB(100, 39, 38, 38)
                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  image: DecorationImage(
                      image: ExactAssetImage(
                        "assets/images/chatroombg.png",
                      ),
                      fit: BoxFit.cover)),
              child: chatRoomList()),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Color.fromARGB(255, 141, 133, 133),
            child: Icon(Icons.search,
              color: Colors.black,
              size: 30,),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => NewSearch()));
            },
          ),
        ),
      ),
    );
  }
}

class ChatRoomTile extends StatelessWidget {

  final String userName;
  final String chatRoomId;

  ChatRoomTile(this.userName, this.chatRoomId);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => ChatScreen(chatRoomId, userName)
        ));
      },
      onLongPress: () {
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => UserInfo(userName)
        ));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(23),
          color: Colors.transparent,
//          border: Border(bottom: BorderSide(
//              color: Color.fromARGB(255, 141, 133, 133), width: 0.1)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        margin: EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Container( //Letter in the circle Container
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(40)
              ),
              child: Text("${userName.substring(0, 1).toUpperCase()}",
                style: TextStyle(
                  color: Colors.white,
                ),),
            ),
            SizedBox(width: 7,),
            Text(userName, style: mediumTextStyle(),)
          ],
        ),
      ),
    );
  }
}
