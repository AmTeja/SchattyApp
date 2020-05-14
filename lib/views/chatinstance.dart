import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';
import 'package:schatty/helper/constants.dart';
import 'package:schatty/helper/helperfunctions.dart';
import 'package:schatty/services/RSAEncryption.dart';
import 'package:schatty/services/database.dart';
import 'package:schatty/widgets/widget.dart';

class ChatInstance extends StatefulWidget {
  final String chatRoomID;
  final String userName;

  ChatInstance(this.chatRoomID, this.userName);

  @override
  _ChatInstanceState createState() => _ChatInstanceState();
}

class _ChatInstanceState extends State<ChatInstance> {

  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController messageTEC = TextEditingController();

  Stream chatMessageStream;
  RsaKeyHelper rsaKeyHelper = RsaKeyHelper();

  //Chat Stream Widget
  Widget chatMessageList() {
    return StreamBuilder(
      stream: chatMessageStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  print(snapshot.data.documents[index].data["message"]
                      .toString());
                  return MessageTile(
                      snapshot.data.documents[index].data["message"],
                      snapshot.data.documents[index].data["sendBy"] ==
                          Constants.ownerName);
                },
              )
            : Container();
      },
    );
  }


  //Send Message and Upload to Firebase
  sendMessage() async {
    print("function called");
    if (messageTEC.text.isNotEmpty) {
      keyPair = await futureKeyPair;
      String message = encrypt(messageTEC.text, keyPair.publicKey);
      Map<String, dynamic> messageMap = {
        "message": message,
        "sendBy": Constants.ownerName,
        "time": DateTime.now().millisecondsSinceEpoch
      };
      databaseMethods.addMessage(widget.chatRoomID, messageMap);
      messageTEC.text = "";
    }
  }

  //Initstate to get message from Firebase
  @override
  void initState() {
    var userName = (HelperFunctions.getUserNameSharedPreference().then((
        value) => print(value)));
    databaseMethods.getMessage(widget.chatRoomID).then((value) {
      setState(() {
        chatMessageStream = value;
      });
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xfffdfbfb), Color(0xffebedee)]
          )
      ),
      child: Scaffold(
        appBar: appBarMain(context),
        backgroundColor: Colors.transparent,
        body:
        Container(
          child: Stack(
            children: [
              chatMessageList(),
              Container(
                alignment: Alignment.bottomCenter,
                child: Container(
                  color: Colors.black54,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                          child: TextField(
                            controller: messageTEC,
                            style: TextStyle(
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                                hintText: "Say Something",
                                hintStyle: TextStyle(
                                  color: Colors.black38,
                                ),
                                border: InputBorder.none),
                          )),
                      GestureDetector(
                        onTap: () {
                          sendMessage();
                        },
                        child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  const Color(0x44FFFFFF),
                                  const Color(0x55ffffff)
                                ]),
                                borderRadius: BorderRadius.circular(40)),
                            padding: EdgeInsets.all(12),
                            child: Image.asset("assets/images/send.png")),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<String> getDecryptText(String decryptText) async {
  keyPair = await futureKeyPair;
  final text = await decrypt(decryptText, keyPair.privateKey);
  return text;
}
class MessageTile extends StatelessWidget {
  final String
  message;
  final bool isSentByOwner;

  MessageTile(this.message, this.isSentByOwner);

  @override
  Widget build(BuildContext context) {
    String decryptedMessage;
    return Container(
      padding: EdgeInsets.only(
          left: isSentByOwner ? 0 : 18, right: isSentByOwner ? 18 : 0),
      margin: EdgeInsets.symmetric(vertical: 8),
      width: MediaQuery.of(context).size.width,
      alignment: isSentByOwner ? Alignment.centerRight : Alignment.centerLeft,
      child: FutureBuilder(
          future: getDecryptText(message).then((value) =>
          decryptedMessage = value),
          builder: (context, snapshot) {
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: isSentByOwner
                          ? [const Color(0xffff758c), const Color(0xffff7eb3)]
                          : [Color(0xff93a5cf), const Color(0xff93a5cf)]),
                  borderRadius: isSentByOwner
                      ? BorderRadius.only(
                      topLeft: Radius.circular(23),
                      topRight: Radius.circular(23),
                      bottomLeft: Radius.circular(23))
                      : BorderRadius.only(
                      topLeft: Radius.circular(23),
                      topRight: Radius.circular(23),
                      bottomRight: Radius.circular(23))),
              child: Text(
                decryptedMessage != null ? decryptedMessage : "null",
                style: TextStyle(color: Colors.white, fontSize: 17),
              ),
            );
            return Text(decryptedMessage);
          }
      ),
    );
  }
}
