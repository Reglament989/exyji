import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

// ignore: missing_return
Future<String> compressAndPutIntoRef({@required String ref, @required File rawFile, bool returnUrl = false}) async {
  final Uint8List file = await FlutterImageCompress.compressWithFile(
    rawFile.absolute.path,
    minWidth: 1980,
    minHeight: 1080,
    quality: 50,
  );
  await firebase_storage.FirebaseStorage.instance.ref(ref).putData(file);
  if (returnUrl) {
    return await firebase_storage.FirebaseStorage.instance
        .ref(ref)
        .getDownloadURL();
  }
}