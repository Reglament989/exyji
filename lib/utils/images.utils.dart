import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

// ignore: missing_return
Future compressImage({@required String ref, @required File rawFile, bool returnUrl = false, bool putToRef = true}) async {
  final Uint8List file = await FlutterImageCompress.compressWithFile(
    rawFile.absolute.path,
    minWidth: 1980,
    minHeight: 1080,
    quality: 50,
  );
  if (putToRef) {
    await firebase_storage.FirebaseStorage.instance.ref(ref).putData(file);
  } else {
    return file;
  }
  if (returnUrl) {
    return await firebase_storage.FirebaseStorage.instance
        .ref(ref)
        .getDownloadURL();
  }
}

Future<File> compressImageAndSaveToFile({@required File rawFile, String targetPath}) async {
  return await FlutterImageCompress.compressAndGetFile(
    rawFile.absolute.path, targetPath,
    minWidth: 1980,
    minHeight: 1080,
    quality: 50,
  );
}