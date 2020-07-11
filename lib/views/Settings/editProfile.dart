import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:schatty/helper/constants.dart';
import 'package:schatty/helper/preferencefunctions.dart';
import 'package:schatty/services/AuthenticationManagement.dart';
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

  bool isLoading = false;

  ImagePicker picker = ImagePicker();

  DatabaseMethods databaseMethods = new DatabaseMethods();

  final formKey = GlobalKey<FormState>();

  String displayName;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading = true;
    assignURL();
    getDisplayName();
    setState(() {
      isLoading = false;
    });
  }

  getDisplayName() async {
    displayName = await databaseMethods.getDName(widget.username);
    setState(() {});
  }

  assignURL() async {
    profilePicURL = await databaseMethods
        .getProfileUrlByName(Constants.ownerName.toLowerCase());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      backgroundColor: Color.fromARGB(100, 39, 38, 38),
      appBar: AppBar(
        title: Text(
          "Schatty",
        ),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 70),
              alignment: Alignment.topCenter,
              child: CircleAvatar(
                radius: 125,
                backgroundImage: AssetImage("assets/images/username.png"),
                child: ClipOval(
                  child: profilePicURL != null
                      ? CachedNetworkImage(
                          imageUrl: profilePicURL,
                          imageBuilder: (context, imageProvider) => Container(
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
              height: 30,
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  displayName == null
                      ? Text(
                          "Display Name: ${widget.username}",
                          style: TextStyle(
                            fontSize: 26,
                          ),
                        )
                      : Text(
                          "Display Name: $displayName",
                          style: TextStyle(
                            fontSize: 26,
                          ),
                        ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      showAlert(context);
                    },
                  )
                ],
              ),
              padding: EdgeInsets.symmetric(vertical: 10),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 120, vertical: 10),
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
                      Icons.camera_alt,
                      size: 40,
                      color: Colors.black,
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 120, vertical: 10),
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

  showAlert(BuildContext context) {
    TextEditingController nameTEC = new TextEditingController();

    return showDialog(context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Edit Display Name"),
            content: Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 65,
              child: Form(
                key: formKey,
                child: TextFormField(
                  validator: NameValidator.validate,
                  controller: nameTEC,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(
                        left: 15, top: 20, bottom: 20, right: 15),
                    hintText: 'Name',
                    filled: true,
                    hintStyle: TextStyle(color: Colors.grey[400]),
                  ),
                ),
              ),
            ),
            actions: [
              FlatButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text("Save"),
                onPressed: () {
                  if (formKey.currentState.validate()) {
                    setDisplayName(nameTEC.text);
                    Navigator.pop(context);
                  }
                },
              )
            ],
          );
        });
  }

  setDisplayName(String newName) {
    displayName = newName;
    setState(() {

    });
    databaseMethods.updateDisplayName(
        displayName, widget.username.toLowerCase());
  }

  Future getImage() async {
    var tempPic = await picker.getImage(source: ImageSource.gallery);
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
            toolbarColor: Color(0xff99d8d0),
            toolbarTitle: "Schatty",
            toolbarWidgetColor: Colors.white,
            backgroundColor: Colors.black,
            activeControlsWidgetColor: Color(0xff99d8d0),
          ));
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
    final String fileName = 'profilepic/' + widget.uid +
        '/${randomNum.nextInt(5000).toString()}.jpg'; //filename to be stored
    final StorageReference storageReference = FirebaseStorage.instance.ref()
        .child(fileName); //ref to storage
    StorageUploadTask task = storageReference.putFile(
        newProfilePic); //task to upload file
    StorageTaskSnapshot snapshotTask = await task.onComplete;
    var downloadUrl = await snapshotTask.ref
        .getDownloadURL(); //download url of the image uploaded
    String url = downloadUrl.toString();
    await Preferences.saveUserImageURL(url);
    databaseMethods.updateProfilePicture(
        downloadUrl.toString(), Constants.ownerName);
    setState(() {
      profilePicURL = url;
    });
  }
}
