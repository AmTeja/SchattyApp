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
    // TODO: implement initState
    var userName = (HelperFunctions.getUserNameSharedPreference());
    databaseMethods.getMessage(widget.chatRoomID).then((val) {
      setState(() {
        chatMessageStream = val;
      });
    });
    super.initState();
  }

  Future<String> getDataFromFuture(String message) async {
    return await getDecryptedText(message);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Scaffold(
            appBar: AppBar(title: Text("Chats")),
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
                                      return buildMessage(
                                          snapshot.data.documents[index]
                                              .data["message"],
                                          snapshot.data.documents[index]
                                                  .data["sendBy"] ==
                                              Constants.ownerName);
                                    },
                                  )
                                : Container();
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
      keyPair = await futureKeyPair;
      String encryptedText = encrypt(messageTEC.text, keyPair.publicKey);
      Map<String, String> messageMap = {
        "message": encryptedText,
        "sendBy": Constants.ownerName,
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

  buildMessage(String message, bool isMe) {
    String decryptedText;
    getDecryptedText(message).then((val) {
      decryptedText = val;
    });
    final Widget msg = Padding(
      padding: EdgeInsets.all(8),
      child: Container(
        margin: isMe
            ? EdgeInsets.only(top: 8, bottom: 8, left: 80)
            : EdgeInsets.only(top: 8, bottom: 8, right: 80),
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        width: MediaQuery.of(context).size.width * 0.75,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: isMe
                    ? [const Color(0xffff758c), const Color(0xffff7eb3)]
                    : [const Color(0xff93a5cf), const Color(0xff93a5cf)]),
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(15))
                : BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FutureBuilder(
                future: getDataFromFuture(message),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Text(
                      decryptedText,
                      style: TextStyle(
                        color: isMe ? Colors.white60 : Colors.blueGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }
                  return CircularProgressIndicator();
                })
          ],
        ),
      ),
    );
    return msg;
  }
}
