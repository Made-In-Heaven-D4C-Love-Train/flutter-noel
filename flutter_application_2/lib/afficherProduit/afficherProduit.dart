import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AfficherProduit extends StatefulWidget {
  final String produitId;
  final String categorieId;
  final String userId;

  const AfficherProduit(
      {Key? key,
      required this.produitId,
      required this.categorieId,
      required this.userId})
      : super(key: key);

  @override
  State<AfficherProduit> createState() => _AfficherProduitState();
}

class _AfficherProduitState extends State<AfficherProduit> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _stream;
  bool _estDansLesFavoris = false;

  @override
  void initState() {
    super.initState();

    _stream = _db
        .collection('categorie')
        .doc(widget.categorieId)
        .collection('produit')
        .doc(widget.produitId)
        .snapshots();
    _verifierSiDansFavoris();
  }

  Future<void> _verifierSiDansFavoris() async {
    if (widget.userId != null && widget.userId != "") {
      final userId = widget.userId;
      final snapshot = await _db
          .collection('favoris')
          .where('userId', isEqualTo: userId)
          .where('produitId', isEqualTo: widget.produitId)
          .get();

      setState(() {
        _estDansLesFavoris = snapshot.docs.isNotEmpty;
      });
    }
  }

  Future<void> _ajouterAuxFavoris() async {
    if (widget.userId == null || widget.userId == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Veuillez vous connecter pour ajouter des produits aux favoris.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final userId = widget.userId;

    try {
      if (_estDansLesFavoris) {
        // Retirer le produit des favoris
        final snapshot = await _db
            .collection('favoris')
            .where('userId', isEqualTo: userId)
            .where('produitId', isEqualTo: widget.produitId)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final docId = snapshot.docs.first.id;
          await _db.collection('favoris').doc(docId).delete();
        }

        setState(() {
          _estDansLesFavoris = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Le produit a été retiré des favoris.'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Ajouter le produit aux favoris
        final favorisRef = _db.collection('favoris').doc();
        final produitSnapshot = await _db
            .collection('categorie')
            .doc(widget.categorieId)
            .collection('produit')
            .doc(widget.produitId)
            .get();
        await favorisRef.set({
          'id': favorisRef.id,
          'userId': userId,
          'produitId': widget.produitId,
          'nomProduit': produitSnapshot.data()!['nom'],
          'categorieId': widget.categorieId,
        });

        setState(() {
          _estDansLesFavoris = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Le produit a été ajouté aux favoris.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      print('Erreur lors de l\'ajout du produit aux favoris : $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Une erreur est survenue lors de l\'ajout du produit aux favoris.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _ajouterAuPanier(
      BuildContext context, Map<String, dynamic> produit) async {
    try {
      // Vérifier si l'utilisateur est connecté
      if (widget.userId == null || widget.userId == "") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Veuillez vous connecter pour ajouter des produits au panier.'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Récupérer l'ID de l'utilisateur actuel
        final userId = widget.userId;

        // Ajouter le produit au panier
        final panierRef = _db.collection('panier').doc();
        await panierRef.set({
          'id': panierRef.id,
          'userId': userId,
          'produit': produit,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Le produit a été ajouté au panier.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      print('Erreur lors de l\'ajout du produit au panier : $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Une erreur est survenue lors de l\'ajout du produit au panier.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Afficher un produit"),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _stream,
          builder: (BuildContext context,
              AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.hasError) {
              return const Text('Erreur de chargement des données');
            }
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            final data = snapshot.data!.data();
            if (data == null) {
              return const Text('Aucun produit trouvé');
            }

            // Vérifier si le produit est déjà dans les favoris de l'utilisateur
            final bool estFavori = _estDansLesFavoris;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.network(
                  data['lien_image'],
                  height: 200,
                ),
                Text(
                  data['nom'],
                  style: const TextStyle(fontSize: 24.0),
                ),
                Text(
                  'Prix : ${data['prix']} euros',
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 20), // Ajout d'une marge de 20 pixels
                ElevatedButton(
                  onPressed: () {
                    _ajouterAuPanier(context, data);
                  },
                  child: const Text('Ajouter au panier'),
                ),
                const SizedBox(height: 10), // Ajout d'une marge de 10 pixels
                ElevatedButton(
                  onPressed: () {
                    _ajouterAuxFavoris();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        estFavori ? Colors.grey : Colors.green),
                  ),
                  child: Text(estFavori
                      ? 'Déjà dans les favoris'
                      : 'Ajouter aux favoris'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
