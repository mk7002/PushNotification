import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../ui/components/Utils.dart';

class FileManager {
  Future<Map<String, String>?> pickAndReadP8File() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['p8'],
      );

      if (result == null) {
        Utils().showMessage('File picking canceled or failed', error: true);
        return null;
      }

      final pickedFile = result.files.single;
      String fileContent = '';

      // For Web: use bytes
      if (pickedFile.bytes != null) {
        fileContent = utf8.decode(pickedFile.bytes!);
      }
      // For Mobile/Desktop: use file path
      else if (pickedFile.path != null) {
        final file = File(pickedFile.path!);
        fileContent = await file.readAsString();
      }

      if (fileContent.trim().isEmpty) {
        Utils().showMessage('File content is empty', error: true);
        return null;
      }

      return {
        'fileName': pickedFile.name,
        'content': fileContent,
      };
    } catch (e) {
      Utils().showMessage('Failed to read .p8 file: $e', error: true);
      return null;
    }
  }

  Future<dynamic> pickAndReadJsonFile() async {
    // Pick a JSON file from the user's device
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'], // Limit to JSON files
    );

    if (result != null) {
      // For web, get bytes directly
      Uint8List? fileBytes = result.files.single.bytes;

      // If you are on mobile and the path is available
      String fileContent = '';
      if (fileBytes != null) {
        // Convert bytes to a string
        fileContent = utf8.decode(fileBytes);
      } else if (result.files.single.path != null) {
        // For mobile platforms
        File file = File(result.files.single.path!);
        fileContent = await file.readAsString();
      }

      // Decode the JSON data
      if (fileContent.isNotEmpty) {
        var jsonData = jsonDecode(fileContent);
        return jsonData;
      } else {
        Utils().showMessage('File content is Empty', error: true);
      }
    } else {
      // User canceled the file picking
      Utils().showMessage('File picking canceled or failed', error: true);
    }
    return null;
  }

  List<Map<String, dynamic>>? parseJsonToList(jsonData) {
    if (jsonData is List) {
      final List<Map<String, dynamic>> typedList = jsonData
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      return typedList;
    } else {
      Utils().showMessage('Invalid template JSON format', error: true);
    }
    return null;
  }
}
