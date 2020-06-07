import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:schatty/enums/view_state.dart';
import 'package:schatty/helper/cachednetworkimage.dart';
import 'package:schatty/helper/constants.dart';
import 'package:schatty/helper/preferencefunctions.dart';
import 'package:schatty/provider/image_upload_provider.dart';
import 'package:schatty/services/AuthenticationManagement.dart';
import 'package:schatty/services/DatabaseManagement.dart';
import 'package:schatty/views/TargetUserInfo.dart';

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

  DatabaseMethods databaseMethods = new DatabaseMethods();
  final AuthMethods authMethods = new AuthMethods();

  Stream chatMessageStream;

  ImageUploadProvider imageUploadProvider;

  DateTime lastAccessedTime;

  String sentTo;

  File newImage;

  ScrollController scrollController;

  @override
  void initState() {
//    lastAccessedTime = DateTime.now();
    HelperFunctions.getUserNameSharedPreference();
    databaseMethods.getMessage(widget.chatRoomID).then((val) {
      setState(() {
        chatMessageStream = val;
      });
    });
    super.initState();
    scrollController = ScrollController();
    setSentTo();
  }

  getUID() async {
    uid = await databaseMethods.getUIDByUsername(Constants.ownerName);
  }

  setSentTo() async {
    sentTo = await databaseMethods.getUIDByUsername(widget.userName);
    setState(() {
      print(sentTo);
    });
  }

