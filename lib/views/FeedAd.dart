import 'package:flutter/material.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';

class FeedAd extends StatelessWidget {
  //AdMob
  static const adUnitAd = "ca-app-pub-1304691467262814/5518891816";
  final _controller = NativeAdmobController();

  @override
  Widget build(BuildContext context) {
    final _nativeAdMob = NativeAdmob(
      adUnitID: FeedAd.adUnitAd,
      loading: Center(child: CircularProgressIndicator()),
      error: Center(child: Text("Failed to load")),
      controller: _controller,
      type: NativeAdmobType.full,
    );
    return Container(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(10),
            child: Text("Advert:"),
          ),
          Container(
            height: 330,
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(10),
            child: _nativeAdMob,
          )
        ],
      ),
    );
  }
}
