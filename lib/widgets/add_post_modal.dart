import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/post_model.dart';
import 'package:dev_mobile/color.dart';
import 'package:dev_mobile/config/api_config.dart';

class AddPostModal extends StatefulWidget {
  final Function(Post) onPostAdded;
  final int currentUserId;

  const AddPostModal({
    Key? key,
    required this.onPostAdded,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<AddPostModal> createState() => _AddPostModalState();
}

class _AddPostModalState extends State<AddPostModal> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _content = '';
  String? _selectedCategory;
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _categories = [
    'Aménagement',
    'Circulation',
    'Événements',
    'Économies',
    'Transport',
    'Santé',
  ];

  Future<void> _submitPost() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final String apiUrl = '${ApiConfig.baseUrl}/posts';
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
          },
          body: jsonEncode(<String, dynamic>{
            'user_id': widget.currentUserId,
            'category': _selectedCategory,
            'title': _title,
            'content': _content,
          }),
        );

        if (response.statusCode == 201) {
          final Map<String, dynamic> responseData =
              jsonDecode(response.body)['post'];
          final newPost = Post.fromJson(responseData);
          widget.onPostAdded(newPost);
          Navigator.of(context).pop();
        } else {
          final errorBody = jsonDecode(response.body);
          setState(() {
            _errorMessage =
                errorBody['message'] ?? 'Erreur lors de la création du post.';
            if (errorBody['errors'] != null) {
              errorBody['errors'].forEach((key, value) {
                _errorMessage = '$_errorMessage\n${value[0]}';
              });
            }
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Impossible de se connecter au serveur: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Créer un nouveau Post',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.quatre,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Titre du Post',
                  labelStyle: TextStyle(color: AppColors.one),
                  filled: true,
                  fillColor: AppColors.three,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: AppColors.one, width: 2),
                  ),
                  prefixIcon: Icon(Icons.title, color: AppColors.one),
                ),
                maxLength: 100,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Catégorie',
                  labelStyle: TextStyle(color: AppColors.one),
                  filled: true,
                  fillColor: AppColors.three,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: AppColors.one, width: 2),
                  ),
                  prefixIcon: Icon(Icons.category, color: AppColors.one),
                ),
                value: _selectedCategory,
                hint: Text('Sélectionnez une catégorie',
                    style: TextStyle(color: AppColors.one.withOpacity(0.7))),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner une catégorie.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _selectedCategory = value;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Contenu du Post',
                  labelStyle: TextStyle(color: AppColors.one),
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: AppColors.three,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: AppColors.one, width: 2),
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(
                        bottom: 80.0, left: 0, right: 0, top: 0),
                    child: Icon(Icons.description, color: AppColors.one),
                  ),
                ),
                maxLines: 5,
                minLines: 3,
                maxLength: 500,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le contenu du post.';
                  }
                  if (value.length > 500) {
                    return 'Le contenu est trop long (max 500 caractères).';
                  }
                  return null;
                },
                onSaved: (value) {
                  _content = value!;
                },
              ),
              const SizedBox(height: 30),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitPost,
                icon: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Icon(Icons.send, size: 24),
                label: Text(
                  _isLoading ? 'Envoi en cours...' : 'Publier le Post',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.one,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 8,
                  shadowColor: AppColors.one.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
