import 'dart:convert';
import 'package:dev_mobile/Models/Cerfificat.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dev_mobile/config/api_config.dart';


class CertificatService {
  final String apiUrl = '${ApiConfig.baseUrl}/certificat/demande';

  Future<Map<String, dynamic>> envoyerDemande({
    required String livraison,
    required int nombreCertificats,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'livraison': livraison,
          'nombre_certificats': nombreCertificats,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Demande envoyée avec succès'};
      } 
      else if (response.statusCode == 403) {
        return {
          'success': false,
          'message':
              'Votre profil n\'a pas encore été validé. Veuillez ajouter une preuve (facture, quittance, etc.). Si c\'est déjà fait, veuillez patienter : la validation prendra au maximum 48 heures.'
        };
      } 
      else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Erreur inconnue'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau'};
    }
  }


    Future<List<Certificat>> fetchCertificats() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('${ApiConfig.baseUrl}/certificats/livreur');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Certificat.fromJson(json)).toList();
    } else {
      throw Exception('Erreur de chargement des certificats');
    }
  }
Future<bool> livrerCertificat(int id) async {
  final url = Uri.parse('${ApiConfig.baseUrl}/certificats/$id/livrer');
  final response = await http.put(url); 

  return response.statusCode == 200;
}

}
