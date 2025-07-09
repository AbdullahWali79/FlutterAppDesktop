import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

class FileSelectorUtil {
  static Future<String?> selectFile({
    String? initialDirectory,
    List<String>? allowedExtensions,
  }) async {
    try {
      final typeGroup = XTypeGroup(
        label: 'Files',
        extensions: allowedExtensions ?? ['csv', 'xlsx', 'xls'],
      );

      final file = await openFile(
        acceptedTypeGroups: [typeGroup],
        initialDirectory: initialDirectory,
        confirmButtonText: 'Select',
      );

      return file?.path;
    } catch (e) {
      debugPrint('Error selecting file: $e');
      return null;
    }
  }

  static Future<String?> selectDirectory({
    String? initialDirectory,
  }) async {
    try {
      final directory = await getDirectoryPath(
        initialDirectory: initialDirectory,
        confirmButtonText: 'Select',
      );

      return directory;
    } catch (e) {
      debugPrint('Error selecting directory: $e');
      return null;
    }
  }

  static Future<String?> saveFile({
    String? initialDirectory,
    String? suggestedName,
    List<String>? allowedExtensions,
  }) async {
    try {
      final typeGroup = XTypeGroup(
        label: 'Files',
        extensions: allowedExtensions ?? ['csv', 'xlsx', 'xls'],
      );

      final location = await getSaveLocation(
        acceptedTypeGroups: [typeGroup],
        initialDirectory: initialDirectory,
        suggestedName: suggestedName,
        confirmButtonText: 'Save',
      );

      return location?.path;
    } catch (e) {
      debugPrint('Error saving file: $e');
      return null;
    }
  }
} 