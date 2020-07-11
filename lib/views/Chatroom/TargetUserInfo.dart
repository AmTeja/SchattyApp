import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  String tagForStream;

  List<String> tagList = ["Sci-F", "Memes", "Tech", "Art", "Animals"];

  bool dev = true;

  DatabaseMethods databaseMethods = new DatabaseMethods();
  NewSearch newSearch = new NewSearch();

  Stream postStream;

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setPostStream("Sci-Fi");
    tabController = new TabController(length: 5, vsync: this);
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userName),
        centerTitle: true,
      ),
//      backgroundColor: Color.fromARGB(255, 14, 14, 14),
      body: !dev
          ? Center(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 70),
                    alignment: Alignment.topCenter,
                    child: CircleAvatar(
                      radius: 120,
                      child: ClipOval(
                        child: profileURL != null
                            ? CachedNetworkImage(
                                imageUrl: profileURL,
                    imageBuilder: (context, imageProvider) =>
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    placeholder: (context, url) =>
                        CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        Icon(Icons.error),
                  )
                      : Image(
                    image: AssetImage("assets/images/username.png"),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 100),
              child: Column(
                children: [
                  Text(
                    "Username",
                    style: TextStyle(fontSize: 26),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      userName,
                      style: TextStyle(fontSize: 26),
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 100),
              child: Column(
                children: [
                  Text(
                    "Display Name",
                    style: TextStyle(fontSize: 26),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      displayName ?? userName,
                      style: TextStyle(fontSize: 26),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ) : newBody(),
    );
  }

  Widget newBody() {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            children: [
              UserAvatar(profileURL, 70),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(userName,
                  style: TextStyle(
                      fontSize: 30
                  ),),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              showTag("Sci-Fi"),
              showTag("Memes"),
              showTag("Tech"),
              showTag("Art"),
              showTag("Animals"),
              showTag("History"),
              showTag("Educational"),
            ],
          ),
        ),
        Expanded(
          child: returnPosts(),
        )
      ],
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
            tag).snapshots();
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
          itemCount: snapshot.data.documents.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3),
          itemBuilder: (context, index) {
            return snapshot.data.documents[index].data["username"] == userName
                ? Card(
              child: Column(
                children: [
                  Expanded(
                      child: CachedNetworkImage
                        (imageUrl: snapshot.data.documents[index].data['url'],
                        fit: BoxFit.cover,)
                  )
                ],
              ),
            )
                : SizedBox();
          },
        ) : Center(child: Container(child: Text("failed to load"),));
      },
    );
  }
}
