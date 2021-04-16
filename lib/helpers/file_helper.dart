import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';

class FileApi {
  static Future<List<Uint8List>?> pick(
      {required List<String> extensions, bool multiple = false}) async {
    if (Platform.isLinux) {
      final typeGroup = XTypeGroup(label: 'images', extensions: extensions);
      if (multiple) {
        List<Uint8List> endUintFiles = [];
        final List<XFile>? files =
            await openFiles(acceptedTypeGroups: [typeGroup]);
        await Future.forEach(
            files!, (XFile f) async => endUintFiles.add(await f.readAsBytes()));
        return endUintFiles;
      }
      final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);
      return List.of([await file!.readAsBytes()]);
    }
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png'],
        allowMultiple: multiple);
    if (result != null) {
      if (multiple) {
        List<Uint8List> files = await Future.forEach(result.paths,
            (String? filePath) async => await File(filePath!).readAsBytes());
        return files;
      }
      final PlatformFile plFile = result.files.first;
      return List.of([plFile.bytes!]);
    }
  }
}
