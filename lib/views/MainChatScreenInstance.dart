import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schatty/helper/constants.dart';
import 'package:schatty/helper/preferencefunctions.dart';
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
  final TextEditingController messageTEC = TextEditingController();

  DatabaseMethods databaseMethods = new DatabaseMethods();
  Stream chatMessageStream;

  DateTime lastAccessedTime;

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
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Scaffold(
            backgroundColor: Color.fromARGB(255, 14, 14, 14),
            appBar: AppBar(
              title: Text(chatWith),
              backgroundColor: Colors.black,
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.info),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserInfo(chatWith)));
                  },
                )
              ],
            ),
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: StreamBuilder(
                          stream: chatMessageStream,
                          builder: (context, snapshot) {
                            return snapshot.hasData
                                ? ListView.builder(
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
                                            .data["time"]);
                                }) : Container();
                          }),
                    ),
                  ),
                  buildMessageComposer(),
                ],
              ),
            )),
      ),
    );
  }

  buildMessageComposer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      height: 70,
      color: Colors.black,
      child: Row(
        children: <Widget>[
          RawMaterialButton(

            onPressed: () {},
            child: Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 25,
            ),
            shape: CircleBorder(),
            elevation: 2,
            fillColor: Colors.black54,
            padding: EdgeInsets.only(right: 10),
          ),
          Expanded(
            child: TextField(
              controller: messageTEC,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) {},
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
      };
      databaseMethods.addMessage(widget.chatRoomID, messageMap);
      messageTEC.text = "";
      Map<String, dynamic> timeMap = {
        "time": DateTime.now().millisecondsSinceEpoch,
      };
      databaseMethods.updateChatRoomTime(widget.chatRoomID, timeMap);
    }
  }


  buildMessage(String message, bool isMe, int time) {
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
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: isMe
                        ? [const Color(0xffff758c), const Color(0xffff7eb3)]
                        : [Color(0xff93a5cf), const Color(0xff93a5cf)]),
                borderRadius: isMe
                    ? BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomLeft: Radius.circular(23))
                    : BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomRight: Radius.circular(23))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                    Text(
                        message,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        )),
          ],
        ),
      ),
        ));
    return msg;
  }
}
