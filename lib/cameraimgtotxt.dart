import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pictotxt/savetxtfile.dart';

class cameraimgtotxt extends StatefulWidget {
  const cameraimgtotxt({Key? key}) : super(key: key);

  @override
  _cameraimgtotxtState createState() => _cameraimgtotxtState();
}

class _cameraimgtotxtState extends State<cameraimgtotxt> {
  final ImagePicker picker = ImagePicker();
  late String textResult = "";
  String? selectedImagePath;
  final FlutterTts flutterTts = FlutterTts();
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: const Color.fromARGB(255, 51, 51, 51),
          title: const Text(
            'Image To Text',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            selectedImagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      File(selectedImagePath!),
                      fit: BoxFit.contain,
                      height: MediaQuery.of(context).size.height * 0.4,
                      width: MediaQuery.of(context).size.width * 0.7,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assest/images/camerahome.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.camera);
                    if (image != null) {
                      final a = await getImageToText(image.path);
                      setState(() {
                        textResult = a;
                        selectedImagePath = image.path;
                      });
                    }
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromARGB(255, 27, 224, 94)),
                  ),
                  child: const Text(
                    'Take Photo',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
            if (textResult.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () async {
                      if (!isPlaying) {
                        await speak(textResult);
                        setState(() {
                          isPlaying = true;
                        });
                      } else {
                        await stop();
                        setState(() {
                          isPlaying = false;
                        });
                      }
                    },
                    icon: Icon(
                      isPlaying ? Icons.stop : Icons.play_arrow,
                      size: 48,
                      color: isPlaying
                          ? Colors.red
                          : const Color.fromARGB(255, 27, 224, 94),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  IconButton(
                    onPressed: () async {
                      String? fileName = await _promptFileName(context);

                      if (fileName != null && fileName.isNotEmpty) {
                        saveTextToFile(textResult, fileName, context);
                      }
                    },
                    icon: const Icon(
                      Icons.save,
                      size: 48,
                      color: Color.fromARGB(255, 27, 224, 94),
                    ),
                  ),
                ],
              ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    textResult,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<String> getImageToText(final imagePath) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(InputImage.fromFilePath(imagePath));
    return recognizedText.text.toString();
  }

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.speak(text);
    flutterTts.setCompletionHandler(() {
      setState(() {
        isPlaying = false;
      });
    });
  }

  Future<void> stop() async {
    await flutterTts.stop();
  }

  Future<String?> _promptFileName(BuildContext context) async {
    TextEditingController fileNameController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter File Name'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: fileNameController,
                  decoration: const InputDecoration(hintText: 'File Name'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(fileNameController.text);
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
