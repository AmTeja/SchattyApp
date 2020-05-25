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

  updateProfilePicture(String picUrl) async {
    var userInfo = User();
    userInfo.profileImageUrl = picUrl;
//    print(userInfo.profileImageUrl);
    Map<String, String> imageMap = {
      'photoURL': userInfo.profileImageUrl
    };

    await FirebaseAuth.instance.currentUser().then((user) async {
      await Firestore.instance
          .collection('/users')
          .where('uid', isEqualTo: user.uid)
          .getDocuments()
          .then((docs) {
        Firestore.instance
            .document('/users/${docs.documents[0].documentID}')
            .updateData(imageMap).whenComplete(() {
          print('Updated');
        }).catchError((onError) {
          print(onError);
        }).catchError((onError) {
          print(onError);
        });
      });
    });
  }

  getProfileUrl() async {
    String url;
    int length;
    String uid;
    await FirebaseAuth.instance.currentUser().then((user) {
      uid = user.uid;
      print(uid);
    });

    await Firestore.instance.collection('users')
        .where('uid', isEqualTo: uid)
        .getDocuments()
        .then((value) async {
      url = await value.documents[0].data["photoURL"];
//        length = await value.documents.length;
      print(length);
    }).catchError((e) {
      print(e);
    });
    return url;
  }

  updateChatRoomTime(chatRoomID, timeMap) async {
    print('Called');
    await Firestore.instance
        .collection("ChatRoom")
        .document(chatRoomID)
        .updateData(timeMap)
        .catchError((onError) {
      print(onError);
    });
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
    try {
      return Firestore.instance
          .collection("ChatRoom")
          .where("users", arrayContains: userName)
          .orderBy("time", descending: true)
          .snapshots();
    } catch (e) {
      print(e);
    }
  }


}
