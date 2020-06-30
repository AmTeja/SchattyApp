import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';

class ViewAd extends StatefulWidget {
  @override
  _ViewAdState createState() => _ViewAdState();
}

class _ViewAdState extends State<ViewAd> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAd();
  }

  initAd(){
    MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
      keywords: <String>['flutterio', 'apps'],
      contentUrl: 'https://flutter.io',
      childDirected: false,
    );

    InterstitialAd interstitialAd = InterstitialAd(
        //adUnitId: "ca-app-pub-1304691467262814/9808678544",
        adUnitId: InterstitialAd.testAdUnitId,
        targetingInfo: targetingInfo,
        listener: (MobileAdEvent event) {
          print("Interstitial Ad Event is $event");
        });
    interstitialAd
      ..load()
      ..show(
        anchorType: AnchorType.top,
        anchorOffset: 0.0,
        horizontalCenterOffset: 0.0,
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }
}
