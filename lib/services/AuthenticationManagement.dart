import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:schatty/model/user.dart';

class AuthMethods {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();
  User _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(userId: user.uid) : null;
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser firebaseUser = result.user;

      if (firebaseUser.isEmailVerified) {
        return _userFromFirebaseUser(firebaseUser);
      } else {
        return null;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future signUpWithEmailAndPassword(String email, String password) async {
    try{
      AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      FirebaseUser firebaseUser = result.user;
      try {
        await firebaseUser.sendEmailVerification();
      }
      catch (e) {
        print("An error has occured while trying to send email verification.");
        print(e.toString());
      }
      return _userFromFirebaseUser(firebaseUser);
    }catch(e)
    {
      print(e.toString());
    }
  }

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
