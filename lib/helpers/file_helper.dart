import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:exyji/helpers/images.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class EFile {
  final Uint8List data;
  final int size;
  final String fileExtension;
  final String caption;

  EFile(this.data, this.size, this.fileExtension, this.caption);
}

abstract class FileApi {
  static Future<List<EFile>?> pick(
      {required List<String> extensions, bool multiple = false}) async {
    if (Platform.isLinux) {
      final typeGroup = XTypeGroup(label: 'images', extensions: extensions);
      if (multiple) {
        List<EFile> endUintFiles = [];
        final List<XFile>? files =
            await openFiles(acceptedTypeGroups: [typeGroup]);
        if (files == null) {
          return null;
        }
        if (extensions == ['jpg', 'png']) {
          await Future.forEach(files, (XFile f) async {
            final compressedFile = await compressImage(imagePath: f.path);
            endUintFiles.add(compressedFile);
          });
        } else {
          await Future.forEach(files, (XFile f) async {
            final data = await f.readAsBytes();
            final size = await f.length();
            final fileName = f.path.split('/').last.split('.');
            final eFile = EFile(data, size, fileName.last, fileName.first);
            endUintFiles.add(eFile);
          });
        }
        if (endUintFiles.length > 0) {
          return endUintFiles;
        }
        return null;
      }
      final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);
      if (file == null) {
        return null;
      }
      if (extensions == ['jpg', 'png']) {
        final compressedFile = await compressImage(imagePath: file.path);
        return List.of([compressedFile]);
      }
      final fileName = file.path.split('/').last.split('.');
      return List.of([
        EFile((await file.readAsBytes()), (await file.length()), fileName.last,
            fileName.first)
      ]);
    }
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: extensions,
        allowMultiple: multiple);
    if (result != null) {
      if (multiple) {
        List<EFile> endUintFiles = [];
        if (extensions == ['jpg', 'png']) {
          await Future.forEach(result.paths, (String? filePath) async {
            final compressedFile = await compressImage(imagePath: filePath!);
            endUintFiles.add(compressedFile);
          });
        } else {
          await Future.forEach(result.paths, (String? filePath) async {
            final file = File(filePath!);
            final fileName = file.path.split('/').last.split('.');
            endUintFiles.add(EFile((await file.readAsBytes()),
                (await file.stat()).size, fileName.last, fileName.first));
          });
        }
        if (endUintFiles.length > 0) {
          return endUintFiles;
        }
        return null;
      }
      if (result.files.single.path != null) {
        final String path = result.files.single.path as String;
        if (extensions == ['jpg', 'png']) {
          final compressedFile = await compressImage(imagePath: path);
          return List.of([compressedFile]);
        }
        final File rawFile = File(path);
        final fileName = path.split('/').last.split('.');
        return List.of([
          EFile((await rawFile.readAsBytes()), (await rawFile.stat()).size,
              fileName.last, fileName.first)
        ]);
      }
    }
  }

  static Future<void> saveToExternal(
      Uint8List data, String fullName, BuildContext ctx) async {
    final downloadsDir =
        (await getExternalStorageDirectory())!.path + '/photos/';
    final dir = Directory(downloadsDir);
    if (!(await dir.exists())) {
      await dir.create();
    }
    final file = File(downloadsDir + fullName);
    await file.writeAsBytes(data);
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        backgroundColor: Colors.lightGreen,
        content: Text('File saved to $downloadsDir.')));
  }
}
