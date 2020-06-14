import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schatty/services/DatabaseManagement.dart';

class GetPhotoURL {
  final DatabaseMethods databaseMethods = new DatabaseMethods();

  Future<String> fetchTargetURL(String username) async {
    String targetUrl;
    try {
      await Firestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .getDocuments()
          .then((docs) async {
        targetUrl = docs.documents[0].data["photoURL"];
        return targetUrl;
      });
//      return targetUrl;
    } catch (e) {
      print("Error Fetching URL: $e");
    }
    return targetUrl;
  }
}
