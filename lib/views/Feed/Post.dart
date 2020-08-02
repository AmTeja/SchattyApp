import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';
import 'package:schatty/provider/DarkThemeProvider.dart';
import 'package:schatty/services/AuthenticationManagement.dart';
import 'package:schatty/services/DatabaseManagement.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

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
bool newTag = false;
bool isVideo = false;
bool compressVideo = false;

File selectedFile;

String selectedTag;
String postUrl;
String ranString;
String urlFromImage;
String selectedFilePath;
String status = "Getting file";

TextEditingController captionTEC = new TextEditingController();
TextEditingController titleTEC = new TextEditingController();
TextEditingController tagTEC = new TextEditingController();

FlickManager flickManager;

Stream tagStream;
ScrollController tagController;

final tagFormKey = new GlobalKey<FormState>();
final postFormKey = new GlobalKey<FormState>();

DatabaseMethods databaseMethods = new DatabaseMethods();

ImagePicker picker = ImagePicker();
final videoCompress = VideoCompress();

class _PostContentState extends State<PostContent> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedFile = null;
    setTagStream();
    isVideo = false;
    tagController = new ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading
        ? Consumer<DarkThemeProvider>(
      builder: (BuildContext context, value, Widget child) {
        return newBody();
      },
    )
        : postingStatus();
  }

  Widget postingStatus() {
    return Scaffold(
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  "$status",
                  style: TextStyle(fontSize: 40),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.black,
                ),
              )
            ],
          ),
        ),
      ),
    );
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
                  colors: [Color(0xff111111), Color(0xff111111)],
                      begin: Alignment.center,
                      end: Alignment.bottomLeft)
          ),
          child: Center(
            child: ListView(
              physics: selectedFile == null
                  ? NeverScrollableScrollPhysics()
                  : AlwaysScrollableScrollPhysics(),
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
                    selectedFile == null && urlFromImage == null
                        ? Row(
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
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.videocam,
                                    color: Colors.white,
                                    size: 35,
                                  ),
                                  onPressed: () {
                                    getVideo();
                                  },
                                ),
                              ),
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
                    ) : Container(
                      child: isVideo ? FlickVideoPlayer(
                        flickManager: flickManager,
                      ) : Image.file(selectedFile, fit: BoxFit.cover,),
                    ),
