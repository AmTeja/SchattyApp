import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_native_admob/native_admob_options.dart';

class FeedAd extends StatelessWidget {
  //AdMob
  final adUnitId;

  final _controller = NativeAdmobController();

  FeedAd({this.adUnitId});

  @override
  Widget build(BuildContext context) {
    final _nativeAdMob = NativeAdmob(
      options: NativeAdmobOptions(
        showMediaContent: true,
      ),
      adUnitID: adUnitId ?? NativeAd.testAdUnitId,
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
            child: Text(
              "Advert:",
              style: TextStyle(fontSize: 20),
            ),
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
