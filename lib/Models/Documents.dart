// models/document.dart
class Document {
  final int id;
  final String nom;
  final String date;
  final String statut;
  final int nbr;

  Document({
    required this.id,
    required this.nom,
    required this.date,
    required this.statut,
    required this.nbr,
  });
}
