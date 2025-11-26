import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

Future<void> saveTextToFile(
  String text,
  String fileName,
  BuildContext context,
) async {
  try {
    // Get the download directory
    final directory = Directory('/storage/emulated/0/Download');

    // Save the file in the download directory
    final file = File('${directory.path}/$fileName.txt');
    await file.writeAsString(text);

    // Show a SnackBar to indicate that the file is saved
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Text saved to file.',
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  } catch (e) {
    // Show a SnackBar with the error message if saving fails
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Error saving file: $e',
          style: TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
    print("the error is $e");
  }
}
