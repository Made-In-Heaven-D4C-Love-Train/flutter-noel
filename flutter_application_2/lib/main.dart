import 'package:flutter/material.dart';

import 'ListeProduit/listeProduit.dart';
import 'connexion/connexion.dart';
import 'listeFavoris/listeFavoris.dart';
import 'panier/panier.dart';
import 'listeCommande/listeCommande.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var userId = "";
  var userIdOk = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Accueil"),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            userIdOk
                ? FractionallySizedBox(
                    widthFactor: 0.5,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.red),
                      ),
                      child: Text('Connexion'),
                      onPressed: () async {
                        final result = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                        setState(() {
                          userId = result!;
                          userIdOk = false;
                        });
                      },
                    ),
                  )
                : Column(
                    children: [
                      FractionallySizedBox(
                        widthFactor: 0.5,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.red),
                          ),
                          child: Text('Déconnexion'),
                          onPressed: () {
                            setState(() {
                              userId = "";
                              userIdOk = true;
                            });
                          },
                        ),
                      )
                    ],
                  ),
            FractionallySizedBox(
              widthFactor: 0.5,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                ),
                child: const Text('Liste Produit'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => listeProduitPage(
                              userId: userId,
                            )),
                  );
                },
              ),
            ),
            !userIdOk
                ? FractionallySizedBox(
                    widthFactor: 0.5,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.red),
                      ),
                      child: const Text('Liste Favoris'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => listeFavorisPage(
                                    userId: userId,
                                  )),
                        );
                      },
                    ),
                  )
                : const FractionallySizedBox(),
            !userIdOk
                ? FractionallySizedBox(
                    widthFactor: 0.5,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.red),
                      ),
                      child: const Text('Panier'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Panier(
                                    userId: userId,
                                  )),
                        );
                      },
                    ),
                  )
                : const FractionallySizedBox(),
            !userIdOk
                ? FractionallySizedBox(
                    widthFactor: 0.5,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.red),
                      ),
                      child: const Text('Commande'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ListeCommande(
                                    userId: userId,
                                  )),
                        );
                      },
                    ),
                  )
                : const FractionallySizedBox(),
          ],
        ),
      ),
    );
  }
}
