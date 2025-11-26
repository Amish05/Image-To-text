import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pictotxt/ocr.dart';
import 'package:pictotxt/savetxtfile.dart';

class OcrHistory extends StatefulWidget {
  final List<String> history;
  final VoidCallback? onReturn;
  OcrHistory({Key? key, required this.history, this.onReturn})
      : super(key: key);

  @override
  State<OcrHistory> createState() => _OcrHistoryState();
}

class _OcrHistoryState extends State<OcrHistory> {
  final FlutterTts flutterTts = FlutterTts();
  late List<bool> isPlayingList;
  late int index;

  @override
  void initState() {
    super.initState();
    isPlayingList = List<bool>.generate(widget.history.length, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 51, 51, 51),
        title: const Text(
          'Automatic Text Extraction',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              String? fileName = await _promptFileName(context);

              if (fileName != null && fileName.isNotEmpty) {
                saveTextToFile(
                  widget.history.join('\n'),
                  fileName,
                  context,
                );
              }
            },
            icon: const Icon(
              Icons.save,
              size: 30,
              color: Color.fromARGB(255, 27, 224, 94),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.history.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.all(16.0),
            color: Colors.black,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.history[index],
                    style: const TextStyle(color: Colors.white, fontSize: 18.0),
                    overflow: TextOverflow.fade,
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () async {
                        if (!isPlayingList[index]) {
                          await speak(widget.history[index], index);

                          setState(() {
                            isPlayingList[index] = true;
                          });
                        } else {
                          await stop();
                          setState(() {
                            isPlayingList[index] = false;
                          });
                        }
                      },
                      icon: Icon(
                        isPlayingList[index] ? Icons.stop : Icons.play_arrow,
                        size: 30,
                        color: isPlayingList[index]
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
                          saveTextToFile(
                              widget.history[index], fileName, context);
                        }
                      },
                      icon: const Icon(
                        Icons.save,
                        size: 30,
                        color: Color.fromARGB(255, 27, 224, 94),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        String? fileName = await _promptFileName(context);

                        if (fileName != null && fileName.isNotEmpty) {
                          await flutterTts.synthesizeToFile(
                            widget.history[index],
                            '$fileName.mp3',
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.audio_file_rounded,
                        size: 30,
                        color: Color.fromARGB(255, 27, 224, 94),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> speak(String text, int index) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.speak(text);
    flutterTts.setCompletionHandler(() {
      setState(() {
        isPlayingList[index] = false;
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
