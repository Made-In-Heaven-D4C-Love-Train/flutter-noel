import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListeCommande extends StatefulWidget {
  final String userId;

  const ListeCommande({Key? key, required this.userId}) : super(key: key);

  @override
  _CommandesPageState createState() => _CommandesPageState();
}

class _CommandesPageState extends State<ListeCommande> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = FirebaseFirestore.instance
        .collection('commande')
        .doc(widget.userId)
        .collection('commande')
        .orderBy('date', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes commandes'),
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
              child: Text('Aucune commande passée.'),
            );
          }
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (BuildContext context, int index) {
              final data = documents[index].data();
              print(data);
              final date = (data['date'] as Timestamp).toDate();
              return ListTile(
                title: Text(data['produit']['nom']),
                subtitle: Text(
                    'Commande du ${int.parse(date.day.toString())}/${int.parse(date.month.toString())}/${date.year}'),
              );
            },
          );
        },
      ),
    );
  }
}
