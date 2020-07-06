import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:schatty/helper/constants.dart';
import 'package:schatty/helper/preferencefunctions.dart';
import 'package:schatty/model/user.dart';
import 'package:schatty/services/AuthenticationManagement.dart';

class DatabaseMethods {
  FirebaseAuth auth = FirebaseAuth.instance;

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

  updateToken(String token, String userName) async {
    final AuthMethods authMethods = new AuthMethods();
    try {
      String uid = await authMethods.getUserUID();
      Map<String, String> tokenMap = {
        "token": token,
        "uid": uid,
        "username": userName,
      };
      await Firestore.instance
          .collection("tokens")
          .document(uid)
          .setData(tokenMap);
    } catch (e) {
      print("ERROR Updating Token: $e");
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
    Firestore.instance
        .collection("ChatRoom")
        .document(chatRoomID)
        .collection("chats")
        .add(messageMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  updateDisplayName(String displayName) async {
    try {
      Map<String, dynamic> dNMap = {
        "displayName": displayName,
      };
      FirebaseUser user = await auth.currentUser();
      String uid = user.uid;
      Firestore.instance
          .collection('users')
          .where("uid", isEqualTo: uid)
          .getDocuments()
          .then((docs) async {
        Firestore.instance
            .document('users/${docs.documents[0].documentID}')
            .updateData(dNMap);
      });
    } catch (error) {
      print("ERROR UPDATING DNAME: $error");
    }
  }

  getDName(String userName) async {
    String dName;
    String uid;
    uid = await getUIDByUsername(userName);
    await Firestore.instance
        .collection('users')
        .where("uid", isEqualTo: uid)
        .getDocuments()
        .then((docs) async {
      dName = await docs.documents[0].data["displayName"];
    }).catchError((error) {
      print("ERROR GETTING DNAME: $error");
    });
    return dName;
  }

  updateProfilePicture(String picUrl, String userName) async {
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

  getProfileUrl(String username) async {
    String url;
    await Firestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
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

  updateChatRoomTime(String chatRoomID) async {
    Map<String, dynamic> timeMap = {
      "lastTime": DateTime.now().millisecondsSinceEpoch,
    };
    await Firestore.instance
        .collection("ChatRoom")
        .document(chatRoomID)
        .updateData(timeMap)
        .catchError((onError) {
      print("ChatRoomTime: $onError");
    });
  }

  getMessage(String chatRoomID) async {
    return Firestore.instance
        .collection("ChatRoom")
        .document(chatRoomID)
        .collection("chats")
        .orderBy("time", descending: true)
        .snapshots();
  }

  getChatRooms(String userName) async {
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

  getUIDByUsername(String username) async {
    String uid;
    try {
      await Firestore.instance
          .collection("users")
          .where("username", isEqualTo: username)
          .getDocuments()
          .then((docs) async {
        uid = docs.documents[0].data["uid"];
      });
      return uid;
    } catch (e) {
      print(e);
    }
  }

  updateLastMessage(String message, String chatRoomId) async
  {
    List<String> messageMap = [message, Constants.ownerName.toLowerCase()];
    Map<String, dynamic> lastMessageMap = {
      "lastMessage": messageMap,
    };
    await Firestore.instance
        .collection("ChatRoom")
        .document(chatRoomId)
        .updateData(lastMessageMap)
        .catchError((onError) {
      print("ChatRoomTime: $onError");
    });
  }

}
