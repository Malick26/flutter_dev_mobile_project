import 'package:flutter/material.dart';
import '../../services/certificat_service.dart';
import '../../color.dart';

class DrawerCertificat extends StatefulWidget {
  final VoidCallback onClose;

  const DrawerCertificat({required this.onClose});

  @override
  _DrawerCertificatState createState() => _DrawerCertificatState();
}

class _DrawerCertificatState extends State<DrawerCertificat> {
  final _formKey = GlobalKey<FormState>();
  bool livraison = false;
  int nombreCertificats = 1;
  bool isLoading = false;

  int calculerTotal() {
    int total = 500 * nombreCertificats;
    if (livraison) total += 300; // Livraison une seule fois
    return total;
  }

  Future<void> envoyerDemande() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final service = CertificatService();
    final result = await service.envoyerDemande(
      livraison: livraison ? "oui" : "non",
      nombreCertificats: nombreCertificats,
    );

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'])),
    );

    if (result['success']) {
      widget.onClose(); // Fermer le bottom sheet
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Demande de certificat", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              children: [
                Text("Livraison :"),
                Switch(
                  value: livraison,
                  onChanged: (value) {
                    setState(() => livraison = value);
                  },
                ),
                Text(livraison ? "Oui" : "Non"),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text("Nombre : "),
                SizedBox(width: 20),
                DropdownButton<int>(
                  value: nombreCertificats,
                  items: List.generate(10, (i) => i + 1)
                      .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => nombreCertificats = value);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              "Total à payer : ${calculerTotal()} FCFA",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : envoyerDemande,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.one),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Envoyer", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
