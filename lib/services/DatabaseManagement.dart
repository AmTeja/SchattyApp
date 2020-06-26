import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:schatty/helper/preferencefunctions.dart';
import 'package:schatty/model/user.dart';
import 'package:schatty/services/AuthenticationManagement.dart';

class DatabaseMethods {
  getUserByUserName(String username) async {
    await Firestore.instance
        .collection("users")
        .where("username", isEqualTo: username)
        .getDocuments()
        .then((value) {
      if (value.documents.length <= 0) {
        return null;
      } else {
        return value.documents.length;
      }
    });
  }

  updateToken(String token) async {
    final AuthMethods authMethods = new AuthMethods();
    try {
      String uid = await authMethods.getUserUID();
      Map<String, String> tokenMap = {
        "token": token,
      };
      await Firestore.instance
          .collection("users")
          .where("uid", isEqualTo: uid)
          .getDocuments()
          .then((docs) async {
        await Firestore.instance
            .document("users/${docs.documents[0].documentID}")
            .updateData(tokenMap);
      });
    } catch (e) {
      print(e);
    }
  }

  getUserByUserEmail(String email) async {
    return await Firestore.instance
        .collection("users")
        .where("email", isEqualTo: email)
        .getDocuments();
  }

  getEmailByUsername(String username) async {}

  uploadUserInfo(userMap, String uid) {
    Firestore.instance
        .collection("users")
        .document(uid)
        .setData(userMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  createChatRoom(String chatRoomID, chatRoomMap) {
    Firestore.instance
        .collection("ChatRoom")
        .document(chatRoomID)
        .setData(chatRoomMap)
        .catchError((e) {
      print("CreateChatRoom: $e");
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
    Map<String, String> imageMap = {'photoURL': userInfo.profileImageUrl};

    await Preferences.saveUserImageURL(picUrl);
    await FirebaseAuth.instance.currentUser().then((user) async {
      await Firestore.instance
          .collection('/users')
          .where('uid', isEqualTo: user.uid)
          .getDocuments()
          .then((docs) async {
        Firestore.instance
            .document('/users/${docs.documents[0].documentID}')
            .updateData(imageMap)
            .whenComplete(() {})
            .catchError((onError) {
          print(onError);
        }).catchError((onError) {
          print(onError);
        });
      });
    });
  }

  getProfileUrl() async {
    String url;
    String uid;
    await FirebaseAuth.instance.currentUser().then((user) {
      uid = user.uid;
    });

    await Firestore.instance.collection('users')
        .where('uid', isEqualTo: uid)
        .getDocuments()
        .then((value) async {
      url = await value.documents[0].data["photoURL"];
//        length = await value.documents.length;
      await Preferences.saveUserImageURL(url);
    }).catchError((e) {
      print("URL ERROR: $e");
    });
    return url;
  }

  updateChatRoomTime(chatRoomID, timeMap) async {
    await Firestore.instance
        .collection("ChatRoom")
        .document(chatRoomID)
        .updateData(timeMap)
        .catchError((onError) {
      print("ChatRoomTime: $onError");
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
          .orderBy("lastTime", descending: true)
          .where("users", arrayContains: userName)
          .snapshots();
    } catch (e) {
      print("GetChatRooms: $e");
    }
  }

  getUIDByUsername(String username) async
  {
    String uid;
    try {
      await Firestore.instance.collection("users").where(
          "username", isEqualTo: username)
          .getDocuments().then((docs) async {
        uid = docs.documents[0].data["uid"];
        print(docs.documents[0].data["uid"]);
        return uid;
      });
    } catch (e) {
      print(e);
    }
  }

}
