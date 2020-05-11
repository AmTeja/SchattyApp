import 'package:flutter/material.dart';
import 'package:schatty/helper/authenticate.dart';
import 'package:schatty/helper/constants.dart';
import 'package:schatty/helper/helperfunctions.dart';
import 'package:schatty/services/auth.dart';
import 'package:schatty/services/database.dart';
import 'package:schatty/views/chatinstance.dart';
import 'package:schatty/views/search.dart';
import 'package:schatty/widgets/widget.dart';


class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {

  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  Stream chatRoomsStream;

  Widget chatRoomList() {
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (context, snapshot) {
        return snapshot.hasData ? ListView.builder(
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
      appBar: AppBar(
        title: Image.asset("assets/images/logo.png", height: 50,),
        actions: [
          GestureDetector(
            onTap: () {
              authMethods.signOut();
              HelperFunctions.saveUserLoggedInSharedPreference(false);
              Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) => Authenticate()
              ));
            },
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.exit_to_app)),
          )
        ],
      ),
      body: chatRoomList(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => SearchScreen()
          ));
        },
      ),
    );
  }
}

class ChatRoomTile extends StatelessWidget {

  final String userName;
  final String chatRoomID;

  ChatRoomTile(this.userName, this.chatRoomID);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => ChatInstance(chatRoomID)
        ));
      },
      child: Container(
        color: Colors.black12,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(40)
              ),
              child: Text("${userName.substring(0, 1).toUpperCase()}",
                style: mediumTextStyle(),),
            ),
            SizedBox(width: 7,),
            Text(userName, style: mediumTextStyle(),)
          ],
        ),
      ),
    );
  }
}
