import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:schatty/views/MainChatsRoom.dart';

class ViewAd extends StatefulWidget {
  @override
  _ViewAdState createState() => _ViewAdState();
}

class _ViewAdState extends State<ViewAd> {


  //adUnitId: "ca-app-pub-1304691467262814/9808678544",

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    InterstitialAd newInterstitialAd = InterstitialAd(
        adUnitId: "ca-app-pub-1304691467262814/9808678544",
        listener: (MobileAdEvent event) {
          print("Interstitial AD Event: $event");
        }
    );
    newInterstitialAd.load();
    return Scaffold(
      appBar: AppBar(),
      body: Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("ADDVERT HERE!",
                  style: TextStyle(
                    fontSize: 40,
                  ),),
                MaterialButton(
                  onPressed: () async {
                    newInterstitialAd.show(
                      horizontalCenterOffset: 0.0,
                      anchorOffset: 0.0,
                      anchorType: AnchorType.bottom,
                    );
                    Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (context) => ChatRoom(),
                    ));
                  },
                  child: Text("Show AD"),
                ),
              ],
            ),
          )
      ),
    );
  }
}
