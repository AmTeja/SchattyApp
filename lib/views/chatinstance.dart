import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schatty/helper/constants.dart';
import 'package:schatty/services/database.dart';
import 'package:schatty/widgets/widget.dart';

class ChatInstance extends StatefulWidget {
  final String chatRoomID;

  ChatInstance(this.chatRoomID);

  @override
  _ChatInstanceState createState() => _ChatInstanceState();
}

class _ChatInstanceState extends State<ChatInstance> {
  DatabaseMethods databaseMethods = new DatabaseMethods();

  TextEditingController messageTEC = TextEditingController();

  Stream chatMessageStream;

  Widget chatMessageList() {
    return StreamBuilder(
      stream: chatMessageStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
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

  sendMessage() {
    print("function called");
    if (messageTEC.text.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        "message": messageTEC.text,
        "sendBy": Constants.ownerName,
        "time": DateTime.now().millisecondsSinceEpoch
      };
      databaseMethods.addMessage(widget.chatRoomID, messageMap);
      messageTEC.text = "";
    }
  }

  @override
  void initState() {
    databaseMethods.getMessage(widget.chatRoomID).then((value) {
      setState(() {
        chatMessageStream = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      //backgroundColor: Colors.white,
      body: Container(
        child: Stack(
          children: [
            chatMessageList(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Color(0x54FFFFFF),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: messageTEC,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                          hintText: "Say Something",
                          hintStyle: TextStyle(
                            color: Colors.white54,
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
                                const Color(0x36FFFFFF),
                                const Color(0x0fffffff)
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
    );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool isSentByOwner;

  MessageTile(this.message, this.isSentByOwner);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          left: isSentByOwner ? 0 : 18, right: isSentByOwner ? 18 : 0),
      margin: EdgeInsets.symmetric(vertical: 8),
      width: MediaQuery.of(context).size.width,
      alignment: isSentByOwner ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: isSentByOwner
                    ? [const Color(0xff007EF4), const Color(0xff2A75BC)]
                    : [const Color(0xFF000000), const Color(0xFF000000)]),
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
          message,
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
      ),
    );
  }
}
