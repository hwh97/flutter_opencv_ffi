import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart';

// c functions
typedef _version_func = Pointer<Utf8> Function();
typedef _add_image_mask = Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>,
    Pointer<Utf8>, Double, Int32 position, Double markRatio);
typedef _add_text_mask = Pointer<Utf8> Function(
    Pointer<Utf8>,
    Pointer<Utf8>,
    Pointer<Utf8>,
    Int32 position,
    Double scale,
    Double thickness,
    Int32 colorR,
    Int32 colorG,
    Int32 colorB);

// dart functions
typedef _VersionFunc = Pointer<Utf8> Function();
typedef _AddImageMask = Pointer<Utf8> Function(
    Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, double, int, double);
typedef _AddTextMask = Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>,
    Pointer<Utf8>, int, double, double, int, int, int);

enum MarkPosition {
  TopLeft,
  TopRight,
  BottomLeft,
  BottomRight,
  Center,
}

class FlutterOpencvFfi {
  static const MethodChannel _channel =
      const MethodChannel('flutter_opencv_ffi');
  static DynamicLibrary? nativelib;

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static void init() {
    nativelib = Platform.isAndroid
        ? DynamicLibrary.open("libnative-lib.so")
        : DynamicLibrary.process();
  }

  static String? getOpenCVVersion() {
    try {
      final _VersionFunc _versionFunc = nativelib!
          .lookup<NativeFunction<_version_func>>('version')
          .asFunction();
      return _versionFunc().toDartString();
    } catch (e) {
      debugPrint("get opencv version failed $e");
    }
  }

  static String? addImageMask(
    String markImage,
    String joinImage,
    String outputPath,
    double alpha, {
    MarkPosition maskPosition = MarkPosition.BottomRight,
    double markRatio = 1.0,
  }) {
    assert(alpha >= 0.0 && alpha <= 1);
    assert(markRatio > 0.0 && markRatio <= 1);
    try {
      final _AddImageMask _addFunc = nativelib!
          .lookup<NativeFunction<_add_image_mask>>('add_image_mark')
          .asFunction();
      Pointer<Utf8> result = _addFunc(
        markImage.toNativeUtf8(),
        joinImage.toNativeUtf8(),
        outputPath.toNativeUtf8(),
        alpha,
        maskPosition.index,
        markRatio,
      );
      if (result.address == nullptr.address) {
        return null;
      } else {
        return result.toDartString();
      }
    } catch (e) {
      debugPrint("add_image_mask failed $e");
    }
    return null;
  }

  static String? addTextMask(
    String textMark,
    String joinImage,
    String outputPath, {
    MarkPosition maskPosition = MarkPosition.TopLeft,
    double scale = 1,
    double thickness = 1,
    int colorR = 255,
    int colorG = 255,
    int colorB = 255
  }) {
    try {
      final _AddTextMask _addFunc = nativelib!
          .lookup<NativeFunction<_add_text_mask>>('add_text_mark')
          .asFunction();
      final result = _addFunc(
        textMark.toNativeUtf8(),
        joinImage.toNativeUtf8(),
        outputPath.toNativeUtf8(),
        maskPosition.index,
        scale,
        thickness,
        colorR,
        colorG,
        colorB,
      );
      if (result.address == nullptr.address) {
        return null;
      } else {
        return result.toDartString();
      }
    } catch (e) {
      debugPrint("add_image_mask failed $e");
    }
  }
}
