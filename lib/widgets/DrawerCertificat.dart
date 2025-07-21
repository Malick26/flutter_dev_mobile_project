import 'package:flutter/material.dart';
import '../../services/certificat_service.dart';
import '../../color.dart';

class DrawerCertificat extends StatefulWidget {
  final void Function(bool added) onClose;

  const DrawerCertificat({required this.onClose});

  @override
  _DrawerCertificatState createState() => _DrawerCertificatState();
}

class _DrawerCertificatState extends State<DrawerCertificat> {
  final _formKey = GlobalKey<FormState>();
  int _nombreCertificats = 1;
  bool livraison = false;
  bool _isLoading = false;

  int get prixTotal {
    int total = _nombreCertificats * 500;
    if (livraison) total += 300;
    return total;
  }

  void _envoyerDemande() async {
    if (_nombreCertificats <= 0) return;

    setState(() => _isLoading = true);

    final service = CertificatService();
    final result = await service.envoyerDemande(
      livraison: livraison ? "Oui" : "Non",
      nombreCertificats: _nombreCertificats,
    );

    setState(() => _isLoading = false);
    widget.onClose(true); // Ferme le drawer

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.three,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          result['success'] ? "Succès" : "Erreur",
          style: TextStyle(
            color: result['success'] ? AppColors.one : Colors.red,
          ),
        ),
        content: Text(
          result['message'],
          style: TextStyle(color: AppColors.quatre),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("OK", style: TextStyle(color: AppColors.one)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.three,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "Demande de Certificat",
                style: TextStyle(
                    color: AppColors.one,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (_nombreCertificats > 1) {
                              setState(() => _nombreCertificats--);
                            }
                          },
                          icon: Icon(Icons.remove_circle_outline,
                              color: AppColors.one),
                        ),
                        Text(
                          '$_nombreCertificats',
                          style: TextStyle(
                              fontSize: 20, color: AppColors.quatre),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() => _nombreCertificats++);
                          },
                          icon: Icon(Icons.add_circle_outline,
                              color: AppColors.one),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SwitchListTile(
                      title: Text("Souhaitez-vous une livraison ?",
                          style: TextStyle(color: AppColors.quatre)),
                      value: livraison,
                      onChanged: (value) {
                        setState(() {
                          livraison = value;
                        });
                      },
                      activeColor: AppColors.one,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Prix total : ${prixTotal} F",
                      style: TextStyle(
                          color: AppColors.one,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? CircularProgressIndicator(color: AppColors.one)
                        : ElevatedButton.icon(
                            onPressed: _envoyerDemande,
                            icon: Icon(Icons.send),
                            label: Text("Envoyer"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.one,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 12),
                            ),
                          ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
