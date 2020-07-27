import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthMethods {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();

//  User _userFromFirebaseUser(FirebaseUser user) {
//    return user != null ? User(userId: user.uid) : null;
//  }

  Future resetPass(String email) async
  {
    try{
      return await _auth.sendPasswordResetEmail(email: email);
    }catch(e) {
      print(e.toString());
    }
  }

  Future signOut() async
  {
    try{
      return await _auth.signOut();
    }catch(e) {
      print(e.toString());
    }
  }

  // ignore: missing_return
  Future<String> signInWithGoogle() async {

  }

  getUserUID() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseUser user = await auth.currentUser();
    final uid = user.uid;
    return uid;
  }

  updateUID(String username) async {
    String uid;
    try {
      uid = await getUserUID();
      if (uid != null) {
        Map<String, String> uidMap = {
          "uid": uid,
        };
        await Firestore.instance
            .collection("users")
            .where("username", isEqualTo: username)
            .getDocuments()
            .then((docs) async {
          await Firestore.instance
              .document("users/${docs.documents[0].documentID}")
              .updateData(uidMap);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void signOutGoogle() async {
    await googleSignIn.disconnect();
    print("User Signed Out");
  }
}

class EmailValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return "Email cannot be empty";
    }
    return null;
  }
}

class TagValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return ("Tag cannot be empty");
    }
    if (value.length < 3 || value.length > 12) {
      return ("Tag length must be between 2 and 13");
    }
    return null;
  }
}

class UserNameValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return "Username cannot be empty";
    }
    if (value.length < 5) {
      return "Username must be at least 5 chars long";
    }
    if (value.length > 15) {
      return "Username must be less than 15 chars long";
    }
    return RegExp(r"^[a-zA-Z0-9_]+([_]?[a-zA-Z0-9])*$").hasMatch(value)
        ? null
        : "Username can contain only alphanumeric and underscore";
  }
}

class NameValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return "Name cannot be empty";
    }
    if (value.length < 5) {
      return "Name must be at least 5 chars long";
    }
    if (value.length > 20) {
      return "Name must be less than 20 chars long";
    }
    return null;
  }
}

class PasswordValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return "Password cannot be empty";
    }
    return null;
  }
}

class TitleValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return "Title can't be empty";
    }
    return null;
  }
}

class UrlValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return "Url cannot be empty!";
    }
    return RegExp(
                r"https?:\/\/(www\.)?[-a-zA-Z0-9@:%.,_\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\,+.~#?&//=]*)")
            .hasMatch(value)
        ? null
        : "Invalid url";
  }
}