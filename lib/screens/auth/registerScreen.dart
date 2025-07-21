import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../color.dart';
import '../../providers/auth_provider.dart';
import 'loginScreen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController prenomController = TextEditingController();
  final TextEditingController nomController = TextEditingController();
  final TextEditingController dateNaissController = TextEditingController();
  final TextEditingController lieuNaissController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final result = await authProvider.register({
      "prenom": prenomController.text.trim(),
      "nom": nomController.text.trim(),
      "date_naiss": dateNaissController.text.trim(),
      "lieu_naiss": lieuNaissController.text.trim(),
      "email": emailController.text.trim(),
      "password": passwordController.text.trim(),
      "quartier_id": 1,
    });

    setState(() {
      _isLoading = false;
    });

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Inscription réussie")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Échec de l'inscription")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text("Inscription")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 40, left: 20, right: 20, top: 10),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: width / 2,
                  height: 150,
                  fit: BoxFit.contain,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Créer votre compte",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 20),
                buildTextField("Prénom", prenomController),
                SizedBox(height: 15),
                buildTextField("Nom", nomController),
                SizedBox(height: 15),
                buildTextField(
                    "Date de naissance (AAAA-MM-JJ)", dateNaissController),
                SizedBox(height: 15),
                buildTextField("Lieu de naissance", lieuNaissController),
                SizedBox(height: 15),
                buildTextField("Email", emailController,
                    keyboard: TextInputType.emailAddress,
                    validator: validateEmail),
                SizedBox(height: 15),
                buildTextField("Mot de passe", passwordController,
                    obscure: true),
                SizedBox(height: 15),
                buildTextField(
                    "Confirmer mot de passe", confirmPasswordController,
                    obscure: true, validator: validateConfirmPassword),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.one,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'S’inscrire',
                            style: TextStyle(
                              color: AppColors.three,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 30),
                Divider(thickness: 1),
                SizedBox(height: 20),
                Row(
                  children: [
                    Text("Déjà un compte ?"),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                        );
                      },
                      child: Text(
                        "Se connecter",
                        style: TextStyle(
                          color: AppColors.one,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {bool obscure = false,
      TextInputType keyboard = TextInputType.text,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez remplir ce champ';
            }
            return null;
          },
    );
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Veuillez entrer un email';
    if (!value.contains('@')) return 'Email invalide';
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value != passwordController.text)
      return 'Les mots de passe ne correspondent pas';
    return null;
  }
}
