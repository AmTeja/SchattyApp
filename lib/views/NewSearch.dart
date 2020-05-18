import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:schatty/helper/constants.dart';
import 'package:schatty/services/SearchService.dart';
import 'package:schatty/services/database.dart';

import 'MainChatScreenInstance.dart';

class NewSearch extends StatefulWidget {
  @override
  _NewSearchState createState() => _NewSearchState();
}

class _NewSearchState extends State<NewSearch> {
  var queryResultSet = [];
  var tempSearchStore = [];

  initiateSearch(String value) {
    if (value.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    }

    var capitalisedValue =
        value.substring(0, 1).toUpperCase() + value.substring(1);
    if (queryResultSet.length == 0 && value.length == 1) {
      SearchService().searchByName(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.documents.length; i++) {
          queryResultSet.add(docs.documents[i].data);
        }
      });
    } else {
      tempSearchStore = [];
      queryResultSet.forEach((element) {
        if (element['username'].startsWith(value) ||
            element['username'].startsWith(capitalisedValue)) {
          setState(() {
            tempSearchStore.add(element);
          });
        }
      });
    }
    if (tempSearchStore.length == 0 && value.length > 1) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Schatty",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                onChanged: (val) {
                  initiateSearch(val);
                },
                decoration: new InputDecoration(
                  hintText: "Search for users",
                  prefixIcon: IconButton(
                    color: Colors.black,
                    icon: Icon(Icons.arrow_back),
                    iconSize: 20.0,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ListView(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              primary: false,
              shrinkWrap: true,
              children: tempSearchStore.map((element) {
                return buildResultCard(element);
              }).toList(),
            )
          ],
        ),
      ),
    );
  }

  createChatInstance(String userName) {
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
          color: Color(0xffeef1f5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          elevation: 2,
          child: Container(
            child: Center(
              child: Text(
                data['username'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
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
