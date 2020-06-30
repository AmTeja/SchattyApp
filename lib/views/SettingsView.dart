import 'dart:ui';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schatty/provider/DarkThemeProvider.dart';

class SettingsView extends StatefulWidget {
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  void initState() {
    super.initState();
  }

  getDarkTheme() {}

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: ListView(
            children: [
              Container(
                  height: 100,
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Text(
                          "Dark Theme",
                          style: TextStyle(
                            fontSize: 30.0,
                          ),
                        ),
                      ),
                      Switch(
                        value: themeChange.darkTheme,
                        onChanged: (value) {
                          themeChange.darkTheme = value;
                        },
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
//                            color: Color.fromARGB(255, 141, 133, 133),
//                            width: 0.1
                            )),
                  )),
              InkWell(
                onTap: ShowAd(),
                child: Container(
                  height: 100,
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "View an ad",
                        style: TextStyle(
                          fontSize: 30.0,
                        ),
                      )
                    ],
                  ),
                  decoration: BoxDecoration(
                      border: Border(
                    bottom: BorderSide(),
                  )),
                ),
              )
            ],
          ),
        ));
  }

  ShowAd() {
    MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
      keywords: <String>['flutterio', 'apps'],
      contentUrl: 'https://flutter.io',
      childDirected: false,
    );

    InterstitialAd interstitialAd = InterstitialAd(
        adUnitId: "ca-app-pub-1304691467262814/9808678544",
        targetingInfo: targetingInfo,
        listener: (MobileAdEvent event) {
          print("Interstitial Ad Event is $event");
        });

//      BannerAd bannerAd = BannerAd(
//        adUnitId: BannerAd.testAdUnitId,
//        targetingInfo: targetingInfo,
//        size: AdSize.smartBanner,
//        listener: (MobileAdEvent event){
//          print("BannerAD event is $event");
//        }
//      );
    interstitialAd
      ..load()
      ..show(
        anchorType: AnchorType.top,
        anchorOffset: 0.0,
        horizontalCenterOffset: 0.0,
      );

//      bannerAd..dispose();
//      bannerAd..load()..show(
//        anchorType: AnchorType.bottom,
//      );
  }
}
