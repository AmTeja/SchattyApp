import 'package:shared_preferences/shared_preferences.dart';
class Preferences {
  static String sharedPreferenceUserLoggedInKey = "LOGGEDIN";
  static String sharedPreferenceUserNameKey = "KEYUSERNAME";
  static String sharedPreferenceUserEmailKey = "KEYUSEREMAIL";
  static String sharedPreferenceImageURL = "IMAGEURL";
  static String isGoogleUser = "GOOGLEUSER";
  static const themePreference = "THEMESTATUS";

  //Saving data to SharedPreference

  static Future<void> saveIsGoogleUser(bool googleUser) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    return await sharedPreferences.setBool(isGoogleUser, googleUser);
  }

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

  static saveThemePreference(bool value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool(themePreference, value);
  }

  //Getting data from Shared Preference

  static Future<bool> getIsGoogleUser() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool(isGoogleUser);
  }

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

  static Future<bool> getThemePreference() async {
    SharedPreferences prefers = await SharedPreferences.getInstance();
    return prefers.getBool(themePreference) ?? false;
  }
}
