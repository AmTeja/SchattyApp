import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:schatty/helper/constants.dart';
import 'package:schatty/views/Chatroom/MainChatScreenInstance.dart';
import 'package:schatty/views/Chatroom/Profile.dart';
import 'package:schatty/widgets/widget.dart';

class ChatRoomTile extends StatelessWidget {
  final String username;
  final String chatRoomId;
  final urls;
  final displayNames;
  final lastMessageDetails;
  final lastTime;
  final seenBy;

  const ChatRoomTile(
      {this.username,
      this.chatRoomId,
      this.urls,
      this.displayNames,
      this.lastMessageDetails,
      this.lastTime,
      this.seenBy});

  @override
  Widget build(BuildContext context) {
    String targetUrl;
    String targetDName;
    String lastMessage;
    String lastSentBy;

    bool newDay = true;
    bool targetSeen = true;

    if (lastMessageDetails != null) {
      lastMessage = lastMessageDetails[0] ?? null;
    }

    var timeInDM = DateFormat('dd:M:y')
        .format(DateTime.fromMillisecondsSinceEpoch(lastTime));
    newDay = compareTime(timeInDM);

    if (seenBy != null) {
      targetSeen = seenBy[Constants.ownerName];
    }

    if (urls != null) targetUrl = urls[username];

    if (displayNames != null) {
      targetDName = displayNames[username];
    }

    if (lastMessageDetails[1] == Constants.ownerName.toLowerCase()) {
      lastSentBy = "You";
    } else {
      lastSentBy = lastMessageDetails[1];
    }

    return Slidable(
      key: Key("slidable"),
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => ChatScreen(chatRoomId, username))
          );
        },
        child: Container(
//        color: Colors.white,
          height: 110,
          alignment: Alignment.center,
          child: ListTile(
            trailing: Container(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  targetSeen != null && !targetSeen ? Container(
                    width: 15,
                    height: 15,
                    alignment: Alignment.bottomCenter,
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 126, 217, 241),
                        borderRadius: BorderRadius.circular(23)
                    ),
                  ) : SizedBox(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      !newDay
                          ? DateFormat('kk:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(lastTime))
                          : DateFormat('kk:mm dd/MM/yy').format(
                          DateTime.fromMillisecondsSinceEpoch(lastTime)),
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (context) => TargetUserInfo(username)));
              },
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.indigoAccent,
                child: Container(
                  child: targetUrl != null ? ClipOval(
                    child: CachedNetworkImage(
                      height: 75,
                      width: 75,
                      imageUrl: targetUrl,
                      fit: BoxFit.cover,
                    ),
                  ) : Text("${username.substring(0, 1).toUpperCase()}",),
                ),
                foregroundColor: Colors.white,
              ),
            ),
            title: targetDName == null ? Text(
              '$username', style: TextStyle(fontSize: 20,),)
                : Text('$targetDName', style: TextStyle(fontSize: 20,),),

            subtitle: lastMessage != null && lastMessage != "" ? Text(
                "$lastSentBy: $lastMessage") : null,
          ),
        ),
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Archive',
          color: Colors.black45,
          icon: Icons.archive,
          onTap: () {},
        ),
        IconSlideAction(
          caption: 'Info',
          color: Color(0xff509ece),
          icon: Icons.info,
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(
                    builder: (context) => TargetUserInfo(username)));
          },
        ),
      ],
    );
  }
}
