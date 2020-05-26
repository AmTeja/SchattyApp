import 'package:shared_preferences/shared_preferences.dart';
class HelperFunctions {

  static String sharedPreferenceUserLoggedInKey = "LOGGEDIN";
  static String sharedPreferenceUserNameKey = "KEYUSERNAME";
  static String sharedPreferenceUserEmailKey = "KEYUSEREMAIL";
  static String sharedPreferenceImageURL = "IMAGEURL";

  //Saving data to SharedPreference

  static Future<void> saveUserLoggedInSharedPreference(
      bool isUserLoggedIn) async {
    final SharedPreferences prefers = await SharedPreferences.getInstance();
    return await prefers.setBool(
        sharedPreferenceUserLoggedInKey, isUserLoggedIn);
  }

  static Future<void> saveUserNameSharedPreference(String userName) async {
    final SharedPreferences prefers = await SharedPreferences.getInstance();
    return await prefers.setString(sharedPreferenceUserNameKey, userName);
  }

  static Future<void> saveUserEmailSharedPreference(String userEmail) async {
    final SharedPreferences prefers = await SharedPreferences.getInstance();
    return await prefers.setString(sharedPreferenceUserEmailKey, userEmail);
  }

  static Future<void> saveUserImageURL(String imageURL) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    return await sharedPreferences.setString(
        sharedPreferenceImageURL, imageURL);
  }

  //Getting data from Shared Preference

  static Future<String> getUserImageURL() async {
    final SharedPreferences sharedPreferences = await SharedPreferences
        .getInstance();
    return sharedPreferences.getString(sharedPreferenceImageURL);
  }

  static Future<bool> getUserLoggedInSharedPreference() async {
    final SharedPreferences prefers = await SharedPreferences.getInstance();
    return prefers.getBool(sharedPreferenceUserLoggedInKey);
  }

  static Future<String> getUserNameSharedPreference() async {
    SharedPreferences prefers = await SharedPreferences.getInstance();
    return prefers.getString(sharedPreferenceUserNameKey);
  }

  static Future<String> getUserEmailSharedPreference() async {
    SharedPreferences prefers = await SharedPreferences.getInstance();
    return prefers.getString(sharedPreferenceUserEmailKey);
  }
}