//                    Padding(
//                      padding: const EdgeInsets.symmetric(
//                          horizontal: 8.0, vertical: 30.0),
//                      child: Container(
//                        child: selectedFile == null ? Text(
//                          "File: ",
//                          style: TextStyle(fontSize: 24, color: Colors.white),
//                        ) : Text(
//                          "File: $selectedFilePath",
//                          style: TextStyle(fontSize: 24, color: Colors.white),
//                        ),
//                      ),
//                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TitleField(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CaptionField(),
                    ),
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

  // ignore: non_constant_identifier_names
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

  // ignore: non_constant_identifier_names
  Widget TitleField() {
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width * 0.70,
      child: Form(
        key: postFormKey,
        child: TextFormField(
          maxLines: 1,
          validator: TitleValidator.validate,
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
      ),
    );
  }

  setTagStream() {
    tagStream =
        Firestore.instance.collection('Posts').document('Public').collection(
            'Tags').snapshots();
    setState(() {

    });
  }

  getVideo() async {
    try {
//      PickedFile tempVideo;
//      tempVideo = await picker.getVideo(source: ImageSource.gallery, maxDuration: Duration(minutes: 2));
      var tempFile = await FilePicker.getFile(
        type: FileType.video,
      );
//      if(tempFile)
      if (tempFile != null) {
        selectedFile = File(tempFile.path);
        int sizeInByte = selectedFile.lengthSync();
        double sizeInMb = sizeInByte / (1024 * 1024);
        flickManager = FlickManager(
            autoPlay: false,
            videoPlayerController: VideoPlayerController.file(selectedFile));
        print(selectedFile.path);
        if (sizeInMb < 30) {
          isVideo = true;
          selectedFilePath =
              selectedFile.path;
          setState(() {

          });
        }
        else {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("File size alert"),
                  content: Text(
                      "The selected file is more than 30 Mb.\nPlease choose a file less than 30Mb."),
                  actions: [
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                        selectedFile = null;
                        isVideo = false;
                      },
                      child: Text("Ok"),
                    ),
                  ],
                );
              }
          );
        }
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
          selectedFilePath =
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
            maxWidth: 1080,
            maxHeight: 1920,
            compressFormat: ImageCompressFormat.jpg,
            compressQuality: 100,
            androidUiSettings: AndroidUiSettings(
              toolbarTitle: "Crop Image",
              toolbarColor: Color(0xff99d8d0),
              toolbarWidgetColor: Colors.white,
              backgroundColor: Colors.black,
              activeControlsWidgetColor: Color(0xff99d8d0),
            ));
        setState(() {
          if (cropped != null) {
            selectedFile = cropped;
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
              color: Colors.transparent,
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.55,
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.7,
              child: ListView(
                controller: tagController,
                children: [
                  StreamBuilder(
                    stream: tagStream,
                    builder: (context, snapshot) {
                      return snapshot.hasData ?
                      ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) {
                            return tagContainer(
                                snapshot.data.documents[index].data["tag"]);
                          }
                      ) : Container(child: Center(child: Text("No tags"),),);
                    },
                  ),
                  Form(
                      key: tagFormKey,
                      child: TextFormField(
                        validator: TagValidator.validate,
                        style: TextStyle(fontSize: 18),
                        onTap: () {
                          print('Tapped on field');
                          tagController.animateTo(
                              tagController.position.maxScrollExtent,
                              duration: Duration(milliseconds: 1000),
                              curve: Curves.easeInOut);
                        },
                        decoration: InputDecoration(
                            hintText: "New tag",
                            suffixIcon: IconButton(
                              icon: Icon(Icons.create),
                              color: Color(0xFF7ED9F1),
                              onPressed: () {
                                createNewTag();
                              },
                            ),
                            focusColor: Color(0xFF7ED9F1),
                            border: OutlineInputBorder(
                              borderSide:
                              BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(40),
                            )
                        ),
                        controller: tagTEC,
                      ))
                ],
              ),
            ),
          );
        });
  }

  createNewTag() {
    if (tagFormKey.currentState.validate()) {
      Firestore.instance.collection('Posts').document('Public').collection(
          'Tags').document(selectedTag).setData(
          {'tag': tagTEC.text, 'posts': 0});
      tagSelected(tagTEC.text);
      tagTEC.text = "";
      Navigator.pop(context);
    }
  }

  bool tagIsSelected = false;

  Widget tagContainer(String title) {
    return ListTile(
      key: Key(title),
      title: Text(title),
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
    ranString = randomString(10);
  }


  uploadVideo(String tag) async {
    try {
      final String fileName = 'PublicPosts/' + tag + '/$ranString.mp4';
      getRandom();
      int sizeInByte = selectedFile.lengthSync();
      double sizeInMb = sizeInByte / (1024 * 1024);
      if (sizeInMb <= 30) {
        print("uploading");
        status = "Uploading";
        setState(() {

        });
        final StorageReference storageReference =
        FirebaseStorage.instance.ref().child("$fileName");
        StorageUploadTask task = storageReference.putFile(selectedFile);
        StorageTaskSnapshot taskSnapshot = await task.onComplete;
        var post = await taskSnapshot.ref.getDownloadURL();
        setState(() {
          postUrl = post.toString();
        });
      }
    } catch (e) {
      print("Error uploading video: $e");
    }
  }

  uploadImageToPublic(String tag) async {
    getRandom();
    print("uploading");
    status = "Uploading";
    setState(() {

    });
    final String fileName = 'PublicPosts/' + tag + '/$ranString.jpg';
    final StorageReference storageReference =
    FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask task = storageReference.putFile(selectedFile);
    StorageTaskSnapshot taskSnapshot = await task.onComplete;
    var post = await taskSnapshot.ref.getDownloadURL();
    setState(() {
      postUrl = post.toString();
    });
  }

  showUrlDialog(BuildContext context) {
    TextEditingController urlTEC = new TextEditingController();

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
    });
    int posts;
    await Firestore.instance.collection('Posts').document('Public').collection(
        'Tags').document(selectedTag).get().then((docs) async {
      posts = await docs.data['posts'];
      posts++;
      Firestore.instance.collection('Posts').document('Public').collection(
          'Tags').document(selectedTag).updateData({'posts': posts});
    });
  }

  nsfwTrigger(bool val) {
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

  updateUserPosts() async
  {
    var uid = await databaseMethods.getUIDByUsername(widget.username);
    int posts;
    await Firestore.instance.collection('users').document(uid).get().then((
        docs) async {
      posts = await docs.data["numPosts"];
      posts++;
      await Firestore.instance.collection('users').document(uid).updateData(
          {'numPosts': posts});
    });
  }

  post(BuildContext context) async {
    try {
      if (postFormKey.currentState.validate()) {
        print('called');
        isLoading = true;
        status = "Getting file";
        if (mounted) {
          setState(() {

          });
        }
        if (selectedFile == null && selectedTag == null &&
            urlFromImage == null) {
          setState(() {
            isLoading = false;
          });
          showError();
        } else {
          print('Else called: $selectedPublic');
          if (selectedPublic) {
            if (urlFromImage == null) {
              if (isVideo) {
                await uploadVideo(selectedTag);
              }
              else if (!isVideo) {
                await uploadImageToPublic(selectedTag);
              }
            }
          print('Uploaded!');
          if (postUrl != null || urlFromImage != null) {
            status = "Almost done";
            setState(() {

            });
            print("not null");
            Map<String, dynamic> postMap = {
              "url": postUrl ?? urlFromImage,
              "username": widget.username,
              "caption": captionTEC.text,
              "time": DateTime
                  .now()
                  .millisecondsSinceEpoch,
              "likes": [""],
              "dislikes": [""],
              "postUid": ranString,
              "NSFW": nsfw ?? false,
              "title": titleTEC.text,
              "titleIndex": await makeIndex(),
              "numLikes": 0,
              "numDislikes": 0,
              "isVideo": isVideo,
            };
            postToSelectedTag(postMap);
            updateUserPosts();
            isLoading = false;
            captionTEC.text = "";
            selectedTag = null;
            urlFromImage = null;
            titleTEC.text = "";
            captionTEC.text = "";
            isVideo = false;
            setState(() {});
            print("done");
            Navigator.pop(context);
          }
        }
        }
      }
    } catch (e) {
      print("Error Posting: $e");
      isLoading = false;
      Fluttertoast.showToast(msg: "An error occurred: $e");
    }
  }
}
