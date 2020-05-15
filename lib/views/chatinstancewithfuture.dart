import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';
import 'package:schatty/helper/constants.dart';
import 'package:schatty/helper/helperfunctions.dart';
import 'package:schatty/services/RSAEncryption.dart';
import 'package:schatty/services/database.dart';

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

  @override
  void initState() {
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
            appBar: AppBar(title: Text(chatWith)),
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
      color: Colors.white,
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
            fillColor: Theme.of(context).primaryColor,
            padding: EdgeInsets.all(5),
          ),
          Expanded(
            child: TextField(
              controller: messageTEC,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) {},
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
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
//      keyPair = await futureKeyPair;
//      String encryptedText = encrypt(messageTEC.text, keyPair.publicKey);
      Map<String, dynamic> messageMap = {
        "message": messageTEC.text,
        "sendBy": Constants.ownerName,
        "time": DateTime
            .now()
            .millisecondsSinceEpoch,
      };
      databaseMethods.addMessage(widget.chatRoomID, messageMap);
      messageTEC.text = "";
    }
  }

  getDecryptedText(String encryptedText) async {
    keyPair = await futureKeyPair;
    String decrypted;
    decrypted = decrypt(encryptedText, keyPair.privateKey);
    print(decrypted);
    return decrypted;
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