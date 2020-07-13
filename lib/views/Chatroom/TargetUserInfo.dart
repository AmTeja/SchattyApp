import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:schatty/services/DatabaseManagement.dart';
import 'package:schatty/views/NewSearch.dart';
import 'package:schatty/widgets/widget.dart';

class TargetUserInfo extends StatefulWidget {
  final String userName;

  TargetUserInfo(this.userName);

  @override
  _TargetUserInfoState createState() => _TargetUserInfoState();
}

class _TargetUserInfoState extends State<TargetUserInfo>
    with TickerProviderStateMixin {
  String uid;
  String profileURL;
  String displayName;
  String userName;
  String tagForStream = "Sci-Fi";

  bool dev = true;

  DatabaseMethods databaseMethods = new DatabaseMethods();
  NewSearch newSearch = new NewSearch();

  Stream postStream;
  Stream tagStream;

  TabController tabController;

  getData() async {
    userName = widget.userName;
    await Firestore.instance
        .collection('users')
        .where('username', isEqualTo: userName.replaceAll(" ", "_"))
        .getDocuments()
        .then((value) async {
      uid = await value.documents[0].data["uid"];
      profileURL = await value.documents[0].data["photoURL"];
    }).catchError((e) {
      print(e);
    });
    displayName = await databaseMethods.getDName(userName);
    setState(() {});
  }

  setTagsStream() {
    tagStream = Firestore.instance
        .collection('Posts')
        .document('Public')
        .collection('Tags')
        .snapshots();
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setPostStream(tagForStream);
    tabController = new TabController(length: 5, vsync: this);
    getData();
    setTagsStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userName),
        centerTitle: true,
      ),
//      backgroundColor: Color.fromARGB(255, 14, 14, 14),
      body: newBody(),
    );
  }

  Widget newBody() {
    return SingleChildScrollView(
      physics: ScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              children: [
                UserAvatar(profileURL, 70),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    displayName ?? userName,
                    style: TextStyle(fontSize: 30),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            height: 40,
            width: MediaQuery
                .of(context)
                .size
                .width,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                StreamBuilder(
                  stream: tagStream,
                  builder: (context, snap) {
                    return snap.hasData ?
                    ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: snap.data.documents.length,
                        itemBuilder: (context, index) {
                          return showTag(snap.data.documents[index]
                              .data['tag']);
                        }
                    )
                        : Container(child: Center(child: Text("OOF"),),);
                  },
                )
              ],
            ),
          ),
          Flexible(
            child: returnPosts(),
          )
        ],
      ),
    );
  }

  selectTag(String tag) {
    setState(() {
      tagForStream = tag;
      setPostStream(tagForStream);
    });
  }

  Widget showTag(String tag) {
    return GestureDetector(
      onTap: () {
        selectTag(tag);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Container(
          height: 30,
          width: 80,
          decoration: BoxDecoration(
              color: tagForStream == tag ? Color(0xFF7ED9F1) : null,
              borderRadius: BorderRadius.circular(23)),
          child: Center(
            child: Text(
              tag,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  setPostStream(tag) {
    postStream =
        Firestore.instance.collection('Posts').document('Public').collection(
            tag).where('username', isEqualTo: userName).orderBy(
            'time', descending: true).getDocuments().asStream();
    if (mounted) {
      setState(() {

      });
    }
  }

  returnPosts() {
    return StreamBuilder(
      stream: postStream,
      builder: (BuildContext context, snapshot) {
        return snapshot.hasData ? GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: snapshot.data.documents.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2),
          itemBuilder: (context, index) {
            return snapshot.data.documents[index].data["username"] == userName
                ? snapshot.data.documents[index].data["NSFW"] == true
                ? GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          viewPost(snapshot.data.documents[index],
                              tagForStream),
                    ));
              },
              child: Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("NSFW",
                          style: TextStyle(fontSize: 40, color: Colors.black),),
                      ),
                    ],
                  ),
                ),),
            )
                : GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) =>
                      viewPost(snapshot.data.documents[index], tagForStream),
                ));
              },
              child: Card(
                child: Column(
                  children: [
                    Expanded(
                        child: CachedNetworkImage
                          (imageUrl: snapshot.data.documents[index].data['url'],
                          fit: BoxFit.cover,)
                    )
                  ],
                ),
              ),
            )
                : SizedBox.shrink();
          },
        ) : Center(child: Container(child: Text("failed to load"),));
      },
    );
  }
}
