import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

class SwipeTest extends StatefulWidget {
  @override
  _SwipeTestState createState() => _SwipeTestState();
}

class _SwipeTestState extends State<SwipeTest> {
  FlickManager flickManager;
  File videoFile;
  final picker = ImagePicker();
  final videoCompress = VideoCompress();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Schatty"),
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            child: videoFile != null
                ? FlickVideoPlayer(
                    flickManager: flickManager,
                  )
                : Container(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          video();
        },
      ),
    );
  }

  video() async {
    var tempFile = await FilePicker.getFile(
      type: FileType.video,
    );
    if (tempFile?.path != null) {
      final resultFile = await VideoCompress.getFileThumbnail(tempFile.path,
          quality: 70, position: -1);
//      print(resultFile.path);

      assert(resultFile.existsSync());

      debugPrint('file Exists: ${resultFile.existsSync()}');

      final MediaInfo info = await VideoCompress.compressVideo(
        tempFile.path,
        deleteOrigin: false,
        quality: VideoQuality.LowQuality,
      );

      debugPrint(info.toJson().toString());
      videoFile = resultFile;
      flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.file(videoFile),
      );
      setState(() {});
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    flickManager.dispose();
  }
}
