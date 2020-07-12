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
import 'package:random_string/random_string.dart';
import 'package:schatty/provider/DarkThemeProvider.dart';
import 'package:schatty/services/AuthenticationManagement.dart';
import 'package:schatty/widgets/widget.dart';

class PostContent extends StatefulWidget {
  final bool isDark;
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
bool dev = true;
bool nsfw = false;


File selectedImage;

String selectedTag;
String postUrl;
String ranString;
String urlFromImage;
String selectedImagePath;

TextEditingController captionTEC = new TextEditingController();
TextEditingController titleTEC = new TextEditingController();

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
        return newBody();
      },
    )
        : loadingScreen("Posting...");
  }

  Widget newBody() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: !widget.isDark ? Color(0xFF7ED9F1) : Colors.black,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          width: MediaQuery
              .of(context)
              .size
              .width,
          decoration: BoxDecoration(
              gradient: !widget.isDark ? LinearGradient(
                  colors: [Color(0xFF7ED9F1), Color(0xFF3FB9D9)],
                  begin: Alignment.center,
                  end: Alignment.bottomRight) :
              LinearGradient(
                  colors: [Color(0xff111111), Color(0xff3B3B3B)],
                  begin: Alignment.center,
                  end: Alignment.bottomLeft)
          ),
          child: Center(
            child: ListView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.1,
                    ),
                    selectedImage == null && urlFromImage == null ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            icon: Icon(
                              Icons.collections,
                              color: Colors.white,
                              size: 35,
                            ),
                            onPressed: () {
                              getImage(ImageSource.gallery);
                            },
                          ),
                        ),
//                        Padding(
//                          padding: const EdgeInsets.all(8.0),
//                          child: IconButton(
//                            icon: Icon(
//                              Icons.videocam,
//                              color: Colors.white,
//                              size: 35,
//                            ),
//                            onPressed: () {
//                              getVideo();
//                            },
//                          ),
//                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            icon: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 35,
                            ),
                            onPressed: () {
                              getImage(ImageSource.camera);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            icon: Icon(
                              Icons.attach_file,
                              color: Colors.white,
                              size: 35,
                            ),
                            onPressed: () {
                              showUrlDialog(context);
                            },
                          ),
                        ),
                      ],
                    ) : SizedBox(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 30.0),
                      child: Container(
                        child: selectedImage == null ? Text(
                          "File: ",
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ) : Text(
                          "File: $selectedImagePath",
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                      ),
                    ),
                    TitleField(),
                    CaptionField(),
                    Container(
                      padding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 64),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Tag/Flag :",
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                          selectedTag == null ? IconButton(
                            icon: Icon(
                              Icons.add_box,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: () {
                              selectTag(context);
                            },
                          ) : GestureDetector(onTap: () {
                            selectTag(context);
                          },
                            child: Text(selectedTag, style: TextStyle(
                                color: Colors.white, fontSize: 24),),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 64),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("NSFW: ",
                              style: TextStyle(
                                fontSize: 24, color: Colors.white,
                              )),
                          Switch(
                            value: nsfw,
                            onChanged: (value) => nsfwTrigger(value),
                          )
                        ],
                      ),),
                    SizedBox(
                      height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.05,
                    ),
