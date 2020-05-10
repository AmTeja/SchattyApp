import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  getUserByUserName(String username) async {
    return await Firestore.instance
        .collection("users")
        .where("username", isEqualTo: username)
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
}
