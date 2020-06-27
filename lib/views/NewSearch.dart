import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:schatty/helper/constants.dart';
import 'package:schatty/helper/preferencefunctions.dart';
import 'package:schatty/helper/targetURL.dart';
import 'package:schatty/services/DatabaseManagement.dart';
import 'package:schatty/services/SearchService.dart';

import 'MainChatScreenInstance.dart';

class NewSearch extends StatefulWidget {
  @override
  _NewSearchState createState() => _NewSearchState();
}

class _NewSearchState extends State<NewSearch> {
  var queryResultSet = [];
  var tempSearchStore = [];
  bool foundNone = false;

  initiateSearch(String value) {
    if (value.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
        foundNone = false;
      });
    }

    var capitalisedValue =
        value.substring(0, 1).toUpperCase() + value.substring(1);
    if (queryResultSet.length == 0 && value.length == 1) {
      SearchService().searchByName(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.documents.length; i++) {
          queryResultSet.add(docs.documents[i].data);
          setState(() {
            foundNone = false;
          });
        }
      });
    } else {
      tempSearchStore = [];
      queryResultSet.forEach((element) {
        if (element['username'].startsWith(value) ||
            element['username'].startsWith(capitalisedValue)) {
          setState(() {
            tempSearchStore.add(element);
            foundNone = false;
          });
        }
      });
    }
    if (tempSearchStore.length == 0 && value.length > 1) {
      setState(() {
        foundNone = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Schatty",
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                  top: 20, bottom: 20, left: 30, right: 30),
              child: TextField(
                onChanged: (val) {
                  initiateSearch(val);
                },
                decoration: new InputDecoration(
                  hintText: "Search for users",
                  hintStyle: TextStyle(
                  ),
                  border: new OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30)
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            !foundNone
                ? ListView(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    primary: false,
                    shrinkWrap: true,
                    children: tempSearchStore.map((element) {
                      return buildResultCard(element);
                    }).toList(),
                  )
                : showEmptyList()
          ],
        ),
      ),
    );
  }

  Widget showEmptyList() {
    return Container(
      child: Center(
          child: Container(
        width: 350,
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "No user found...",
                style: TextStyle(fontSize: 26),
              ),
            )
          ],
        ),
      )),
    );
  }

  createChatInstance(String userName) async {
    final GetPhotoURL targetURL = new GetPhotoURL();
    if (userName != Constants.ownerName) {
      String chatRoomID = getChatRoomID(userName, Constants.ownerName);
      String targetUserURL = await targetURL.fetchTargetURL(userName);
      String currentUserURL = await Preferences.getUserImageURL();
      List<String> users = [Constants.ownerName, userName];
      List<String> photos = [currentUserURL, targetUserURL];
      Map<String, dynamic> chatRoomMap = {
        "users": users,
        "chatRoomId": chatRoomID,
        "photoURLS": photos,
        "lastTime": DateTime.now().millisecondsSinceEpoch,
      };

      DatabaseMethods().createChatRoom(chatRoomID, chatRoomMap);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatScreen(chatRoomID, userName)));
    }
  }

  getChatRoomID(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  Widget buildResultCard(data) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 100,
      child: GestureDetector(
        onTap: () {
          createChatInstance(data['username']);
        },
        child: Card(
          color: Colors.black,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
          elevation: 3,
          shadowColor: Color.fromARGB(217, 0, 0, 0),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 14, 14, 14),
                      Color.fromARGB(100, 46, 45, 45)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight
                )
            ),
            child: Center(
              child: Text(
                data['username'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
