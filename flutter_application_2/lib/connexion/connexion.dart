import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase_options.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isFirebaseInitialized = false;

  bool _isLoading = false;

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
  }

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).then((value) {
      print("Firebase initialisé avec succès");
      setState(() {
        _isFirebaseInitialized = true;
      });
    });
  }

  static Future<String?> _login(
      {required String email,
      required String password,
      required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        print("Cette adresse mail existe pas !");
        return null;
      }
      return null;
    }
    return user?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connexion'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _isFirebaseInitialized
                ? FutureBuilder(
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Une erreur est survenue'),
                        );
                      } else {
                        return SingleChildScrollView(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: <Widget>[
                                  SizedBox(height: 48.0),
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      labelText: 'Adresse email',
                                    ),
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return 'Veuillez entrer votre adresse email';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 16.0),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      labelText: 'Mot de passe',
                                    ),
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return 'Veuillez entrer votre mot de passe';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 48.0),
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.red),
                                    ),
                                    onPressed: _isLoading
                                        ? null
                                        : () async {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              setState(() {
                                                _isLoading = true;
                                              });
                                              String? userId = await _login(
                                                  email: _emailController.text,
                                                  password:
                                                      _passwordController.text,
                                                  context: context);
                                              setState(() {
                                                _isLoading = false;
                                              });
                                              if (userId != null) {
                                                Navigator.pop(context, userId);
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'Adresse email ou mot de passe incorrect'),
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .errorColor,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                    child: _isLoading
                                        ? CircularProgressIndicator()
                                        : Text('Se connecter'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  )
                : CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
