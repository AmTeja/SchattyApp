import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:schatty/helper/authenticate.dart';
import 'package:schatty/helper/constants.dart';
import 'package:schatty/helper/helperfunctions.dart';
import 'package:schatty/services/auth.dart';
import 'package:schatty/services/database.dart';
import 'package:schatty/views/MainChatScreenInstance.dart';
import 'package:schatty/views/SearchLayout.dart';
import 'package:schatty/widgets/widget.dart';


class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {

  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();

//  final StorageReference storageRef = FirebaseStorage.instance.ref().child(fileName);

  final String fileName =
      Constants.ownerName + Random().nextInt(10000).toString() + '.$extension';
  Stream chatRoomsStream;
  bool newMessageReceived = false;
  File _image;
  var imageUrl;
  String url;

  logOut(BuildContext context) {
    authMethods.signOut();
    HelperFunctions.saveUserLoggedInSharedPreference(false);
    print(HelperFunctions.getUserLoggedInSharedPreference().toString());
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Authenticate()));
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image.path != null) {
      setState(() {
        _image = image;
        print('Image path: $_image');
      });
      uploadImage();
    } else {
      return null;
    }
  }

  Future uploadImage() async {
    String fileName = Constants.ownerName + basename(_image.path);
    StorageReference storageReference = FirebaseStorage.instance.ref().child(
        fileName);
    StorageUploadTask storageUploadTask = storageReference.putFile(_image);
    imageUrl = await (await storageUploadTask.onComplete).ref.getDownloadURL();
    url = imageUrl.toString();
    await databaseMethods.addImagePathToDatabase(url).whenComplete(() {
      setState(() {
        Fluttertoast.showToast(msg: "Image updated");
      });
    });
  }


  Widget mainDrawer(BuildContext context) {
    return Drawer(
      elevation: 4,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 50,
//                  backgroundColor: Colors.blue,
                  child: ClipOval(
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: (_image != null) ? Image.file(
                        _image, fit: BoxFit.fill,)
                          : url != null ? (Image.network(url,
                        fit: BoxFit.fitHeight,)) : Image.asset(
                        "assets/images/username.png",
                        fit: BoxFit.fill,),
                    ),
                  ),
                ),
                SizedBox(
                  width: 50,
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text(Constants.ownerName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.black,
                    ),),
                )
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            onTap: () {
              getImage();
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
        ],
      ),

    );
  }


  Widget chatRoomList() {
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (context, snapshot) {
        return snapshot.hasData ? ListView.builder(
            reverse: false,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) {
              return ChatRoomTile(
                  snapshot.data.documents[index].data["chatRoomId"]
                      .toString()
                      .replaceAll("_", "")
                      .replaceAll(Constants.ownerName, ""),
                  snapshot.data.documents[index].data["chatRoomId"]
              );
            }) : Container();
      },
    );
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  getUserInfo() async {
    print("getting user infO");
    Constants.ownerName = await HelperFunctions.getUserNameSharedPreference();
    databaseMethods.getChatRooms(Constants.ownerName).then((val) {
      setState(() {
        chatRoomsStream = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: mainDrawer(context),
      appBar: AppBar(
        title: Text("Schatty"),
        elevation: 3,
      ),
      body: Container(
        child: Scaffold(
          backgroundColor: Color(0xfff0f2f2),
          body: chatRoomList(),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.search),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(
                      builder: (context) => SearchScreen()));
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
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        margin: EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Container( //Letter in the circle Container
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.blue,
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
