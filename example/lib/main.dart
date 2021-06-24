import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path/path.dart' as path;

import 'package:flutter/services.dart';
import 'package:flutter_opencv_ffi/flutter_opencv_ffi.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _openCVVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    FlutterOpencvFfi.init();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    String openCVVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await FlutterOpencvFfi.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    // get opencv version by using ffi
    openCVVersion =
        FlutterOpencvFfi.getOpenCVVersion() ?? 'Unknown opencv version';

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      _openCVVersion = openCVVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text(
            'Running on: $_platformVersion\n OpenCV Version: $_openCVVersion',
            textAlign: TextAlign.center,
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // add imagemark
            FloatingActionButton(
              onPressed: () async {
                String storageDirBasePath = (await getExternalStorageDirectory())!.path;
                FlutterOpencvFfi.addImageMask(
                  path.join(storageDirBasePath, "mask.jpg"),
                  path.join(storageDirBasePath, "source.png"),
                  path.join(storageDirBasePath, "result_image_mark.png"),
                  0.3,
                  maskPosition: MaskPosition.Center,
                  markRatio: 0.2, // decrease size of image to 50%
                );
              },
              child: Icon(Icons.image),
            ),
            SizedBox(height: 20,),
            // add textmark
            FloatingActionButton(
              onPressed: () async {
                String storageDirBasePath = (await getExternalStorageDirectory())!.path;
                FlutterOpencvFfi.addTextMask(
                  "@Andy.huang",
                  path.join(storageDirBasePath, "source.png"),
                  path.join(storageDirBasePath, "result_text_mark.png"),
                  0.3,
                  maskPosition: MaskPosition.BottomRight,
                );
              },
              child: Icon(Icons.text_format),
            )
          ],
        ),
      ),
    );
  }
}
