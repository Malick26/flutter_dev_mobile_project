import 'package:flutter/material.dart';
import '../color.dart';

class DrawerCertificat extends StatefulWidget {
  final VoidCallback onClose;

  const DrawerCertificat({Key? key, required this.onClose}) : super(key: key);

  @override
  State<DrawerCertificat> createState() => _DrawerCertificatState();
}

class _DrawerCertificatState extends State<DrawerCertificat> {
  String modeRetrait = 'À Livrer';
  int quantity = 1;
  int basePrice = 500;

  int get totalPrice {
    int total = basePrice * quantity;
    if (modeRetrait == 'À Livrer') {
      total += 300 * quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), 
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // important pour bottom sheet
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ligne fermeture + titre
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                ),
                const Text(
                  'Certificat',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 20),

            // Mode retrait
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(15),
              ),
              child: DropdownButton<String>(
                value: modeRetrait,
                underline: const SizedBox(),
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'À Livrer', child: Text('À Livrer')),
                  DropdownMenuItem(value: 'À Récupérer', child: Text('À Récupérer')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      modeRetrait = val;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 20),

            // Quantité
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Quantité', style: TextStyle(fontSize: 18)),
                  Row(
                    children: [
                      IconButton(
                        onPressed: quantity > 1
                            ? () {
                                setState(() {
                                  quantity--;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Text(
                        '$quantity',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Total + bouton
            Text(
              'Total : $totalPrice FCFA',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.two,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  widget.onClose();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Succès : Vous avez choisi $quantity certificat(s) en mode $modeRetrait.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text(
                  'Effectuer',
                  style: TextStyle(fontSize: 18, color: AppColors.one),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
