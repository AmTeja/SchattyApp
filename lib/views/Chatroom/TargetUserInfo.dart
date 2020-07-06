import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schatty/services/DatabaseManagement.dart';

class TargetUserInfo extends StatefulWidget {
  final String userName;

  TargetUserInfo(this.userName);

  @override
  _TargetUserInfoState createState() => _TargetUserInfoState();
}

class _TargetUserInfoState extends State<TargetUserInfo> {
  String uid;
  String profileURL;
  String displayName;
  String userName;

  bool dev = false;

  DatabaseMethods databaseMethods = new DatabaseMethods();

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
      body: Center(
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
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

//  Widget newBody() {
//    return Container(
//      height: MediaQuery.of(context).size.height,
//      padding: EdgeInsets.all(16),
//      child: Column(
//        mainAxisSize: MainAxisSize.min,
//        crossAxisAlignment: CrossAxisAlignment.center,
//        children: [
//          Container(
//            alignment: Alignment.center,
//            padding: EdgeInsets.symmetric(vertical: 16,horizontal: 8),
//            child: Row(
//              children: [
//                UserAvatar(profileURL, 70),
//                Padding(
//                  padding: const EdgeInsets.symmetric(horizontal: 32),
//                  child: Text(userName,
//                    style: TextStyle(
//                        fontSize: 30
//                    ),),
//                ),
//              ],
//            ),
//          ),
////          Flex(
////            direction: Axis.vertical,
////            children: [
////              Container(
////                padding: EdgeInsets.all(16),
////                height: 400,
////                child: GridView.count(
////                  crossAxisCount: 3,
////                  crossAxisSpacing: 4.0,
////                  mainAxisSpacing: 8.0,
////                  children: [
////                    Container(color: Colors.red,),
////                    Container(color: Colors.red,),
////                    Container(color: Colors.red,),
////                    Container(color: Colors.red,),
////                  ],
////                ),
////              ),
////            ]
////          )
//        ],
//      ),
//    );
//  }

}
