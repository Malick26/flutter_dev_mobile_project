import 'package:flutter/material.dart';
import '../../services/certificat_service.dart';
import '../../Models/Cerfificat.dart';
import '../../widgets/header.dart';

class Livreur extends StatefulWidget {
  const Livreur({super.key});

  @override
  State<Livreur> createState() => _LivreurState();
}

class _LivreurState extends State<Livreur> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  late Future<List<Certificat>> _certificatsFuture;
  final CertificatService _service = CertificatService();

  @override
  void initState() {
    super.initState();
    _certificatsFuture = _service.fetchCertificats();
  }

  void _refresh() {
    setState(() {
      _certificatsFuture = _service.fetchCertificats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            HeaderWidget(
              title: 'Mon Quartier',
              subtitle: 'Historique Livreur',
              searchController: _searchController,
              onSearch: (value) {
                setState(() {
                  _searchTerm = value;
                });
              },
            ),
            Expanded(
              child: FutureBuilder<List<Certificat>>(
                future: _certificatsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  }

                  final documents = snapshot.data ?? [];

                  final toDeliver = documents.where((doc) =>
                    !doc.isDelivered &&
                    (doc.nom.toLowerCase().contains(_searchTerm.toLowerCase()) ||
                     doc.adresse.toLowerCase().contains(_searchTerm.toLowerCase()))
                  ).toList();

                  final delivered = documents.where((doc) =>
                    doc.isDelivered &&
                    (doc.nom.toLowerCase().contains(_searchTerm.toLowerCase()) ||
                     doc.adresse.toLowerCase().contains(_searchTerm.toLowerCase()))
                  ).toList();

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (toDeliver.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Livraisons à effectuer',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              ...toDeliver.map((doc) => _buildDocCard(doc)).toList(),
                            ],
                          ),
                        const SizedBox(height: 24),
                        if (delivered.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Livraisons effectuées',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              ...delivered.map((doc) => _buildDocCard(doc)).toList(),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocCard(Certificat doc) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: doc.isDelivered ? Colors.green : Colors.orange,
          child: Icon(
            doc.isDelivered ? Icons.check : Icons.delivery_dining,
            color: Colors.white,
          ),
        ),
        title: Text(doc.nom),
        subtitle: Text(doc.adresse),
        trailing: doc.isDelivered
            ? const Icon(Icons.check_circle, color: Colors.green)
            : ElevatedButton(
                onPressed: () async {
                  final success = await _service.livrerCertificat(doc.id);
                  if (success) {
                    setState(() {
                      doc.isDelivered = true;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Échec de la livraison")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Marquer livré', style: TextStyle(fontSize: 12)),
              ),
      ),
    );
  }
}
