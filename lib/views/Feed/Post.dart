import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:schatty/provider/DarkThemeProvider.dart';
import 'package:schatty/widgets/widget.dart';

class PostContent extends StatefulWidget {
  final isDark;
  final username;
  final profileUrl;

  const PostContent(
      {Key key,
      @required this.isDark,
      @required this.username,
      @required this.profileUrl})
      : super(key: key);

  @override
  _PostContentState createState() => _PostContentState();
}

var randomNum = Random(40);

bool selectedPublic = true;
bool selectedPrivate = false;
bool isLoading = false;

File selectedImage;

String selectedTag;
String postUrl;
String random;

TextEditingController captionTEC = new TextEditingController();

ImagePicker picker = ImagePicker();

class _PostContentState extends State<PostContent> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedImage = null;
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading
        ? Consumer<DarkThemeProvider>(
            builder: (BuildContext context, value, Widget child) {
              return Scaffold(
                appBar: AppBar(
                  title: Text("Schatty"),
                  centerTitle: true,
                ),
                body: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.transparent,
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.85,
                        decoration: BoxDecoration(
                            color: !widget.isDark
                                ? Color(0xFFE0DEDE)
                                : Colors.blueGrey,
                            boxShadow: [
                              BoxShadow(
                                  color: !widget.isDark
                                      ? Colors.white70
                                      : Colors.black12,
                                  spreadRadius: 3,
                                  blurRadius: 2)
                            ],
                            borderRadius: BorderRadius.circular(23)),
                        child: ListView(
                          children: [
                            Container(
                              //Close And Post
                              child: ListTile(
                                title: SizedBox.shrink(),
                                leading: IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    size: 40,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                trailing: InkWell(
                                  onTap: () {
                                    post(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                    child: Text(
                                      "Post",
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                                padding: EdgeInsets.all(10),
                                height: 400,
                                width: 400,
                                child: selectedImage != null
                                    ? Image.file(
                                        selectedImage,
                                        fit: BoxFit.cover,
                                      )
                                    : Center(
                                        child: Container(
                                          height: 400,
                                          width: 400,
                                          decoration: BoxDecoration(
                                              color: Color(0xFFE0DEDE),
                                              border: Border(
                                                top: BorderSide(
                                                    color: Colors.black),
                                                bottom: BorderSide(
                                                    color: Colors.black),
                                                left: BorderSide(
                                                    color: Colors.black),
                                                right: BorderSide(
                                                    color: Colors.black),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(23)),
                                          child: IconButton(
                                            icon: Icon(Icons.collections),
                                            onPressed: () {
                                              getImage();
                                            },
                                          ),
                                        ),
                                      )),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 16),
                              child: TextField(
                                maxLines: 2,
                                controller: captionTEC,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                style: TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,
                                    hintText: "Caption...",
                                    hintStyle: TextStyle(
                                        color: Colors.black54, fontSize: 18),
                                    focusColor: Colors.black,
                                    contentPadding: EdgeInsets.all(16),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(23),
                                    )),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 30),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Tag Post: ",
                                    style: TextStyle(
                                      fontFamily: "Segoe UI",
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  selectedTag == null
                                      ? IconButton(
                                          onPressed: () {
                                            selectTag(context);
                                          },
                                          icon: Icon(
                                            Icons.add_box,
                                            size: 30,
                                          ),
                                        )
                                      : GestureDetector(
                                          onTap: () {
                                            selectTag(context);
                                          },
                                          child: Text(
                                            selectedTag,
                                            style: TextStyle(
                                              fontFamily: "Segoe UI",
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Post to: ",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontFamily: "Segoe UI",
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _selectedPublic();
                                    },
                                    child: Text(
                                      "Public",
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontFamily: "Segoe UI",
                                          fontWeight: selectedPublic
                                              ? FontWeight.bold
                                              : null,
                                          color: selectedPublic
                                              ? Colors.black
                                              : Colors.black12),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _selectedPrivate();
                                    },
                                    child: Text(
                                      "Private",
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontFamily: "Segoe UI",
                                          fontWeight: selectedPrivate
                                              ? FontWeight.bold
                                              : null,
                                          color: selectedPrivate
                                              ? Colors.black
                                              : Colors.black12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          )
        : loadingScreen("Posting...");
  }

  _selectedPublic() {
    bool newVal = true;
    if (selectedPublic) {
      newVal = false;
    } else {
      newVal = true;
      selectedPrivate = !newVal;
    }
    setState(() {
      selectedPublic = newVal;
    });
  }

  _selectedPrivate() {
    bool newVal = true;
    if (selectedPrivate) {
      newVal = false;
    } else {
      newVal = true;
      selectedPublic = !newVal;
    }
    setState(() {
      selectedPrivate = newVal;
    });
  }

  getImage() async {
    try {
      var tempPic = await picker.getImage(source: ImageSource.gallery);
      if (tempPic != null) {
        setState(() {
          cropImage(tempPic.path);
        });
      }
    } catch (e) {
      print('Error Selecting Image: $e');
    }
  }

  cropImage(String path) async {
    File cropped;
    try {
      if (path != null) {
        cropped = await ImageCropper.cropImage(
            sourcePath: path,
            maxWidth: 700,
            maxHeight: 700,
            compressFormat: ImageCompressFormat.jpg,
            compressQuality: 90,
            androidUiSettings: AndroidUiSettings(
              toolbarTitle: "Crop Image",
              toolbarColor: Color(0xff99d8d0),
              toolbarWidgetColor: Colors.white,
              backgroundColor: Colors.black,
              activeControlsWidgetColor: Color(0xff99d8d0),
            ));
        setState(() {
          if (cropped != null) {
            selectedImage = cropped;
          }
        });
      }
    } catch (e) {
      print("Error Cropping Image: $e");
    }
  }

  selectTag(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Select Tag"),
            content: Container(
              width: MediaQuery.of(context).size.width * 0.55,
              height: MediaQuery.of(context).size.height * 0.40,
              decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.black),
                    bottom: BorderSide(color: Colors.black),
                    left: BorderSide(color: Colors.black),
                    right: BorderSide(color: Colors.black),
                  ),
                  borderRadius: BorderRadius.circular(23)),
              child: ListView(
                children: [
                  tagContainer(
                    "Sci-Fi",
                  ),
                  tagContainer(
                    "Tech",
                  ),
                  tagContainer("Art"),
                  tagContainer("Animals"),
                  tagContainer("History"),
                ],
              ),
            ),
          );
        });
  }

  bool tagIsSelected = false;

  Widget tagContainer(String title) {
    return ListTile(
      key: Key(title),
      leading: Text(title),
      onTap: () {
        tagSelected(title);
        Navigator.pop(context);
      },
    );
  }

  tagSelected(String tag) {
    setState(() {
      selectedTag = tag;
    });
  }

  showError() {
    Fluttertoast.showToast(
        msg: "Invalid Image/Tag", gravity: ToastGravity.CENTER);
  }

  getRandom() {
    random = randomNum.nextInt(5000).toString();
  }

  uploadImageToPublic(String tag) async {
    getRandom();
    final String fileName = 'PublicPosts/' + tag + '/$random.jgp';
    final StorageReference storageReference =
        FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask task = storageReference.putFile(selectedImage);
    StorageTaskSnapshot taskSnapshot = await task.onComplete;
    var post = await taskSnapshot.ref.getDownloadURL();
    setState(() {
      postUrl = post.toString();
    });
  }

  postToSelectedTag(Map postMap) {
    Firestore.instance
        .collection('Posts')
        .document('Public')
        .collection(selectedTag)
        .add(postMap)
        .catchError((onError) {
      print("Error posting to selected tag: $onError");
    });
  }

  post(BuildContext context) async {
    try {
      isLoading = true;
      if (selectedImage == null || selectedTag == null) {
        setState(() {
          isLoading = false;
        });
        showError();
      } else {
        if (selectedPublic && !selectedPrivate) {
          await uploadImageToPublic(selectedTag);
          if (postUrl != null) {
            Map<String, dynamic> postMap = {
              "url": postUrl,
              "username": widget.username,
              "caption": captionTEC.text,
              "time": DateTime.now().millisecondsSinceEpoch,
              "profileUrl": widget.profileUrl,
            };
            postToSelectedTag(postMap);
            isLoading = false;
            setState(() {});
            Navigator.pop(context);
          }
        }
      }
    } catch (e) {
      print("Error Posting: $e");
    }
  }
}
