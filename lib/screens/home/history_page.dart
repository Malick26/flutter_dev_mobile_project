import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../Models/Documents.dart';
import '../../color.dart';
import '../../widgets/drawercertificat.dart';
import '../../widgets/header.dart';
import 'package:dev_mobile/config/api_config.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  bool _isLoading = true;
  List<Document> documents = [];

  @override
  void initState() {
    super.initState();
    fetchDocuments();
  }

  Future<void> fetchDocuments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/mes-certificats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> certificatList = data['certificats'];

        setState(() {
          documents = certificatList.map((json) => Document(
            id: 0,
            nom: 'Certificat de domicile',
            date: json['date_demande'],
            statut: json['statut'],
            nbr: json['nombre_certificats'],
          )).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print('Erreur API : ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Erreur réseau : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Document> filteredDocuments = documents.where((doc) {
      return doc.nom.toLowerCase().contains(_searchTerm.toLowerCase());
    }).toList();

    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            HeaderWidget(
              title: 'Mon Quartier',
              subtitle: 'Historique des documents',
              searchController: _searchController,
              onSearch: (value) {
                setState(() {
                  _searchTerm = value;
                });
              },
            ),
            const SizedBox(height: 10),
            _isLoading
                ? const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: ListView.builder(
                        itemCount: filteredDocuments.length,
                        itemBuilder: (context, index) {
                          final doc = filteredDocuments[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.two,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doc.nom,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Date : ${doc.date}'),
                                    const SizedBox(height: 1),
                                    Text('nombre : ${doc.nbr}'),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: doc.statut == 'En attente'
                                        ? Colors.orange.shade100
                                        : doc.statut == 'Livrée'
                                            ? Colors.green.shade100
                                            : Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    doc.statut,
                                    style: TextStyle(
                                      color: doc.statut == 'En attente'
                                          ? Colors.orange
                                          : doc.statut == 'Livrée'
                                              ? Colors.green
                                              : Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            builder: (context) {
              return DrawerCertificat(
                onClose: (bool added) {
                  Navigator.of(context).pop(added);
                },
              );
            },
          );

          if (result == true) {
            setState(() {
              _isLoading = true;
            });
            await fetchDocuments();
          }
        },
        backgroundColor: AppColors.three,
        child: const Icon(Icons.add),
      ),
    );
  }
}