//  Future<String> getDataFromFuture(String message) async {
//    print("Data Future");
//    keyPair = await futureKeyPair;
//    String decrypted;
//    decrypted = decrypt(message, keyPair.privateKey);
//    print(decrypted);
//    return decrypted;
//  }

  @override
  Widget build(BuildContext context) {
    String chatWith = widget.userName;
    imageUploadProvider = Provider.of<ImageUploadProvider>(context);
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 18, 18, 18),
        appBar: AppBar(
          title: isComposing ? Text(chatWith + "is typing...") : Text(chatWith),
          backgroundColor: Colors.black12,
          actions: <Widget>[
            isSelected ? IconButton(
              icon: Icon(Icons.content_copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: selectedText),);
                setState(() {
                  isSelected = false;
                  selectedText = "";
                  Fluttertoast.showToast(msg: "Copied Content!");
                });
              },
            ) : SizedBox(),
            IconButton(
              icon: Icon(Icons.info),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TargetUserInfo(chatWith)));
              },
            )
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: <Widget>[
              Flexible(
                child: Container(
                  child: StreamBuilder(
                      stream: chatMessageStream,
                      builder: (context, snapshot) {
                        return snapshot.hasData
                            ? ListView.builder(
                            controller: scrollController,
                            reverse: true,
                            padding: EdgeInsets.only(top: 15),
                            itemCount: snapshot.data.documents.length,
                            itemBuilder: (context, index) {
                              return
                                buildMessage(
                                    snapshot.data.documents[index]
                                        .data["message"],
                                    snapshot.data.documents[index]
                                        .data["sendBy"] ==
                                        Constants.ownerName,
                                    snapshot.data.documents[index]
                                        .data["time"],
                                    snapshot.data.documents[index]
                                        .data["url"]);
                            }) : Container();
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

  buildMessageComposer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      height: 70,
      color: Colors.black,
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () {
              getImage();
            },
            icon: Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 25,
            ),
            splashColor: Colors.blue,
            padding: EdgeInsets.symmetric(horizontal: 10),
          ),
          Expanded(
            child: TextField(
              controller: messageTEC,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) {

              },
              textInputAction: TextInputAction.send,
              onSubmitted: (val) {
                sendMessage();
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 15, top: 20, bottom: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
                hintText: 'Say something...',
                fillColor: Colors.white,
                filled: true,
                hintStyle: TextStyle(color: Colors.grey[400]),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            iconSize: 25,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              sendMessage();
            },
          )
        ],
      ),
    );
  }

  sendMessage() async {
    if (messageTEC.text.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        "message": messageTEC.text,
        "sendBy": Constants.ownerName,
        "time": DateTime
            .now()
            .millisecondsSinceEpoch,
        "sendTo": sentTo,
      };
      databaseMethods.addMessage(widget.chatRoomID, messageMap);
      messageTEC.text = "";
      Map<String, dynamic> timeMap = {
        "lastTime": DateTime
            .now()
            .millisecondsSinceEpoch,
      };
      databaseMethods.updateChatRoomTime(widget.chatRoomID, timeMap);
      scrollController.animateTo(scrollController.position.minScrollExtent,
          duration: Duration(milliseconds: 600), curve: Curves.easeInOut);
    }
  }

  sendImage(BuildContext context) async {
    try {
      Navigator.pop(context);
      imageUploadProvider.setToLoading();
      final String fileName =
          'userImages/' + uid.toString() + '/${DateTime
              .now()
              .millisecondsSinceEpoch
              .toString()}.jgp';
      print("Filename Set!");
      final StorageReference storageReference =
      FirebaseStorage.instance.ref().child(fileName); //ref to storage
      StorageUploadTask task = storageReference.putFile(
          newImage); //task to upload file
      StorageTaskSnapshot snapshotTask = await task.onComplete;
      var downloadUrl = await snapshotTask.ref
          .getDownloadURL(); //download url of the image uploaded
      String url = downloadUrl.toString();
      setState(() {

      });
      Map<String, dynamic> imageMap = {
        "message": captionTEC.text,
        "sendBy": Constants.ownerName,
        "time": DateTime
            .now()
            .millisecondsSinceEpoch,
        "sendTo": sentTo,
        "sentFrom": sentFrom,
        "url": url
      };
      databaseMethods.addMessage(widget.chatRoomID, imageMap);
      imageUploadProvider.setToIdle();
    } catch (e) {
      print("SendImageError: $e");
    }
  }


  Future getImage() async {
    try {
      var tempPic = await ImagePicker.pickImage(source: ImageSource.gallery);
      File edited;
      if (tempPic != null) {
        edited = await ImageCropper.cropImage(sourcePath: tempPic.path,
            compressQuality: 70,
            cropStyle: CropStyle.rectangle,
            compressFormat: ImageCompressFormat.jpg,
            androidUiSettings: AndroidUiSettings(
                toolbarColor: Colors.blue,
                statusBarColor: Colors.blue,
                activeControlsWidgetColor: Colors.blue
            )
        );
      }
//    await Future.delayed(Duration(seconds: 2));
      setState(() {
        if (edited != null) {
          newImage = edited;
          print("newImage set");
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => composeImage(),
          ));
        }

      });
    }
    catch (e) {
      print("GetImageError: $e");
    }
  }

  buildMessage(String message, bool isMe, int time, String imageUrl) {
    var currentTime = DateTime.now();
    bool newDay = false;
    final Widget msg = SafeArea(
        child: Container(
          padding: EdgeInsets.only(
              left: isMe ? 0 : 18, right: isMe ? 18 : 0),
          margin: EdgeInsets.symmetric(vertical: 8),
          width: MediaQuery
              .of(context)
              .size
              .width,
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child:
          GestureDetector(
            onTap: () {
              if (imageUrl == null && !isSelected) {
                setState(() {
                  isSelected = !isSelected;
                  selectedText = message;
                });
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              constraints: BoxConstraints(
                maxWidth: MediaQuery
                    .of(context)
                    .size
                    .width * 0.8,
              ),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: isMe
                          ? ([const Color(0xffff758c), const Color(0xffff7eb3)])
                          : ([Color(0xff93a5cf), const Color(0xff93a5cf)])),
                  borderRadius: isMe
                      ? BorderRadius.only(
                      topLeft: Radius.circular(23),
                      topRight: Radius.circular(23),
                      bottomLeft: Radius.circular(23))
                      : BorderRadius.only(
                      topLeft: Radius.circular(23),
                      topRight: Radius.circular(23),
                      bottomRight: Radius.circular(23))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Flexible(
                    child: imageUrl == null ? Text(
                        message,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        )) : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) => viewImage(imageUrl),
                              ));
                            },
                            child: CachedImage(url: imageUrl,)),
                        message != "" ? Container(

                          padding: EdgeInsets.only(top: 10),
                          child: Text(message,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),),
                        ) : Container(),
                      ],
                    ),
                  ),
                  imageUrl == null ? Container(
                    padding: EdgeInsets.only(left: 10, top: 3, bottom: 0),
                    child: Text(
                      DateFormat('kk:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(time)),
//                      textAlign: TextAlign.right,
                    ),
                  ) : Container(),
                ],
              ),
            ),
          ),
        ));
    return msg;
  }

  Widget viewImage(String url) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.fill,
            )
        ),
      ),
    );
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
                    )
                ),
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(width: 20,),
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
                          contentPadding: EdgeInsets.only(
                              left: 15, top: 20, bottom: 20),
                          fillColor: Colors.white70,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
//                        focusedBorder: UnderlineInputBorder(
//                          borderSide: BorderSide(
//                            color: Colors.white,
//                          )
//                        ),
//                        enabledBorder: UnderlineInputBorder(
//                         borderSide: BorderSide(
//                           color: Colors.white,
//                         )
//                        ),
                        )),
                  ),
                  IconButton(
                    onPressed: () {
                      sendImage(context);
//                      Navigator.pop(context);
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

}
