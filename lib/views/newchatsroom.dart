import 'package:flutter/material.dart';
import 'package:schatty/helper/authenticate.dart';
import 'package:schatty/helper/constants.dart';
import 'package:schatty/helper/helperfunctions.dart';
import 'package:schatty/services/auth.dart';
import 'package:schatty/services/database.dart';
import 'package:schatty/widgets/widget.dart';

import 'chatinstance.dart';

class NewChatRoom extends StatefulWidget {
  @override
  _NewChatRoomState createState() => _NewChatRoomState();
}

class _NewChatRoomState extends State<NewChatRoom> {
  AuthMethods authMethods = new AuthMethods();

  DatabaseMethods databaseMethods = new DatabaseMethods();

  Stream chatRoomsStream;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.blue,
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            actions: [
              GestureDetector(
                onTap: () {
                  authMethods.signOut();
                  HelperFunctions.saveUserLoggedInSharedPreference(false);
                  print(HelperFunctions.getUserLoggedInSharedPreference()
                      .toString());
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Authenticate()));
                },
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(Icons.exit_to_app)),
              )
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text("Schatty"),
              background: Image.network(
                "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fstmed.net%2Fsites%2Fdefault%2Ffiles%2Fhello!-wallpapers-25235-9755499.jpg&f=1&nofb=1",
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverFillRemaining(
            child: Container(
              child: Scaffold(
                backgroundColor: Color(0xfff0f2f2),
                body: chatRoomList(),
                floatingActionButton: FloatingActionButton(
                  child: Icon(Icons.search),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => NewChatRoom()));
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget chatRoomList() {
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return ChatRoomTile(
                      snapshot.data.documents[index].data["chatRoomId"]
                          .toString()
                          .replaceAll("_", "")
                          .replaceAll(Constants.ownerName, ""),
                      snapshot.data.documents[index].data["chatRoomId"]);
                })
            : Container();
      },
    );
  }

  @override
  void initState() {
    getUserInfo();
    print("blah");
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
}

class ChatRoomTile extends StatelessWidget {
  final String userName;
  final String chatRoomId;

  ChatRoomTile(this.userName, this.chatRoomId);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatInstance(chatRoomId, userName)));
      },
      child: Container(
        color: Colors.black12,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        margin: EdgeInsets.symmetric(vertical: 1),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(40)),
              child: Text(
                "${userName.substring(0, 1).toUpperCase()}",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              width: 7,
            ),
            Text(
              userName,
              style: mediumTextStyle(),
            )
          ],
        ),
      ),
    );
  }
}
