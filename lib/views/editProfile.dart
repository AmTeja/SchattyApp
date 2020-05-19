import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:schatty/services/database.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  File newProfilePic;
  String profilePicURL;

  DatabaseMethods databaseMethods = new DatabaseMethods();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseAuth.instance.currentUser().then((user) {
      setState(() {
        profilePicURL = user.photoUrl;
      });
    }).catchError((onError) {
      print(onError);
    });
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
                      image: profilePicURL != null
                          ? NetworkImage(profilePicURL)
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 120),
              child: MaterialButton(
                padding: EdgeInsets.symmetric(vertical: 10),
                onPressed: () {
                  getImage();
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
                color: Colors.blue,
                elevation: 3,
                splashColor: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Edit Picture",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Icon(
                      Icons.camera_enhance,
                      size: 40,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future getImage() async {
    var tempPic = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      newProfilePic = tempPic;
      uploadImage();
    });
  }

  uploadImage() async {
    var randomNum = Random(25);
    final String fileName =
        'profilepic/${randomNum.nextInt(5000).toString()}.jpg';
    final StorageReference storageReference =
        FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask task = storageReference.putFile(newProfilePic);
    StorageTaskSnapshot snapshotTask = await task.onComplete;
    var downloadUrl = snapshotTask.ref.getDownloadURL();
    String url = downloadUrl.toString();
    databaseMethods.updateProfilePicture(url);
  }
}
