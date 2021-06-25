import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:path/path.dart' as path;

import 'package:flutter/services.dart';
import 'package:flutter_opencv_ffi/flutter_opencv_ffi.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    scaffoldMessengerKey: _messangerKey,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

final _messangerKey = GlobalKey<ScaffoldMessengerState>();

class _MyAppState extends State<MyApp> with MyAppPresenter {
  @override
  void initState() {
    super.initState();
    FlutterOpencvFfi.init();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  primary: Colors.white,
                ),
                onPressed: pickMainImage,
                child: Text("Pick Main Image"),
              ),
              Text(mainImagePath ?? "not select main image yet"),
              SizedBox(
                height: 20,
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  primary: Colors.white,
                ),
                onPressed: pickMarkImage,
                child: Text("Pick mark Image"),
              ),
              Text(markImagePath ?? "not select mark image yet"),
              SizedBox(
                height: 20,
              ),
              // opactivy slide bar
              ..._buildOpacity(),
              ..._buildTextMarkOptions(),
              SizedBox(
                height: 20,
              ),
              // mark position select
              ..._buildPositions(),
              // result pic
              if (resultPic != null) ..._buildResultOutput(),
              SizedBox(
                height: 20,
              ),
              Text(
                'Running on: $_platformVersion\n OpenCV Version: $_openCVVersion',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // add imagemark
          FloatingActionButton(
            onPressed: onAddImageMark,
            child: Icon(Icons.image),
          ),
          SizedBox(
            height: 20,
          ),
          // add textmark
          FloatingActionButton(
            onPressed: onAddTextMark,
            child: Icon(Icons.text_format),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOpacity() {
    return [
      Text("Opacity(mark image only):"),
      Row(
        children: [
          Expanded(
            child: Slider(
              value: opacityValue,
              onChanged: onOpacityChange,
            ),
          ),
          Text("${opacityValue.toStringAsFixed(2)}"),
        ],
      ),
    ];
  }

  List<Widget> _buildTextMarkOptions() {
    return [
      Text("Text Mark: "),
      TextField(
        controller: _textMarkCtrl,
        decoration: InputDecoration(hintText: "Input Some Text Mark"),
      ),
      SizedBox(
        height: 10,
      ),
      Text("Text Scale: "),
      Row(
        children: [
          Expanded(
            child: Slider(
              value: scaleValue,
              min: 0,
              max: 10,
              onChanged: onScaleChange,
            ),
          ),
          Text("${scaleValue.toStringAsFixed(2)}"),
        ],
      ),
      SizedBox(
        height: 10,
      ),
      Text("Text Thickness: "),
      Row(
        children: [
          Expanded(
            child: Slider(
              value: thicknessValue,
              min: 0,
              max: 10,
              onChanged: onThicknessChange,
            ),
          ),
          Text("${thicknessValue.toStringAsFixed(2)}"),
        ],
      ),
      SizedBox(
        height: 10,
      ),
      Text("Text Color:  ${pickerColor.toString()}"),
      TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          primary: Colors.white,
        ),
        onPressed: onPickTextColor,
        child: Text("Pick Text Color"),
      ),
    ];
  }

  List<Widget> _buildPositions() {
    return [
      Text("Mark Position: "),
      RadioListTile<MarkPosition>(
        title: Text("TopLeft"),
        value: MarkPosition.TopLeft,
        groupValue: markPosition,
        onChanged: onSelectMarkPosition,
      ),
      RadioListTile<MarkPosition>(
        title: Text("TopRight"),
        value: MarkPosition.TopRight,
        groupValue: markPosition,
        onChanged: onSelectMarkPosition,
      ),
      RadioListTile<MarkPosition>(
        title: Text("Center"),
        value: MarkPosition.Center,
        groupValue: markPosition,
        onChanged: onSelectMarkPosition,
      ),
      RadioListTile<MarkPosition>(
        title: Text("BottomLeft"),
        value: MarkPosition.BottomLeft,
        groupValue: markPosition,
        onChanged: onSelectMarkPosition,
      ),
      RadioListTile<MarkPosition>(
        title: Text("BottomRight"),
        value: MarkPosition.BottomRight,
        groupValue: markPosition,
        onChanged: onSelectMarkPosition,
      ),
    ];
  }

  List<Widget> _buildResultOutput() {
    return [
      Text("Result ouput: "),
      SizedBox(
        height: 10,
      ),
      Image.file(
        File(resultPic!),
        gaplessPlayback: true,
      ),
    ];
  }
}

mixin MyAppPresenter on State<MyApp> {
  final _picker = ImagePicker();
  String _platformVersion = 'Unknown';
  String _openCVVersion = 'Unknown';
  String? mainImagePath;
  String? markImagePath;
  TextEditingController _textMarkCtrl = TextEditingController();
  MarkPosition markPosition = MarkPosition.Center;
  double opacityValue = 0.5;
  double scaleValue = 2;
  double thicknessValue = 1.5;
  Color pickerColor = Colors.white;
  String? resultPic;

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

  void onAddImageMark() async {
    if (mainImagePath == null || markImagePath == null) {
      _messangerKey.currentState?.showSnackBar(
        const SnackBar(content: Text("select main image and mark image first")),
      );
      return;
    }
    final resultPic = path.join(await _getStogragePathPath(),
        "result_image_mark${DateTime.now().millisecondsSinceEpoch}.png");

    this.resultPic = FlutterOpencvFfi.addImageMask(
      markImagePath!,
      mainImagePath!,
      resultPic,
      opacityValue,
      maskPosition: markPosition,
      markRatio: 1,
    );
    setState(() {});
  }

  void onAddTextMark() async {
    if (mainImagePath == null || _textMarkCtrl.text.trim().isEmpty) {
      _messangerKey.currentState?.showSnackBar(
        const SnackBar(
            content: Text("select main image and input some text mark first")),
      );
      return;
    }
    final resultPic = path.join(await _getStogragePathPath(),
        "result_text_mark${DateTime.now().millisecondsSinceEpoch}.png");
    this.resultPic = FlutterOpencvFfi.addTextMask(
      _textMarkCtrl.text.trim(),
      mainImagePath!,
      resultPic,
      maskPosition: markPosition,
      scale: scaleValue,
      thickness: thicknessValue,
      colorR: pickerColor.red,
      colorG: pickerColor.green,
      colorB: pickerColor.blue,
    );
    setState(() {});
  }

  void onOpacityChange(double value) {
    setState(() {
      opacityValue = value;
    });
  }

  void onScaleChange(double value) {
    setState(() {
      scaleValue = value;
    });
  }

  void onThicknessChange(double value) {
    setState(() {
      thicknessValue = value;
    });
  }

  void onPickTextColor() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              enableAlpha: false,
              onColorChanged: (value) {
                setState(() {
                  this.pickerColor = value;
                });
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Got it'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void onSelectMarkPosition(MarkPosition? value) {
    setState(() {
      markPosition = value!;
    });
  }

  Future<String> _getStogragePathPath() async {
    return Platform.isAndroid
        ? (await getExternalStorageDirectory())!.path
        : (await getApplicationDocumentsDirectory()).path;
  }

  Future pickMainImage() async {
    mainImagePath = await _pickImage();
    setState(() {});
  }

  Future pickMarkImage() async {
    markImagePath = await _pickImage();
    setState(() {});
  }

  Future<String?> _pickImage() async {
    final PickedFile? pickedFile =
        await _picker.getImage(source: ImageSource.gallery);
    return pickedFile?.path;
  }
}
