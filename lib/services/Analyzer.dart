import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TestML extends StatefulWidget {
  @override
  _TestMLState createState() => _TestMLState();
}

class _TestMLState extends State<TestML> {
  File _imageFile;
  List<ImageLabel> _labels;

  ImageLabeler labeler = FirebaseVision.instance
      .imageLabeler(ImageLabelerOptions(confidenceThreshold: .3));

  void pickImageAndLabel() async {
    try {
      final imageFile =
          await ImagePicker().getImage(source: ImageSource.gallery);
      if (imageFile != null) {
        final image = FirebaseVisionImage.fromFile(File(imageFile.path));
        final label = await labeler.processImage(image).catchError((onError) {
          print(onError);
        });
        if (mounted) {
          setState(() {
            _imageFile = File(imageFile.path);
            _labels = label;
          });
        }
      }

      String text;
      for (ImageLabel label in _labels) {
        final double confidence = label.confidence;
        setState(() {
          text = "${label.text} ${confidence.toStringAsFixed(2)}\n";
        });
        print(text);
      }
    } catch (e) {
      print('$e');
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    labeler.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ML"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          pickImageAndLabel();
        },
        child: Icon(Icons.add),
      ),
      body: _imageFile != null
          ? LabelsAndList(
              labels: _labels,
              imageFile: _imageFile,
            )
          : Container(),
    );
  }
}

class LabelsAndList extends StatelessWidget {
  final File imageFile;
  final List<ImageLabel> labels;

  const LabelsAndList({Key key, this.imageFile, this.labels}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          flex: 2,
          child: Container(
              constraints: BoxConstraints.expand(),
              child: Image.file(
                imageFile,
                fit: BoxFit.cover,
              )),
        ),
        Flexible(
          flex: 1,
          child: ListView.builder(
            itemCount: labels.length,
            itemBuilder: (BuildContext context, index) {
              return ListTile(
                title: Text(labels[index].text),
                trailing: Text(labels[index].confidence.toStringAsFixed(2)),
              );
            },
          ),
        )
      ],
    );
  }
}
