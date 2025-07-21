import 'dart:convert';
import 'dart:io';
import 'package:dev_mobile/providers/auth_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dev_mobile/config/api_config.dart';
import 'package:dev_mobile/screens/auth/loginScreen.dart';
import 'package:dev_mobile/widgets/header.dart';
import 'package:dev_mobile/color.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  File? _cinFile;
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  bool _isUploading = false;

  Future<void> _pickCINFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _cinFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadCinFile() async {
    if (_cinFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userJson = prefs.getString('user');
      if (token == null || userJson == null) throw Exception("Utilisateur non connecté");

      final user = Map<String, dynamic>.from(jsonDecode(userJson));
      final int userId = user['id'];

      final uri = Uri.parse('${ApiConfig.baseUrl}/habitant/$userId/preuve');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('preuve', _cinFile!.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fichier envoyé avec succès')),
        );
        setState(() {
          _cinFile = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Échec de l\'envoi du fichier')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.three,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Changer le mot de passe',
            style: TextStyle(
              color: AppColors.quatre,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildPasswordField('Mot de passe actuel', currentPasswordController),
                const SizedBox(height: 12),
                _buildPasswordField('Nouveau mot de passe', newPasswordController),
                const SizedBox(height: 12),
                _buildPasswordField('Confirmer le nouveau mot de passe', confirmPasswordController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final current = currentPasswordController.text.trim();
                final newPass = newPasswordController.text.trim();
                final confirm = confirmPasswordController.text.trim();

                if (newPass != confirm) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Les mots de passe ne correspondent pas')),
                  );
                  return;
                }

                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString('token');
                if (token == null) return;

                final response = await http.post(
                  Uri.parse('${ApiConfig.baseUrl}/password/update'),
                  headers: {
                    'Authorization': 'Bearer $token',
                    'Content-Type': 'application/json',
                  },
                  body: jsonEncode({
                    'current_password': current,
                    'new_password': newPass,
                    'new_password_confirmation': confirm,
                  }),
                );

                if (response.statusCode == 200) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mot de passe mis à jour avec succès')),
                  );
                } else {
                  final error = jsonDecode(response.body);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error['message'] ?? 'Erreur')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.one,
                foregroundColor: Colors.white,
              ),
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.quatre),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.three,
      body: SafeArea(
        child: Column(
          children: [
            HeaderWidget(
              title: 'Mon Quartier',
              subtitle: 'Paramètres',
              searchController: _searchController,
              onSearch: (value) {
                setState(() {
                  _searchTerm = value;
                });
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCinUploadSection(),
                    const SizedBox(height: 30),
                    const Divider(thickness: 1),
                    const SizedBox(height: 20),
                    const Text(
                      'Autres paramètres',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _buildSettingItem(
                      icon: Icons.lock,
                      title: 'Changer le mot de passe',
                      onTap: _showChangePasswordDialog,
                    ),
                    _buildSettingItem(
                      icon: Icons.logout,
                      title: 'Se déconnecter',
                      onTap: () async {
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        await authProvider.logout();

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Déconnexion réussie')),
                        );

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) =>  LoginScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCinUploadSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Téléverser votre pièce d\'identité (CIN)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickCINFile,
              icon: const Icon(Icons.upload),
              label: const Text('Choisir un fichier'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.one,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_isUploading)
              const Center(child: CircularProgressIndicator())
            else if (_cinFile != null) ...[
              const Text(
                'Fichier sélectionné :',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              _cinFile!.path.endsWith('.pdf')
                  ? Row(
                      children: [
                        const Icon(Icons.picture_as_pdf, size: 40, color: Colors.red),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _cinFile!.path.split('/').last,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _cinFile!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _uploadCinFile,
                icon: const Icon(Icons.send),
                label: const Text('Envoyer le fichier'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ] else
              const Text('Aucun fichier sélectionné'),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.one.withOpacity(0.1),
        child: Icon(icon, color: AppColors.one),
      ),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
