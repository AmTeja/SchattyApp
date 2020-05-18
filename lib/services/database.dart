import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:schatty/model/user.dart';

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


  Future addImagePathToDatabase(String url) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseUser user = await auth.currentUser();
    final uid = user.uid;
    Map<String, dynamic> pathMap = {
      "imagePath": url
    };
    await Firestore.instance.collection("imageURLs")
        .document(uid).setData(pathMap).catchError((e) {
      print(e.toString());
    });
  }

  Future getImageURLSnapShot() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseUser user = await auth.currentUser();
    final uid = user.uid;
    final snap = await Firestore.instance.collection("imageURLs")
        .document(uid)
        .get();
    if (snap.exists) {
      return snap.data["imagePath"];
    }
    else {
      return null;
    }
  }

  updateProfilePicture(picUrl) async {
    var userInfo = User();
    userInfo.profileImageUrl = picUrl;
  }

  getMessage(String chatRoomID) async {
    return Firestore.instance.collection("ChatRoom")
        .document(chatRoomID)
        .collection("chats")
        .orderBy("time", descending: true)
        .snapshots();
  }

  getChatRooms(String userName) async
  {
    return Firestore.instance.collection("ChatRoom")
        .where("users", arrayContains: userName).snapshots();
  }


}
