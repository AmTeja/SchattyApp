import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:schatty/enums/globalcolors.dart';
import 'package:schatty/helper/NavigationService.dart';
import 'package:schatty/helper/preferencefunctions.dart';
import 'package:schatty/provider/DarkThemeProvider.dart';
import 'package:schatty/provider/image_upload_provider.dart';
import 'package:schatty/views/Authenticate/AuthHome.dart';
import 'package:schatty/views/Authenticate/StartScreen.dart';
import 'package:schatty/views/MainChatsRoom.dart';

void main() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  runApp(MyApp());
  //  SystemChrome.setEnabledSystemUIOverlays([]);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  NavigationService navigationService = new NavigationService();
  DarkThemeProvider themeChangeProvider = new DarkThemeProvider();
  bool isUserLoggedIn = false;

  @override
  void initState() {
    getState();
    getThemePreference();
    super.initState();
  }

  getThemePreference() async {
    themeChangeProvider.darkTheme = await Preferences.getThemePreference();
  }

  getState() async {
    await Preferences.getUserLoggedInSharedPreference().then((value) {
      setState(() {
        isUserLoggedIn = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ImageUploadProvider>(
          create: (context) => ImageUploadProvider(),
        ),
        ChangeNotifierProvider<DarkThemeProvider>(
          create: (_) {
            return themeChangeProvider;
          },
        )
      ],
      child: Consumer<DarkThemeProvider>(
        builder: (BuildContext context, value, Widget child) {
          return MaterialApp(
            routes: {
              '/ChatsRoom': (context) => ChatRoom(),
            },
            title: 'Schatty',
            navigatorKey: navigationService.navigatorKey,
            debugShowCheckedModeBanner: false,
            theme:
                GlobalColors.themeData(themeChangeProvider.darkTheme, context),
            home: isUserLoggedIn != null
                ? (isUserLoggedIn ? ChatRoom() : AuthHome())
                : StartScreen(),
          );
        },
      ),
    );
  }
}
