import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../afficherProduit/afficherProduit.dart';

import '../firebase_options.dart';

class listeProduitPage extends StatefulWidget {
  final String userId;

  const listeProduitPage({Key? key, required this.userId});

  @override
  State<listeProduitPage> createState() => _listePageState();
}

class _listePageState extends State<listeProduitPage> {
  bool _isFirebaseInitialized = false;
  String? _selectedCategoryId;

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

  Widget _buildProduitList() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('categorie')
            .doc(_selectedCategoryId)
            .collection('produit')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Erreur de chargement des produits');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.45,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            document.get('nom').toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          Text(
                            document.get('prix').toString() + " euros",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.red),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AfficherProduit(
                                      produitId: document.id,
                                      categorieId:
                                          _selectedCategoryId.toString(),
                                      userId: widget.userId),
                                ),
                              );
                            },
                            child: const Text("Voir Produit"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("Liste Produit"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Text("Catégories"),
            _isFirebaseInitialized
                ? StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('categorie')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text(
                            'Erreur de chargement des catégories');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }

                      return Wrap(
                        spacing: 8.0,
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                          String categorie = document.get('nom').toString();
                          String categorieId = document.id;
                          return ElevatedButton(
                            onPressed: () {
                              // Gérer l'événement de clic du bouton ici
                              setState(() {
                                _selectedCategoryId = categorieId;
                              });
                            },
                            child: Text(categorie),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.red),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  )
                : CircularProgressIndicator(),
            if (_selectedCategoryId != null) _buildProduitList(),
          ],
        ),
      ),
    );
  }
}
