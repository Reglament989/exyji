import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:fl_reload/helpers/images.dart';

class FileApi {
  static Future<List<Uint8List>?> pick(
      {required List<String> extensions, bool multiple = false}) async {
    if (Platform.isLinux) {
      final typeGroup = XTypeGroup(label: 'images', extensions: extensions);
      if (multiple) {
        List<Uint8List> endUintFiles = [];
        final List<XFile>? files =
            await openFiles(acceptedTypeGroups: [typeGroup]);
        if (extensions == ['jpg', 'png']) {
          await Future.forEach(files!, (XFile f) async {
            final compressedFile = await compressImage(imagePath: f.path);
            endUintFiles.add(compressedFile);
          });
        } else {
          await Future.forEach(files!,
              (XFile f) async => endUintFiles.add(await f.readAsBytes()));
        }
        return endUintFiles;
      }
      final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);
      if (extensions == ['jpg', 'png']) {
        final compressedFile = await compressImage(imagePath: file!.path);
        return List.of([compressedFile]);
      }
      return List.of([await file!.readAsBytes()]);
    }
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: extensions,
        allowMultiple: multiple);
    if (result != null) {
      if (multiple) {
        List<Uint8List> endUintFiles = [];
        if (extensions == ['jpg', 'png']) {
          await Future.forEach(result.paths, (String? filePath) async {
            final compressedFile = await compressImage(imagePath: filePath!);
            endUintFiles.add(compressedFile);
          });
        } else {
          await Future.forEach(
              result.paths,
              (String? filePath) async =>
                  endUintFiles.add(await File(filePath!).readAsBytes()));
        }
        return endUintFiles;
      }
      if (result.files.single.path != null) {
        final String path = result.files.single.path as String;
        if (extensions == ['jpg', 'png']) {
          final compressedFile = await compressImage(imagePath: path);
          return List.of([compressedFile]);
        }
        final File rawFile = File(path);
        return List.of([await rawFile.readAsBytes()]);
      }
    }
  }
}
