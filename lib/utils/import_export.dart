import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/person.dart';

class ImportExportUtil {
  static Future<FamilyTree?> importFromFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'ftree'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final jsonStr = utf8.decode(bytes);
        return FamilyTree.fromJsonString(jsonStr);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    return null;
  }

  static Future<void> exportToFile(
      BuildContext context, FamilyTree tree) async {
    try {
      final jsonStr = tree.toJsonString();
      final bytes = utf8.encode(jsonStr);

      if (Platform.isAndroid || Platform.isIOS) {
        final tempDir = await getTemporaryDirectory();
        final fileName =
            '${tree.title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.json';
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(bytes);
        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'application/json')],
          text: 'Family Tree: ${tree.title}',
        );
      } else {
        final result = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Family Tree',
          fileName: '${tree.title.replaceAll(' ', '_')}.json',
          type: FileType.custom,
          allowedExtensions: ['json'],
        );

        if (result != null) {
          final file = File(result);
          await file.writeAsBytes(bytes);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Exported to: $result'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
