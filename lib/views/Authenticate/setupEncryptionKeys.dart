import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:schatty/services/encryptionservice.dart';
import 'file:///C:/Users/Dell/AndroidStudioProjects/schatty/lib/views/Chatroom/MainChatsRoom.dart';
import 'package:schatty/widgets/widget.dart';

class SetupEncryption extends StatefulWidget {
  @override
  _SetupEncryptionState createState() => _SetupEncryptionState();
}

class _SetupEncryptionState extends State<SetupEncryption> {
  EncryptionService encryptionService = new EncryptionService();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  Firestore firestore = Firestore.instance;

  String uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black, body: loadingScreen("Setting up"));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setup();
  }

  setup() async {
    await firebaseAuth.currentUser().then((user) {
      uid = user.uid;
    });

    try {
      await firestore
          .collection('users')
          .where('uid', isEqualTo: uid)
          .getDocuments()
          .then((docs) async {
        if (docs.documents[0].data['privateKey'] == null) {
          encryptionService.futureKeyPair = encryptionService.getKeyPair();
          encryptionService.keyPair = await encryptionService.futureKeyPair;

          Map<dynamic, dynamic> keyPairMap = {
            "privateKey": encryptionService.keyPair.privateKey
          };
          await firestore
              .document('/users/${docs.documents[0].documentID}')
              .updateData(keyPairMap);
          print("Updated Key");
          setState(() {});
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ChatRoom()));
        } else {
          print("its has 0_0");
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatRoom(),
              ));
        }
      });
    } catch (e) {
      print("Error In Setup: $e");
    }
  }
}
