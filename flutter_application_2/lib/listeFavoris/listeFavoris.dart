import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase_options.dart';

class listeFavorisPage extends StatefulWidget {
  final String userId;
  const listeFavorisPage({super.key, required this.userId});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<listeFavorisPage> createState() => _listeFavorisState();
}

class _listeFavorisState extends State<listeFavorisPage> {
  // Créer une instance de Firestore
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Définir un Stream pour les données des favoris
  Stream<QuerySnapshot<Map<String, dynamic>>>? _favorisStream;

  @override
  void initState() {
    super.initState();

    // Initialiser le Stream pour les favoris de l'utilisateur
    _favorisStream = firestore
        .collection('favoris')
        .where('userId', isEqualTo: widget.userId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Liste favoris"),
        backgroundColor: Colors.red,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _favorisStream,
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return Text('Erreur: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          // Récupérer les données des favoris de l'utilisateur courant
          List<QueryDocumentSnapshot<Map<String, dynamic>>> documents = snapshot
              .data!.docs
              .where((doc) => doc['userId'] == widget.userId)
              .toList();

          return Center(
            child: ListView.builder(
              itemCount: documents.length,
              itemBuilder: (BuildContext context, int index) {
                // Créer un widget pour chaque favori
                Map<String, dynamic> favori = documents[index].data();
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.favorite),
                    title: Text(favori.containsKey('nomProduit')
                        ? favori['nomProduit']
                        : 'Nom inconnu'),
                    subtitle: Text(favori.containsKey('descriptionProduit')
                        ? favori['descriptionProduit']
                        : ''),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
