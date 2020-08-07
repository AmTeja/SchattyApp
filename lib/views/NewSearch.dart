import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:schatty/helper/constants.dart';
import 'package:schatty/services/DatabaseManagement.dart';
import 'package:schatty/services/SearchService.dart';
import 'package:schatty/views/Chatroom/Profile.dart';
import 'package:schatty/widgets/widget.dart';

import 'Chatroom/MainChatScreenInstance.dart';

// ignore: must_be_immutable
class NewSearch extends StatefulWidget {
  bool isPost;
  bool isVideo;
  String ownerUsername;
  String postUrl;
  String caption;
  String postUid;
  String topic;
  String profileUrl;

  NewSearch({
    @required this.isPost,
    this.isVideo,
    this.profileUrl,
    this.topic,
    this.postUid,
    this.ownerUsername,
    this.postUrl,
    this.caption,
  });

  @override
  _NewSearchState createState() => _NewSearchState();
}

class _NewSearchState extends State<NewSearch> {
  bool isLoading = false;

  String type;
  String searchString;

  QuerySnapshot userSnap;
  Stream<QuerySnapshot> titleSnap;

  SearchService searchService = new SearchService();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    type = "User";
    print(type);
    searchString = null;
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading
        ? Scaffold(
            appBar: AppBar(
              title: Text(
                "Schatty",
              ),
              centerTitle: true,
            ),
            body: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 20, bottom: 20, left: 30, right: 30),
                    child: TextField(
                      onChanged: (val) {
                        searchString = val;
                        updateRef();
                      },
                      decoration: new InputDecoration(
                        contentPadding: EdgeInsets.all(16.0),
                        prefixIcon: !widget.isPost
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: DropdownButton<String>(
                                  value: type,
                                  items: [
                                    DropdownMenuItem(
                                      value: "User",
                                      child: Text("User"),
                                    ),
                                    DropdownMenuItem(
                                      value: "Sci-Fi",
                                      child: Text("SciFi"),
                                    ),
                                    DropdownMenuItem(
                                      value: "Art",
                                      child: Text("Art"),
                                    ),
                                    DropdownMenuItem(
                                      value: "Memes",
                                      child: Text("Memes"),
                                    ),
                                    DropdownMenuItem(
                                      value: "Tech",
                                      child: Text("Tech"),
                                    ),
                                  ],
                                  onChanged: (String newVal) {
                                    if (newVal == "SciFi") {
                                      type = "Sci-Fi";
                                      updateRef();
                                    } else {
                                      type = newVal;
                                      updateRef();
                                    }
                                  },
                                ),
                              )
                            : SizedBox.shrink(),
                        hintText: type == null
                            ? "Search for users/title"
                            : type == "User" || type == null
                                ? "Search for a user"
                                : "Search for a title in $type ",
                        hintStyle: TextStyle(),
                        border: new OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: searchString != null && searchString != ""
                        ? type != "User"
                            ? StreamBuilder<QuerySnapshot>(
                                stream: titleSnap,
                                builder: (context, snapshot) {
                                  if (snapshot.hasError)
                                    return Text('Error: ${snapshot.hasError}');
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.waiting:
                                      return Center(
                                          child: CircularProgressIndicator());
                                    default:
                                      return snapshot.hasData
                                          ? ListView.builder(
                                              itemCount: snapshot
                                                  .data.documents.length,
                                              itemBuilder: (context, index) {
                                                return ListTile(
                                                  title: type != "User"
                                                      ? returnTitlePreview(
                                                          snapshot.data
                                                              .documents[index])
                                                      : Text(snapshot
                                                          .data
                                                          .documents[index]
                                                          .data['username']),
                                                );
                                              },
                                            )
                                          : Container(
                                              child: Text("Nothing here"),
                                            );
                                  }
                                },
                              )
                            : searchString != null && searchString != ""
                                ? //Future builder for username
                                FutureBuilder(
                                    future: searchService
                                        .searchByName(searchString),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasError)
                                        return Text(
                                            'Error: ${snapshot.hasError}');
                                      switch (snapshot.connectionState) {
                                        case ConnectionState.waiting:
                                          return Center(
                                              child:
                                                  CircularProgressIndicator());
                                        default:
                                          return ListView.builder(
                                            itemCount:
                                                snapshot.data.documents.length,
                                            itemBuilder: (context, index) {
                                              var targetUsername = snapshot
                                                  .data
                                                  .documents[index]
                                                  .data['username'];
                                              return Container(
                                                padding: EdgeInsets.all(16.0),
                                                child: GestureDetector(
                                                  onTap: () => Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              TargetUserInfo(snapshot
                                                                      .data
                                                                      .documents[
                                                                          index]
                                                                      .data[
                                                                  'username']))),
                                                  child: ListTile(
                                                    leading: Container(
                                                      child: CircleAvatar(
                                                        radius: 40,
                                                        child: ClipOval(
                                                          child:
                                                              CachedNetworkImage(
                                                            width: 60,
                                                            height: 60,
                                                            imageUrl: snapshot
                                                                    .data
                                                                    .documents[
                                                                        index]
                                                                    .data[
                                                                'photoURL'],
                                                            fit: BoxFit.cover,
                                                            placeholder:
                                                                (context,
                                                                        url) =>
                                                                    Center(
                                                              child:
                                                                  CircularProgressIndicator(),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    title: Text(snapshot
                                                        .data
                                                        .documents[index]
                                                        .data['username']),
                                                    trailing: FlatButton(
                                                      child: !widget.isPost
                                                          ? Text("Message")
                                                          : Text("Send"),
                                                      shape:
                                                      RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                              23)),
                                                      color: Color.fromARGB(
                                                          255, 126, 217, 241),
                                                      onPressed: () {
                                                        if (widget.isPost) {
                                                          SharePost(
                                                              widget.postUrl,
                                                              widget
                                                                  .ownerUsername,
                                                              widget.caption,
                                                              targetUsername,
                                                              widget.profileUrl,
                                                              getChatRoomID(
                                                                  Constants
                                                                      .ownerName,
                                                                  targetUsername),
                                                              widget.postUid,
                                                              widget.topic);
                                                        }
                                                        else {
                                                          createChatInstance(
                                                              snapshot.data
                                                                  .documents[index]
                                                                  .data['username']);
                                                        }
                                                      },
                                                    ),
                                                  ),
                            ),
                          );
                        },
                      );
                  }
                },
              )
                  : SizedBox()
                  : SizedBox(),
            )
          ],
        ),
      ),
    )
        : loadingScreen("Loading");
  }

  updateRef() {
    titleSnap = Firestore.instance
        .collection("Posts")
        .document("Public")
        .collection(type)
        .where("titleIndex", arrayContains: searchString)
        .snapshots();
    if (mounted) {
      setState(() {});
    }
  }

  returnTitlePreview(docs) {
    return GestureDetector(
      onTap: () {
        if (type != "User") {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => viewPost(docs, type),
              ));
        }
      },
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 120,
              width: 120,
              child: docs.data["NSFW"]
                  ? Center(
                child: Text(
                  "NSFW",
                  style: TextStyle(fontSize: 30),
                ),
              )
                  : docs.data["isVideo"]
                  ? Center(child: Text("Video"))
                  : CachedNetworkImage(
                imageUrl: docs.data['url'],
                fit: BoxFit.cover,
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(23),
                  border: Border(
                    top: BorderSide(color: Colors.black),
                    bottom: BorderSide(color: Colors.black),
                    right: BorderSide(color: Colors.black),
                    left: BorderSide(color: Colors.black),
                  )),
            ),
            Container(
                padding: EdgeInsets.all(20),
                height: 120,
                width: 200,
                child: Text(
                  "${docs.data['title']} by ${docs.data['username']}",
                  style: TextStyle(fontSize: 22),
                )),
          ],
        ),
      ),
    );
  }

  createChatInstance(String userName) async {
    final String username = userName.toLowerCase();
    setState(() {
      isLoading = true;
    });
    try {
      if (username != Constants.ownerName.toLowerCase()) {
        String chatRoomID = getChatRoomID(
            username.toLowerCase(), Constants.ownerName.toLowerCase());
        String targetUserURL =
        await databaseMethods.getProfileUrlByName(username.toLowerCase());
        String currentUserURL = await databaseMethods
            .getProfileUrlByName(Constants.ownerName.toLowerCase());
        String ownerDName = await databaseMethods.getDName(Constants.ownerName);
        String targetDName = await databaseMethods.getDName(username);
        List<String> users = [
          Constants.ownerName.toLowerCase(),
          username.toLowerCase()
        ];
        Map<String, dynamic> photos = {
          "${Constants.ownerName}": currentUserURL,
          "$username": targetUserURL
        };
        Map<String, dynamic> dNames = {
          "${Constants.ownerName}": ownerDName,
          "$username": targetDName
        };
        Map<String, dynamic> seenByMap = {
          "$username": false,
          "${Constants.ownerName}": false
        };
        Map<String, dynamic> chatRoomMap = {
          "users": users,
          "chatRoomId": chatRoomID,
          "photoUrls": photos,
          "displayNames": dNames,
          "lastTime": DateTime
              .now()
              .millisecondsSinceEpoch,
          "seenBy": seenByMap,
        };
        DatabaseMethods().createChatRoom(chatRoomID, chatRoomMap, userName);
        setState(() {
          isLoading = false;
        });
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(chatRoomID, username)));
      } else {
        Fluttertoast.showToast(
            msg: "Cannot message yourself", gravity: ToastGravity.CENTER);
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error Creating ChatInstance: $error');
    }
  }

  getChatRoomID(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  // ignore: non_constant_identifier_names
  SharePost(String postUrl, String postOwner, String profileUrl, String caption,
      String sentTo, String chatRoomID, String postUid, String topic) async {
    try {
      String targetUID = await databaseMethods.getUIDByUsername(sentTo);
      setState(() {});
      Map<String, dynamic> imageMap = {
        "message": caption,
        "sendBy": Constants.ownerName,
        "time": DateTime.now(),
        "sendTo": targetUID,
        "sentFrom": Constants.ownerUid,
        "url": postUrl,
        "isPost": true,
        "isVideo": widget.isVideo,
        "ownerUsername": postOwner,
        "postUid": postUid,
        "topic": topic,
        "profileUrl": profileUrl,
      };
      databaseMethods.updateLastMessage("Shared a post", chatRoomID, sentTo);
      databaseMethods.addMessage(chatRoomID, imageMap);
      Fluttertoast.showToast(msg: "Sent to $sentTo");
      Navigator.pop(context);
    } catch (e) {
      print("IMAGE FROM URL ERROR: $e");
    }
  }
}


