import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_luban/flutter_luban.dart';
import 'package:path_provider/path_provider.dart';

Future<Uint8List> compressImage({required String imagePath}) async {
  final tempDir = await getTemporaryDirectory();
  CompressObject compressObject = CompressObject(
    imageFile: File(imagePath), //image
    path: tempDir.path, //compress to path
    quality: 80, //first compress quality, default 80
    step:
        6, //compress quality step, The bigger the fast, Smaller is more accurate, default 6
    mode: CompressMode.LARGE2SMALL, //default AUTO
  );
  final filePath = await Luban.compressImage(compressObject);
  final uint = await File(filePath!).readAsBytes();
  return uint;
}