//                    Container(
//                      padding:
//                          EdgeInsets.symmetric(vertical: 8, horizontal: 90),
//                      child: Row(
//                        children: [
//                          GestureDetector(
//                              onTap: () {
//                                _selectedPublic();
//                              },
//                              child: Text(
//                                "Public",
//                                style: TextStyle(
//                                    fontSize: 40,
//                                    fontWeight: FontWeight.bold,
//                                    color: !selectedPublic ? Color.fromARGB(153, 245, 245, 245) : Color.fromARGB(255, 245, 245, 245)),
//                              )),
//                          SizedBox(width: 30),
//                          GestureDetector(
//                            onTap: (){
//                              _selectedPrivate();
//                            },
//                            child: Text(
//                              "Private",
//                              style: TextStyle(
//                                  fontSize: 40,
//                                  fontWeight: FontWeight.bold,
//                                  color: !selectedPrivate ? Color.fromARGB(153, 245, 245, 245) : Color.fromARGB(255, 245, 245, 245)),
//                            ),
//                          )
//                        ],
//                      ),
//                    ),
                    Container(
                      padding: EdgeInsets.all(28),
                      child: FlatButton(
                        splashColor: Color(0xFF7ED9F1),
                        textColor: Color.fromARGB(255, 126, 217, 241),
                        child: Text(
                          "P O S T",
                          style: TextStyle(fontSize: 20),
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        color: Colors.white,
                        onPressed: () {
                          post(context);
                        },
                        padding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery
                          .of(context)
                          .size
                          .height * .025,
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      iconSize: 50,
                      color: Color(0xFFF5F5F5),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      splashColor: Color(0xFF7ED9F1),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget CaptionField() {
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width * 0.70,
      child: TextField(
        maxLines: 3,
        controller: captionTEC,
        textCapitalization: TextCapitalization.sentences,
        style: TextStyle(color: Colors.white, fontSize: 24),
        maxLength: 500,
        decoration: InputDecoration(
            focusColor: Colors.white,
            hoverColor: Colors.white,
            labelText: "Caption",
            labelStyle: TextStyle(color: Colors.white, fontSize: 20),
            contentPadding: EdgeInsets.all(12),
            filled: false,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            )),
      ),
    );
  }

  Widget TitleField() {
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width * 0.70,
      child: TextField(
        maxLines: 1,
        controller: titleTEC,
        textCapitalization: TextCapitalization.sentences,
        style: TextStyle(color: Colors.white, fontSize: 24),
        maxLength: 50,
        decoration: InputDecoration(
            focusColor: Colors.white,
            hoverColor: Colors.white,
            labelText: "Title",
            labelStyle: TextStyle(color: Colors.white, fontSize: 20),
            contentPadding: EdgeInsets.all(12),
            filled: false,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            )),
      ),
    );
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

  getVideo() async {
    try {
      var tempVideo = await picker.getVideo(source: ImageSource.gallery);
      if (tempVideo != null) {
        selectedImage = File(tempVideo.path);
      }
    } catch (e) {
      print('Error getting video: $e');
    }
  }

  getImage(ImageSource source) async {
    try {
      var tempPic = await picker.getImage(source: source);
      if (tempPic != null) {
        setState(() {
          cropImage(tempPic.path);
          selectedImagePath =
              tempPic.path.substring(tempPic.path.indexOf("image_picker"))
                  .replaceAllMapped("image_picker", (match) {
                return "";
              });
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
                  tagContainer("Sci-Fi",),
                  tagContainer("Memes"),
                  tagContainer("Tech",),
                  tagContainer("Art"),
                  tagContainer("Animals"),
                  tagContainer("History"),
                  tagContainer("Educational"),
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
        msg: "Invalid Image/Tag(Choose Public)", gravity: ToastGravity.CENTER);
  }

  getRandom() {
    ranString = randomString(10);
  }

  uploadImageToPublic(String tag) async {
    getRandom();
    print("uploading");
    final String fileName = 'PublicPosts/' + tag + '/$ranString.jgp';
    final StorageReference storageReference =
    FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask task = storageReference.putFile(selectedImage);
    StorageTaskSnapshot taskSnapshot = await task.onComplete;
    var post = await taskSnapshot.ref.getDownloadURL();
    setState(() {
      postUrl = post.toString();
    });
  }

  showUrlDialog(BuildContext context) {
    TextEditingController urlTEC = new TextEditingController();
    TextEditingController captionTEC = new TextEditingController();

    final formKey = GlobalKey<FormState>();
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Image from Url"),
            content: Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 65,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      validator: UrlValidator.validate,
                      controller: urlTEC,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(
                            left: 15, top: 20, bottom: 20, right: 15),
                        hintText: 'Url',
                        filled: true,
                        hintStyle: TextStyle(color: Colors.grey[400]),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              FlatButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("Select"),
                onPressed: () {
                  if (formKey.currentState.validate()) {
                    if (mounted) {
                      setState(() {
                        urlFromImage = urlTEC.text;
                      });
                    }
                    Navigator.pop(context);
                  } else {}
                },
              )
            ],
          );
        });
  }


  postToSelectedTag(Map postMap) async {
    await Firestore.instance
        .collection('Posts')
        .document('Public')
        .collection(selectedTag)
        .add(postMap)
        .catchError((onError) {
      print("Error posting to selected tag: $onError");
    }).then((doc) {

    });
  }

  nsfwTrigger(bool val) {
    print(val);
    if (mounted) {
      setState(() {
        nsfw = val;
      });
    }
  }

  makeIndex() {
    List<String> splitList = titleTEC.text.split(" ");
    List<String> indexList = [];
    for (int i = 0; i < splitList.length; i++) {
      for (int y = 0; y < splitList[i].length + 1; y++) {
        indexList.add(splitList[i].substring(0, y).toLowerCase());
      }
    }
    return indexList;
  }


  post(BuildContext context) async {
    try {
      print('called');
      isLoading = true;
      if (mounted) {
        setState(() {

        });
      }
      if (selectedImage == null && selectedTag == null &&
          urlFromImage == null) {
        setState(() {
          isLoading = false;
        });
        showError();
      } else {
        print('Else called: $selectedPublic');
        if (selectedPublic) {
          if (urlFromImage == null) {
            await uploadImageToPublic(selectedTag);
          }
          print('Uploaded!');
          if (postUrl != null || urlFromImage != null) {
            print("not null");
            Map<String, dynamic> postMap = {
              "url": postUrl ?? urlFromImage,
              "username": widget.username,
              "caption": captionTEC.text,
              "time": DateTime.now().millisecondsSinceEpoch,
              "profileUrl": widget.profileUrl,
              "likes": [""],
              "dislikes": [""],
              "postUid": ranString,
              "NSFW": nsfw ?? false,
              "title": titleTEC.text,
              "titleIndex": await makeIndex(),
            };
            postToSelectedTag(postMap);
            isLoading = false;
            captionTEC.text = "";
            selectedTag = null;
            urlFromImage = null;
            setState(() {});
            print("done");
            Navigator.pop(context);
          }
        }
      }
    } catch (e) {
      print("Error Posting: $e");
    }
  }
}
