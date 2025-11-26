// ignore_for_file: use_key_in_widget_constructors, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pictotxt/account/login.dart';
import 'package:pictotxt/cameraimgtotxt.dart';
import 'package:pictotxt/imagetotxt.dart';
import 'package:pictotxt/ocr.dart';
import 'package:pictotxt/texttospeech.dart';

class Home extends StatefulWidget {
  const Home({Key? key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late User? _user;
  DocumentSnapshot? _userData;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _user!.email)
          .get();
      if (userDoc.docs.isNotEmpty) {
        final userData = userDoc.docs.first;

        setState(() {
          _userData = userData;
        });
      } else {
        if (kDebugMode) {
          print('No user document found for email: ${_user!.email}');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Image.asset(
          'assest/images/logo.png',
          width: 200,
          height: 50,
        ),
        backgroundColor: const Color.fromARGB(255, 51, 51, 51),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
                color: Color.fromARGB(255, 27, 224, 94),
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 51, 51, 51),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: _userData != null
                        ? NetworkImage(_userData?['profilePictureUrl'])
                        : const AssetImage('assets/images/logo.png')
                            as ImageProvider,
                    radius: 30,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${_userData != null ? _userData!['name'] : 'Unknown'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    '${_userData != null ? _userData!['email'] : 'Unknown'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text(
                  'Gender: ${_userData != null ? _userData!['gender'] : 'Unknown'}'),
            ),
            ListTile(
              title: Text(
                  'Phone Number: ${_userData != null ? _userData!['phoneNumber'] : 'Unknown'}'),
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                // Navigate to login page or any other page after logout
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  text:
                      'Transforming images into voices,where vision meets vocalization with ',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  children: [
                    TextSpan(
                      text: 'SNIP SPEAK',
                      style: TextStyle(
                          color: Color.fromARGB(255, 49, 233, 111),
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            Image.asset('assest/images/home1.png'),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageToTxt(),
                      ));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(
                      width: 200,
                      child: Column(
                        children: [
                          Text(
                            'Upload image from phone',
                            style: TextStyle(
                                color: Color.fromARGB(255, 23, 212, 87),
                                fontSize: 22),
                          ),
                          Text(
                            'Allow users to images containing text for processing',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 14,
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: 120,
                      width: 130,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromARGB(255, 27, 224, 94),
                            width: 2),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        image: const DecorationImage(
                            image: AssetImage('assest/images/imagetotxt.jpg'),
                            fit: BoxFit.fill),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OcrPage(),
                      ));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      height: 120,
                      width: 130,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromARGB(255, 27, 224, 94),
                            width: 2),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        image: const DecorationImage(
                            image: AssetImage(
                                'assest/images/AutomaticTextExtraction.jpg'),
                            fit: BoxFit.fill),
                      ),
                    ),
                    const SizedBox(
                      width: 200,
                      child: Column(
                        children: [
                          Text(
                            'Automatic Text Extraction',
                            style: TextStyle(
                                color: Color.fromARGB(255, 23, 212, 87),
                                fontSize: 22),
                          ),
                          Text(
                            'Implement a robust text extraction algorithm to automatically identify and extract text from the uploaded documents or images.',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 14,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => cameraimgtotxt(),
                      ));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(
                      width: 200,
                      child: Column(
                        children: [
                          Text(
                            'OCR(Optical Character Recognization)',
                            style: TextStyle(
                                color: Color.fromARGB(255, 23, 212, 87),
                                fontSize: 22),
                          ),
                          Text(
                            'Utilize OCR technology to accurately recognize characters and convert them into machine-readable text',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 14,
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: 120,
                      width: 130,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromARGB(255, 27, 224, 94),
                            width: 2),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        image: const DecorationImage(
                            image: AssetImage('assest/images/camera.jpg'),
                            fit: BoxFit.fill),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => txttoimage(),
                      ));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      height: 120,
                      width: 130,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromARGB(255, 27, 224, 94),
                            width: 2),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(20),
                        ),
                        image: const DecorationImage(
                            image: AssetImage('assest/images/texttospeech.jpg'),
                            fit: BoxFit.fill),
                      ),
                    ),
                    const SizedBox(
                      width: 200,
                      child: Column(
                        children: [
                          Text(
                            'Text-to-Speech Conversion',
                            style: TextStyle(
                                color: Color.fromARGB(255, 23, 212, 87),
                                fontSize: 22),
                          ),
                          Text(
                            'Integrate a Text to Speech (TTS)engine to convert the extracted text into natural-sounding speech.',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 14,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
