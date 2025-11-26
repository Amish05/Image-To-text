import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_scalable_ocr/flutter_scalable_ocr.dart';
import 'package:pictotxt/ocrhistory.dart';

List<String> history = [];

class OcrPage extends StatefulWidget {
  const OcrPage({Key? key}) : super(key: key);

  @override
  _OcrPageState createState() => _OcrPageState();
}

class _OcrPageState extends State<OcrPage> {
  String text = "";
  final StreamController<String> controller = StreamController<String>();

  bool isTextDetectionEnabled = true;
  late Timer _timer; // Timer for scanning

  @override
  void initState() {
    super.initState();
    _startTimer(); // Start the timer when the widget is initialized
  }

  @override
  void dispose() {
    controller.close();
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void setText(String value) {
    controller.add(value);
    if (value.isNotEmpty) {
      addtoHistory(value);
    }
  }

  void addtoHistory(String value) {
    history.add(value);
    const int maxHistorySize = 20;
    if (history.length > maxHistorySize) {
      history.removeRange(0, history.length - maxHistorySize);
    }
  }

  void toggleTextDetection(bool isEnabled) {
    setState(() {
      isTextDetectionEnabled = isEnabled;
    });
  }

  void _startTimer() {
    _timer = Timer(Duration(seconds: 30), () {
      // Stop text detection after 30 seconds
      toggleTextDetection(false);
      // Optionally, you can also show a button to restart the timer here
    });
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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ScalableOCR(
              paintboxCustom: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 4.0
                ..color = const Color.fromARGB(153, 102, 160, 241),
              boxLeftOff: 10,
              boxBottomOff: 5,
              boxRightOff: 10,
              boxTopOff: 5,
              boxHeight: MediaQuery.of(context).size.height / 3,
              getRawData: (value) {
                print(value);
              },
              getScannedText:
                  isTextDetectionEnabled ? setText : (String value) {},
            ),
            StreamBuilder<String>(
              stream: controller.stream,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                return Result(
                  text: snapshot.data != null ? snapshot.data! : "",
                );
              },
            ),
            ElevatedButton(
              onPressed: () {
                toggleTextDetection(false);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return OcrHistory(
                        history: history,
                      );
                    },
                  ),
                ).then((_) {
                  toggleTextDetection(true);
                  _startTimer(); // Restart the timer after returning from history
                });
              },
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(
                  const Color.fromARGB(255, 27, 224, 94),
                ),
              ),
              child: const Text(
                'Results',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Result extends StatelessWidget {
  const Result({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      "Read text: $text",
      style: const TextStyle(color: Colors.white),
    );
  }
}
