import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart';

// c functions
typedef _version_func = Pointer<Utf8> Function();
typedef _add_image_mask = Void Function(Pointer<Utf8>, Pointer<Utf8>,
    Pointer<Utf8>, Double, Int32 position, Double markRatio);

// dart functions
typedef _VersionFunc = Pointer<Utf8> Function();
typedef _AddImageMask = void Function(
    Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, double, int, double);

enum MaskPosition {
  TopLeft,
  TopRight,
  BottomLeft,
  BottomRight,
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

  static void addImageMask(
    String markImage,
    String joinImage,
    String outputPath,
    double alpha, {
    MaskPosition maskPosition = MaskPosition.BottomRight,
    double markRatio = 1.0,
  }) {
    assert(alpha > 0.0 && alpha < 1);
    assert(markRatio > 0.0 && markRatio <= 1);
    try {
      final _AddImageMask _addFunc = nativelib!
          .lookup<NativeFunction<_add_image_mask>>('add_image_mask')
          .asFunction();
      _addFunc(
        markImage.toNativeUtf8(),
        joinImage.toNativeUtf8(),
        outputPath.toNativeUtf8(),
        alpha,
        maskPosition.index,
        markRatio,
      );
    } catch (e) {
      debugPrint("get opencv version failed $e");
    }
  }
}
