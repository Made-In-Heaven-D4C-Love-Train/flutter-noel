import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Panier extends StatefulWidget {
  final String userId;

  const Panier({Key? key, required this.userId}) : super(key: key);

  @override
  State<Panier> createState() => _PanierState();
}

class _PanierState extends State<Panier> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = FirebaseFirestore.instance
        .collection('panier')
        .where('userId', isEqualTo: widget.userId)
        .snapshots();
  }

  Future<void> _passerCommande(List<Map<String, dynamic>> produits) async {
    final timestamp = Timestamp.now();
    final commandeData = {
      'userId': widget.userId,
      'date': timestamp,
      'produits': produits,
    };

    try {
      final commandeRef = FirebaseFirestore.instance
          .collection('commande')
          .doc(); // Crée un nouveau document avec un ID généré automatiquement
      await commandeRef.set(commandeData);

      final panierRef = FirebaseFirestore.instance.collection('panier');
      final snapshot =
          await panierRef.where('userId', isEqualTo: widget.userId).get();

      final batch = FirebaseFirestore.instance.batch();
      snapshot.docs.forEach((doc) => batch.delete(doc.reference));
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Commande passée avec succès !'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print('Erreur lors de la passation de la commande : $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Une erreur est survenue lors de la passation de la commande.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panier'),
        backgroundColor: Colors.red,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _stream,
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return const Text('Erreur de chargement des données');
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final documents = snapshot.data!.docs;

          if (documents.isEmpty) {
            return const Center(
              child: Text('Votre panier est vide.'),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    final data = documents[index].data();
                    return ListTile(
                      title: Text(data['produit']['nom']),
                      subtitle: Text('${data['produit']['prix']} euros'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          try {
                            await FirebaseFirestore.instance
                                .collection('panier')
                                .doc(documents[index].id)
                                .delete();
                          } catch (error) {
                            print(
                                'Erreur lors de la suppression du produit du panier : $error');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Une erreur est survenue lors de la suppression du produit du panier.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                ),
                onPressed: () async {
                  final commandesCollection =
                      FirebaseFirestore.instance.collection('commande');

                  final panierDocs = snapshot.data!.docs;

                  final batch = FirebaseFirestore.instance.batch();

                  for (final panierDoc in panierDocs) {
                    final panierData = panierDoc.data();
                    final commandeData = {
                      'userId': widget.userId,
                      'produit': panierData['produit'],
                      'date': DateTime.now(),
                    };
                    final commandeRef = commandesCollection
                        .doc(widget.userId)
                        .collection('commande')
                        .doc();
                    batch.set(commandeRef, commandeData);
                    batch.delete(panierDoc.reference);
                  }

                  try {
                    await batch.commit();
                  } catch (error) {
                    print(
                        'Erreur lors de la sauvegarde des commandes : $error');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Une erreur est survenue lors de la sauvegarde des commandes.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('La commande a bien été passée.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text('Passer commande'),
              ),
            ],
          );
        },
      ),
    );
  }
}
