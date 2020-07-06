import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:schatty/helper/constants.dart';
import 'file:///C:/Users/Dell/AndroidStudioProjects/schatty/lib/views/Chatroom/MainChatScreenInstance.dart';
import 'file:///C:/Users/Dell/AndroidStudioProjects/schatty/lib/views/Chatroom/TargetUserInfo.dart';
import 'package:schatty/widgets/widget.dart';

class ChatRoomTile extends StatelessWidget {
  final String username;
  final String chatRoomId;
  final urls;
  final users;
  final displayNames;
  final lastMessageDetails;
  final lastTime;

  ChatRoomTile(this.username, this.chatRoomId, this.urls, this.users,
      this.displayNames, this.lastMessageDetails, this.lastTime);

  @override
  Widget build(BuildContext context) {
    String targetUrl;
    String targetDName;
    String lastMessage = lastMessageDetails[0];
    String lastSentBy;
    bool newMessage = false;
    bool newDay = true;

    var timeInDM =
    DateFormat('dd:M:y').format(DateTime.fromMillisecondsSinceEpoch(lastTime));
    newDay = compareTime(timeInDM);

    if (users[1] == username) {
      targetUrl = urls[1];
      targetDName = displayNames[1];
    } else {
      targetUrl = urls[0];
      targetDName = displayNames[0];
    }

    if (lastMessageDetails[1] == Constants.ownerName.toLowerCase()) {
      lastSentBy = "You";
    }
    else {
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
            trailing: newMessage ? Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(43),
                  ),
                ),
                Text(
                  !newDay
                      ? DateFormat('kk:mm').format(
                      DateTime.fromMillisecondsSinceEpoch(lastTime))
                      : DateFormat('kk:mm dd/M').format(
                      DateTime.fromMillisecondsSinceEpoch(lastTime)),
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ) : Container(
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
            title: targetDName == null ? Text('$username',
              style: TextStyle(
                fontSize: 20,
              ),) : Text('$targetDName', style: TextStyle(
              fontSize: 20,
            ),),
            subtitle: Text("$lastSentBy: $lastMessage"),
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
