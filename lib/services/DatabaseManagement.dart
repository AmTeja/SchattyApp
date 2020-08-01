import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:schatty/helper/constants.dart';
import 'package:schatty/helper/preferencefunctions.dart';
import 'package:schatty/model/user.dart';

class DatabaseMethods {
  FirebaseAuth auth = FirebaseAuth.instance;

  getUserByUserName(String username) async {
    await Firestore.instance
        .collection("users")
        .where("username", isEqualTo: username.toLowerCase())
        .getDocuments()
        .then((value) {
      if (value.documents.length <= 0) {
        return null;
      } else {
        return value.documents.length;
      }
    });
  }

  updateToken(String token, String uid) async {
    try {
      Map<String, String> tokenMap = {
        "token": token,
        "uid": uid,
        "username": Constants.ownerName.toLowerCase(),
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

  createChatRoom(String chatRoomID, Map chatRoomMap, String targetUsername) {
    Firestore.instance
        .collection("ChatRoom")
        .where('chatRoomId', isEqualTo: chatRoomID)
        .getDocuments()
        .then((docs) {
      if (docs.documents.length != 0) {
        print("docs available");
        chatRoomMap["archivedUsers.${Constants.ownerName}"] = false;
        Firestore.instance
            .collection("ChatRoom")
            .document(chatRoomID)
            .updateData(chatRoomMap)
            .catchError((e) {
          print("Update ChatRoom: $e");
        });
      } else {
        chatRoomMap["lastMessage"] = ["", ""];
        Map<String, dynamic> otherMap = {
          Constants.ownerName: false,
          "$targetUsername": false
        };
        chatRoomMap["archivedUsers"] = otherMap;
        Firestore.instance
            .collection("ChatRoom")
            .document(chatRoomID)
            .setData(chatRoomMap)
            .catchError((e) {
          print("CreateChatRoom: $e");
        });
      }
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

  updateDisplayName(String displayName, String username) async {
    try {
      Map<String, dynamic> dNMap = {
        "displayName": displayName,
      };
      Map<String, dynamic> dNMapForChat = {
        "displayNames.$username": displayName
      };
      FirebaseUser user = await auth.currentUser();
      await Firestore.instance
          .collection('/users')
          .where('uid', isEqualTo: user.uid)
          .getDocuments()
          .then((docs) async {
        Firestore.instance
            .document('/users/${docs.documents[0].documentID}')
            .updateData(dNMap)
            .whenComplete(() {})
            .catchError((onError) {
          print(onError);
        }).catchError((onError) {
          print(onError);
        });
      });
      updateChatRooms(dNMapForChat, username);
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

  updateChatRooms(Map map, String username) async {
    try {
      await Firestore.instance.collection('ChatRoom').where(
          'users', arrayContains: username)
          .getDocuments().then((docs) {
        for (int i = 0; i < docs.documents.length; i++) {
          Firestore.instance.collection('ChatRoom').document(
              docs.documents[i].documentID)
              .updateData(map);
        }
      });
    } catch (err) {
      print("Error updating chatroom maps: $err");
    }
  }


  updateProfilePicture(String picUrl, String userName) async {
    var userInfo = User();
    userInfo.profileImageUrl = picUrl;

    Map<String, String> imageMap = {'photoURL': userInfo.profileImageUrl};
    Map<String, dynamic> forChatroom = {'photoUrls.$userName': picUrl};
    await Preferences.saveUserImageURL(picUrl);

    await FirebaseAuth.instance.currentUser().then((user) async
    {
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
    updateChatRooms(forChatroom, userName);
  }

  getProfileUrlByName(String username) async {
    String url;
    await Firestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .getDocuments()
        .then((value) async {
      url = await value.documents[0].data["photoURL"];
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

  getMessage(String chatRoomID, int limit) async {
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

  updateLastMessage(String message, String chatRoomId,
      String targetUsername) async
  {
    List<String> messageMap = [message, Constants.ownerName.toLowerCase()];
    Map<String, dynamic> lastMessageMap = {
      "lastMessage": messageMap,
      "seenBy.$targetUsername": false,
      "lastTime": DateTime
          .now()
          .millisecondsSinceEpoch,
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
