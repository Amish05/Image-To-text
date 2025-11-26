import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pictotxt/savetxtfile.dart';

class txttoimage extends StatefulWidget {
  const txttoimage({Key? key}) : super(key: key);

  @override
  _txttoimageState createState() => _txttoimageState();
}

class _txttoimageState extends State<txttoimage> {
  final FlutterTts flutterTts = FlutterTts();
  bool isPlaying = false;
  TextEditingController textResult = TextEditingController();
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
            'Text To Speech',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(20),
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2,
                    color: const Color.fromARGB(255, 27, 224, 94),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SingleChildScrollView(
                  child: TextField(
                    controller: textResult,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                        hintText: "Enter Text",
                        hintStyle: TextStyle(color: Colors.white),
                        focusedBorder: InputBorder.none,
                        border: InputBorder.none),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              if (textResult.text.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () async {
                        if (!isPlaying) {
                          await speak(textResult.text);
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
                          saveTextToFile(textResult.text, fileName, context);
                        }
                      },
                      icon: const Icon(
                        Icons.save,
                        size: 48,
                        color: Color.fromARGB(255, 27, 224, 94),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        String? fileName = await _promptFileName(context);

                        if (fileName != null && fileName.isNotEmpty) {
                          await flutterTts.synthesizeToFile(
                            textResult.text,
                            '$fileName.mp3',
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.audio_file_rounded,
                        size: 48,
                        color: Color.fromARGB(255, 27, 224, 94),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
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
