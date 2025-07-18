class Certificat {
  final int id;
  final String nom;
  final String adresse;
  bool isDelivered;

  Certificat({
    required this.id,
    required this.nom,
    this.adresse = 'Adresse inconnue', // valeur par défaut
    this.isDelivered = false,
  });

  factory Certificat.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final statut = json['statut'];
    return Certificat(
      id: json['id'],
      nom: '${user['prenom']} ${user['nom']}',
      adresse: user['quartier']?['nom'] ?? 'Adresse inconnue',
      isDelivered: statut == 'livre',
    );
  }
}
