import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schatty/helper/constants.dart';
import 'package:schatty/services/database.dart';
import 'package:schatty/views/MainChatScreenInstance.dart';
import 'package:schatty/widgets/widget.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  DatabaseMethods databaseMethods = new DatabaseMethods();

  TextEditingController searchTEC = new TextEditingController();

  QuerySnapshot searchSnapshot;

  initiateSearch() {
    databaseMethods.getUserByUserName(searchTEC.text).then((val) {
      setState(() {
        searchSnapshot = val;
      });
    });
  }

  createChatInstance({String userName}) {
    if (userName != Constants.ownerName) {
      String chatRoomID = getChatRoomID(userName, Constants.ownerName);

      List<String> users = [userName, Constants.ownerName];

      Map<String, dynamic> chatRoomMap = {
        "users": users,
        "chatRoomId": chatRoomID
      };

      DatabaseMethods().createChatRoom(chatRoomID, chatRoomMap);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatScreen(chatRoomID, userName)));
    }
  }

  Widget searchTile({String userName, String userEmail}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: mediumTextStyle(),
              ),
              /*Text(
                userEmail,
                style: mediumTextStyle(),
              )*/
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              createChatInstance(
                userName: userName,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Message",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget searchList() {
    return searchSnapshot != null
        ? ListView.builder(
            itemCount: searchSnapshot.documents.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return searchTile(
                userName: searchSnapshot.documents[index].data["username"],
                userEmail: searchSnapshot.documents[index].data["email"],
              );
            })
        : Container();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: Container(
        child: Column(
          children: [
            Container(
              color: Colors.teal,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: searchTEC,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                        hintText: "Search for users...",
                        hintStyle: TextStyle(
                          color: Colors.black26,
                        ),
                        border: InputBorder.none),
                  )),
                  GestureDetector(
                    onTap: () {
                      initiateSearch();
                    },
                    child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [Colors.black, Colors.black]),
                            borderRadius: BorderRadius.circular(40)),
                        padding: EdgeInsets.all(12),
                        child: Image.asset("assets/images/search_white.png")),
                  )
                ],
              ),
            ),
            searchList(),
          ],
        ),
      ),
    );
  }
}

getChatRoomID(String a, String b) {
  if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
    return "$b\_$a";
  } else {
    return "$a\_$b";
  }
}
