import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  getUserByUserName(String username) async {
    return await Firestore.instance
        .collection("users")
        .where("username", isEqualTo: username)
        .getDocuments();
  }

  getUserByUserEmail(String email) async {
    return await Firestore.instance
        .collection("users")
        .where("email", isEqualTo: email)
        .getDocuments();
  }

  uploadUserInfo(userMap) {
    Firestore.instance.collection("users").add(userMap).catchError((e) {
      print(e.toString());
    });
  }

  createChatRoom(String chatRoomID, chatRoomMap) {
    Firestore.instance
        .collection("ChatRoom")
        .document(chatRoomID)
        .setData(chatRoomMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  addMessage(String chatRoomID, messageMap) {
    Firestore.instance.collection("ChatRoom")
        .document(chatRoomID)
        .collection("chats")
        .add(messageMap).catchError((e) {
      print(e.toString());
    });
  }

  getMessage(String chatRoomID) async {
    return await Firestore.instance.collection("ChatRoom")
        .document(chatRoomID).collection("chats").orderBy(
        "time", descending: false).snapshots();
  }

  getChatRooms(String userName) async
  {
    return await Firestore.instance.collection("ChatRoom")
        .where("users", arrayContains: userName).snapshots();
  }
}
