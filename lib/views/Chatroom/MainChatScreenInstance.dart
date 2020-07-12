import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:link_text/link_text.dart';
import 'package:provider/provider.dart';
import 'package:schatty/enums/view_state.dart';
import 'package:schatty/helper/constants.dart';
import 'package:schatty/provider/image_upload_provider.dart';
import 'package:schatty/services/AuthenticationManagement.dart';
import 'package:schatty/services/DatabaseManagement.dart';
import 'package:schatty/views/Chatroom/TargetUserInfo.dart';
import 'package:schatty/widgets/widget.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomID;
  final String userName;

  ChatScreen(this.chatRoomID, this.userName);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool isComposing = false;
  bool isSelected = false;

  final TextEditingController messageTEC = TextEditingController();
  final TextEditingController captionTEC = TextEditingController();
  final DatabaseMethods databaseMethods = new DatabaseMethods();
  final AuthMethods authMethods = new AuthMethods();

  final Firestore firestore = Firestore.instance;

  final _picker = ImagePicker();

  Stream chatMessageStream;

  ImageUploadProvider imageUploadProvider;

  DateTime lastAccessedTime;

  String sentTo;
  String uid;
  String sentFrom;
  String url;
  String selectedText;
  String profileUrl;

  int selectedTime;

  bool onScreen;
  bool isSelectedOwner = false;
  bool isImage = false;

  File newImage;

  ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    onScreen = true;
    getProfileUrl();
    databaseMethods.getMessage(widget.chatRoomID).then((val) {
      setState(() {
        chatMessageStream = val;
      });
    });
    scrollController = ScrollController();
    setSentTo();
  }

  @override
  Widget build(BuildContext context) {
    String chatWith = widget.userName;
    imageUploadProvider = Provider.of<ImageUploadProvider>(context);
    return Scaffold(
//        backgroundColor: Color.fromARGB(255, 18, 18, 18),
        appBar: AppBar(
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                child: profileUrl != null
                    ? ClipOval(
                        child: CachedNetworkImage(
                          height: 35,
                          width: 35,
                          imageUrl: profileUrl,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Text(
                        "${chatWith.substring(0, 1).toUpperCase()}",
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(chatWith),
              ),
            ],
          ),
          actions: <Widget>[
            isSelected
                ? IconButton(
                    icon: Icon(Icons.content_copy),
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: selectedText),
                      );
                      setState(() {
                        isSelected = false;
                        selectedText = "";
                        Fluttertoast.showToast(msg: "Copied Content!");
                      });
                    },
                  )
                : SizedBox(),
            isSelected
                ? isSelectedOwner
                    ? IconButton(
                        icon: Icon(Icons.delete_forever),
                        onPressed: () {
                          deleteMessage(selectedText, selectedTime);
                        },
                      )
                    : SizedBox()
                : SizedBox(),
            isSelected
                ? IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () {
                      share(context, selectedText, isImage);
                      setState(() {
                        isSelected = false;
                        selectedText = "";
                        isImage = null;
                      });
                    },
                  )
                : SizedBox(),
            IconButton(
              icon: Icon(Icons.info),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (newcontext) => TargetUserInfo(widget.userName),
                    ));
              },
            )
          ],
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            isSelected = false;
            selectedText = null;
            setState(() {});
            print('called ontap');
          },
          child: Column(
            children: <Widget>[
              Flexible(
                child: Container(
                  child: StreamBuilder(
                      stream: chatMessageStream,
                      builder: (context, snapshot) {
                        return snapshot.hasData
                            ? ListView.builder(
                            cacheExtent: 50.0,
                            controller: scrollController,
                            reverse: true,
                            padding: EdgeInsets.only(top: 15),
                            itemCount: snapshot.data.documents.length,
                            itemBuilder: (context, index) {
                              return buildMessage(
                                  snapshot.data.documents[index]
                                      .data["message"],
                                  snapshot.data.documents[index]
                                      .data["sendBy"] ==
                                      Constants.ownerName.toLowerCase(),
                                  snapshot
                                      .data.documents[index].data["time"],
                                  snapshot
                                      .data.documents[index].data["url"],
                                  snapshot.data.documents[index]
                                      .data["isSeen"]);
                            })
                            : Container();
                      }),
                ),
              ),
              imageUploadProvider.getViewState == ViewState.LOADING
                  ? Container(
                alignment: Alignment.centerRight,
                margin: EdgeInsets.only(right: 15, top: 10),
                child: CircularProgressIndicator(),
              )
                  : Container(),
              buildMessageComposer(),
            ],
          ),
        ));
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  buildMessage(String message, bool isMe, int time, String imageUrl,
      bool read) {
    bool imageMessage = false;
    var timeInDM =
    DateFormat('dd:M:y').format(DateTime.fromMillisecondsSinceEpoch(time));
    newDay = compareTime(timeInDM);
    if (!(imageUrl == null || imageUrl == "")) {
      imageMessage = true;
    }
    final Widget msg = SafeArea(
        child: Container(
          padding: EdgeInsets.only(left: isMe ? 0 : 18, right: isMe ? 18 : 0),
          margin: EdgeInsets.symmetric(vertical: 8),
          width: MediaQuery
              .of(context)
              .size
              .width * 0.8,
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: GestureDetector(
            onLongPress: () {
              HapticFeedback.mediumImpact();
              if (!imageMessage) {
                setState(() {
                  isSelected = !isSelected;
                  selectedText = message;
                  selectedTime = time;
                  isSelectedOwner = isMe;
                  isImage = false;
                });
              } else {
                setState(() {
                  isSelected = !isSelected;
                  selectedText = imageUrl;
                  selectedTime = time;
                  isSelectedOwner = isMe;
                  isImage = true;
                });
              }
            },
            child: Container(
              padding: !imageMessage
                  ? EdgeInsets.symmetric(horizontal: 24, vertical: 16)
                  : EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              constraints: BoxConstraints(
                maxWidth: MediaQuery
                    .of(context)
                    .size
                    .width * 0.8,
              ),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: isMe
                          ? (!imageMessage
                          ? ([const Color(0xffff758c), const Color(0xffff7eb3)])
                          : [Color(0xffc8435f), Color(0xffc94d83)])
                          : (!imageMessage
                          ? ([Color(0xff93a5cf), const Color(0xff93a5cf)])
                          : [Color(0xff64769e), Color(0xff64769e)])),
                  borderRadius: isMe
                      ? BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18))
                      : BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                      bottomRight: Radius.circular(18))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Flexible(
                    child: (!imageMessage)
                        ? LinkText(
                      text: message,
                      textStyle: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      //                        crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        viewImage(
                                            imageUrl, context, message, time),
                                  ));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(23)),
                              child: Hero(
                                tag: time,
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  errorWidget: (context, msg, error) =>
                                      Center(
                                        child: Text(
                                            "Error loading $msg: $error"),
                                      ),
                                ),
                              ),
                            )),
                        message != ""
                            ? Container(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            message,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                            : Container(),
                      ],
                    ),
                  ),
                  !imageMessage
                      ? Container(
                    padding: EdgeInsets.only(left: 10, top: 3, bottom: 0),
                    child: Text(
                      !newDay
                          ? DateFormat('kk:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(time))
                          : DateFormat('kk:mm dd/M').format(
                          DateTime.fromMillisecondsSinceEpoch(time)),
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  )
                      : Container(),
                  !imageMessage && read && isMe
                      ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Icon(
                      Icons.check,
//                    color: Color(0xff51cec0),
                      size: 15,
                    ),
                  )
                      : Container(),
                ],
              ),
            ),
          ),
        ));
    return msg;
  }

  Widget composeImage() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(newImage),
                      fit: BoxFit.none,
                    )),
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: TextField(
                        controller: captionTEC,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: sendImage(context),
                        decoration: InputDecoration(
                          hintText: "Caption",
                          hintStyle: TextStyle(
                            color: Colors.black54,
                            fontSize: 24,
                          ),
                          contentPadding:
                          EdgeInsets.only(left: 15, top: 20, bottom: 20),
                          fillColor: Colors.white70,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        )),
                  ),
                  IconButton(
                    onPressed: () {
                      sendImage(context);
                    },
                    icon: Icon(Icons.send),
                    color: Colors.blue,
                    iconSize: 25,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  buildMessageComposer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      height: 70,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_drop_up),
            onPressed: () {
              showSheet();
            },
          ),
          Expanded(
            child: TextField(
              controller: messageTEC,
              textCapitalization: TextCapitalization.sentences,
              enableSuggestions: true,
              textInputAction: TextInputAction.send,
              onSubmitted: (val) {
                sendMessage();
              },
              decoration: InputDecoration(
                contentPadding:
                EdgeInsets.only(left: 15, top: 20, bottom: 20, right: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
                hintText: 'Say something...',
                filled: true,
                hintStyle: TextStyle(color: Colors.grey[400]),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            iconSize: 25,
            color: Color(0xff51cec0),
            onPressed: () {
              HapticFeedback.lightImpact();
              sendMessage();
            },
          )
        ],
      ),
    );
  }

  showSheet() {
    showModalBottomSheet(
        context: context,
        elevation: 3,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30),
              topLeft: Radius.circular(30),
            )),
        builder: (context) {
          return _buildBottomNavigationMenu();
        });
  }

  Column _buildBottomNavigationMenu() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(Icons.camera_alt),
          title: Text("Camera"),
          onTap: () => getImage(context, ImageSource.camera),
        ),
        ListTile(
          leading: Icon(Icons.collections),
          title: Text("Gallery"),
          onTap: () => getImage(context, ImageSource.gallery),
        ),
        ListTile(
          leading: Icon(Icons.attach_file),
          title: Text("Image from Url"),
          onTap: () => showUrlDialog(context),
        )
      ],
    );
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
                    TextField(
                      controller: captionTEC,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(
                            left: 15, top: 20, bottom: 20, right: 15),
                        hintText: 'Caption',
                        filled: true,
                        hintStyle: TextStyle(color: Colors.grey[400]),
                      ),
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
                child: Text("Send"),
                onPressed: () {
                  if (formKey.currentState.validate()) {
                    sendImageFromUrl(urlTEC.text, captionTEC.text);
                    Navigator.pop(context);
                  } else {}
                },
              )
            ],
          );
        });
  }

  setSeen() async {
    CollectionReference ref;
    await Firestore.instance
        .collection('ChatRoom')
        .where("chatRoomId", isEqualTo: widget.chatRoomID)
        .getDocuments()
        .then((docs) async {
      ref = Firestore.instance
          .collection('ChatRoom')
          .document(docs.documents[0].documentID)
          .collection('chats');
    });
    QuerySnapshot querySnapshot = await ref
        .where('sendTo', isEqualTo: sentFrom)
        .where('sentFrom', isEqualTo: sentTo)
        .where('isSeen', isEqualTo: false)
        .getDocuments();
    querySnapshot.documents.forEach((msgDoc) {
      msgDoc.reference.updateData({'isSeen': true});
    });

    await Firestore.instance
        .collection('ChatRoom')
        .where('chatRoomId', isEqualTo: widget.chatRoomID)
        .getDocuments()
        .then((docs) {
      Firestore.instance
          .collection('ChatRoom')
          .document(docs.documents[0].documentID)
          .updateData({"seenBy.${Constants.ownerName}": true});
    });
  }

  setSentTo() async {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    FirebaseUser user = await firebaseAuth.currentUser();
    sentTo = await databaseMethods.getUIDByUsername(widget.userName);
    sentFrom = user.uid;
    setSeen();
    if (mounted) {
      setState(() {});
    }
  }

  getProfileUrl() async {
    profileUrl = await databaseMethods
        .getProfileUrlByName(widget.userName.toLowerCase());
    setState(() {});
  }

  sendMessage() async {
    if (messageTEC.text.isNotEmpty && messageTEC.text
        .trim()
        .isNotEmpty) {
//      print(sentTo);
      Map<String, dynamic> messageMap = {
        "message": messageTEC.text,
        "sendBy": Constants.ownerName,
        "time": DateTime
            .now()
            .millisecondsSinceEpoch,
        "sendTo": sentTo,
        "sentFrom": sentFrom,
        "url": "",
        "isSeen": false,
      };
      databaseMethods.addMessage(widget.chatRoomID, messageMap);
      databaseMethods.updateLastMessage(
          messageTEC.text, widget.chatRoomID, widget.userName);
      messageTEC.text = "";
      scrollController.animateTo(scrollController.position.minScrollExtent,
          duration: Duration(milliseconds: 600), curve: Curves.easeInOut);
    }
  }

  sendImage(BuildContext context) async {
    try {
//      Navigator.pop(context);
      imageUploadProvider.setToLoading();
      final String fileName = 'userImages/' +
          uid.toString() +
          '/${DateTime
              .now()
              .millisecondsSinceEpoch
              .toString()}.jgp';
      final StorageReference storageReference =
      FirebaseStorage.instance.ref().child(fileName); //ref to storage
      StorageUploadTask task =
      storageReference.putFile(newImage); //task to upload file
      StorageTaskSnapshot snapshotTask = await task.onComplete;
      var downloadUrl = await snapshotTask.ref
          .getDownloadURL(); //download url of the image uploaded
      String url = downloadUrl.toString();
      setState(() {});
      Map<String, dynamic> imageMap = {
        "message": captionTEC.text,
        "sendBy": Constants.ownerName,
        "time": DateTime
            .now()
            .millisecondsSinceEpoch,
        "sendTo": sentTo,
        "sentFrom": sentFrom,
        "url": url,
        "seen": false,
      };

      databaseMethods.updateLastMessage(
          "Image", widget.chatRoomID, widget.userName);
      databaseMethods.addMessage(widget.chatRoomID, imageMap);
      imageUploadProvider.setToIdle();
    } catch (e) {
      print("SendImageError: $e");
    }
  }

  sendImageFromUrl(String url, String caption) {
    try {
      imageUploadProvider.setToLoading();
      setState(() {});
      Map<String, dynamic> imageMap = {
        "message": caption,
        "sendBy": Constants.ownerName,
        "time": DateTime
            .now()
            .millisecondsSinceEpoch,
        "sendTo": sentTo,
        "sentFrom": sentFrom,
        "url": url
      };
      databaseMethods.updateChatRoomTime(widget.chatRoomID);
      databaseMethods.addMessage(widget.chatRoomID, imageMap);
      imageUploadProvider.setToIdle();
    } catch (e) {
      print("IMAGE FROM URL ERROR: $e");
    }
  }

  Future getImage(BuildContext context, ImageSource source) async {
    try {
      PickedFile tempPickedFile = await _picker.getImage(source: source);
      setState(() {
        cropImage(File(tempPickedFile.path), context);
      });
//      await Future.delayed(Duration(seconds: 2, milliseconds: 500));
    } catch (e) {
      print("GetImageError: $e");
    }
  }

  cropImage(File tempPic, BuildContext context) async {
    File edited;
    if (tempPic != null) {
      edited = await ImageCropper.cropImage(
          sourcePath: tempPic.path,
          compressQuality: 70,
//          cropStyle: CropStyle.rectangle,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
            toolbarTitle: "Crop",
//              toolbarColor: Colors.blue,
//              statusBarColor: Colors.blue,
//              activeControlsWidgetColor: Colors.blue
          )).whenComplete(() {
//        print("Completed!");
      });
    }
    if (edited != null) {
      newImage = edited;
      sendImage(context);
    } else {
      print("null");
    }
  }

  bool newDay = true;

  deleteMessage(String message, int time) async {
    try {
      if (message != url) {
        await Firestore.instance
            .collection('ChatRoom')
            .document(widget.chatRoomID)
            .collection('chats')
            .where('message', isEqualTo: message)
            .where('time', isEqualTo: time)
            .getDocuments()
            .then((docs) async {
          await Firestore.instance
              .collection('ChatRoom')
              .document(widget.chatRoomID)
              .collection('chats')
              .document(docs.documents[0].documentID)
              .delete();
        });
      } else {
        print('Its a url');
        await Firestore.instance
            .collection('ChatRoom')
            .document(widget.chatRoomID)
            .collection('chats')
            .where('url', isEqualTo: message)
            .where('time', isEqualTo: time)
            .getDocuments()
            .then((docs) async {
          await Firestore.instance
              .collection('ChatRoom')
              .document(widget.chatRoomID)
              .collection('chats')
              .document(docs.documents[0].documentID)
              .delete();
        });
      }
      isSelected = false;
      selectedTime = null;
      selectedText = null;
      if (mounted) setState(() {});
    } catch (e) {
      print("Error deleting message: $e");
    }
  }
}
