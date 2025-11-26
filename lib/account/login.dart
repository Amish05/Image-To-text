// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pictotxt/account/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pictotxt/home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assest/images/logo.png',
                width: 300,
                height: 150,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: const Color.fromARGB(255, 217, 217, 217),
                  ),
                  child: Form(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color.fromARGB(255, 6, 74, 111),
                                Color.fromARGB(255, 15, 127, 150),
                                Color.fromARGB(255, 17, 160, 165),
                              ],
                            ).createShader(bounds);
                          },
                          child: const Text(
                            "LOGIN",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: _emailController,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            labelText: 'ENTER EMAIL',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            filled: true,
                            fillColor: Color.fromARGB(255, 131, 242, 169),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            labelText: 'ENTER PASSWORD',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            filled: true,
                            fillColor: Color.fromARGB(255, 131, 242, 169),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 30),
                        Container(
                          height: 44.0,
                          decoration: const BoxDecoration(
                              gradient: LinearGradient(colors: [
                            Color.fromARGB(255, 13, 89, 131),
                            Color.fromARGB(255, 17, 160, 165)
                          ])),
                          child: ElevatedButton(
                            onPressed: () async {
                              try {
                                UserCredential userCredential =
                                    await FirebaseAuth.instance
                                        .signInWithEmailAndPassword(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                );
                                // If login is successful, navigate to the home page
                                if (userCredential.user != null) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Home()),
                                  );
                                }
                              } catch (e) {
                                // If login fails, show an error dialog
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Login Failed'),
                                      content: Text(e.toString()),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            child: const Text(
                              'LOGIN',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account?"),
                            TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SignUpPage()),
                                  );
                                },
                                child: const Text(
                                  "SignUp",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 13, 89, 131),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16),
                                ))
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show loading indicator while checking auth status
        }
        if (snapshot.hasData && snapshot.data != null) {
          // User is already authenticated, navigate to home page
          return const Home();
        } else {
          // User is not authenticated, show login page
          return const LoginPage();
        }
      },
    );
  }
}
