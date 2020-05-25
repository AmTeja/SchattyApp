import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserInfo extends StatefulWidget {
  final String userName;

  UserInfo(this.userName);

  @override
  _UserInfoState createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  String uid;
  String profileURL;

  getData() async {
    print(widget.userName);
    await Firestore.instance
        .collection('users')
        .where('username', isEqualTo: widget.userName)
        .getDocuments()
        .then((value) async {
      uid = await value.documents[0].data["uid"];
      profileURL = await value.documents[0].data["photoURL"];
      setState(() {});
    }).catchError((e) {
      print(e);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 70),
              alignment: Alignment.topCenter,
              child: CircleAvatar(
                radius: 120,
                child: ClipOval(
                  child: SizedBox(
                    width: 250,
                    height: 250,
                    child: Image(
                      image: profileURL != null
                          ? NetworkImage(profileURL)
                          : AssetImage(
                              "assets/images/username.png",
                            ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Username: ",
                    style: TextStyle(fontSize: 24),
                  ),
                  Text(
                    widget.userName,
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
