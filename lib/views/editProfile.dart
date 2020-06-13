import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:schatty/helper/preferencefunctions.dart';
import 'package:schatty/services/DatabaseManagement.dart';
import 'package:schatty/views/Authenticate/ChangePassword.dart';

class EditProfile extends StatefulWidget {
  final String username;
  final String uid;

  EditProfile(this.username, this.uid);

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
    assignURL();
  }

  assignURL() async
  {
    profilePicURL = await databaseMethods.getProfileUrl();
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(100, 39, 38, 38),
      appBar: AppBar(
        title: Text(
          "Schatty",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
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
                color: Colors.white,
                elevation: 3,
                splashColor: Colors.black,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Edit Picture",
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Icon(
                      Icons.camera_enhance,
                      size: 40,
                      color: Colors.black,
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 120, vertical: 20),
              child: MaterialButton(
                padding: EdgeInsets.symmetric(vertical: 10),
                onPressed: () {
                  changePassword();
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
                color: Colors.white,
                elevation: 3,
                splashColor: Colors.black,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 40,
                      child: Center(
                        child: Text(
                          "Change Password",
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  changePassword() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ChangePassword()));
  }

  Future getImage() async {
    var tempPic = await ImagePicker.pickImage(source: ImageSource.gallery);
    File cropped;
    if (tempPic != null) {
      cropped = await ImageCropper.cropImage(
          sourcePath: tempPic.path,
//            aspectRatio: CropAspectRatio(
//                ratioX: 1, ratioY: 1),
          compressQuality: 100,
          maxWidth: 700,
          maxHeight: 700,
          cropStyle: CropStyle.circle,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
            toolbarColor: Colors.blue,
            toolbarTitle: "Schatty",
            statusBarColor: Colors.black,
            backgroundColor: Colors.white,
          )
      );
    }
    setState(() {
      if (cropped != null) {
        newProfilePic = cropped;
        uploadImage();
      }
    });
  }

  uploadImage() async {
    var randomNum = Random(25);
    final String fileName = 'profilepic/' +
        widget.uid +
        '/${randomNum.nextInt(5000).toString()}.jpg'; //filename to be stored
    final StorageReference storageReference =
        FirebaseStorage.instance.ref().child(fileName); //ref to storage
    StorageUploadTask task =
        storageReference.putFile(newProfilePic); //task to upload file
    StorageTaskSnapshot snapshotTask = await task.onComplete;
    var downloadUrl = await snapshotTask.ref
        .getDownloadURL(); //download url of the image uploaded
    String url = downloadUrl.toString();
    await HelperFunctions.saveUserImageURL(url);
    databaseMethods.updateProfilePicture(downloadUrl.toString());
    setState(() {
      profilePicURL = url;
    });
  }

}