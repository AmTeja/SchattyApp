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
    }catch(e)
    {
      print(e.toString());
    }
  }

  Future signOut() async
  {
    try{
      return await _auth.signOut();
    }catch(e)
    {
      print(e.toString());
    }
  }

  // ignore: missing_return
  Future<String> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential authCredential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      final AuthResult authResult =
          await _auth.signInWithCredential(authCredential);
      final FirebaseUser user = authResult.user;

      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);

      return 'signInWithGoogle succeeded: $user';
    } catch (e) {
      //print(e.toString());
    }
  }

  getUserUID() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseUser user = await auth.currentUser();
    final uid = user.uid;
    return uid;
  }

  void signOutGoogle() async {
    await googleSignIn.signOut();
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

class NameValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return "Username cannot be empty";
    }
    if (value.length < 5) {
      return "Username must be at least 5 chars long";
    }
    if (value.length > 20) {
      return "Username must be less than 20 chars long";
    }
    return RegExp(r"^[a-zA-Z0-9_]+([_]?[a-zA-Z0-9])*$").hasMatch(value)
        ? null
        : "Username can contain only alphanumeric and underscore";
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