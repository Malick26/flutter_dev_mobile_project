import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:dev_mobile/config/api_config.dart';

import '../../models/post_model.dart';
import '../../widgets/post_card.dart';
import '../../widgets/add_post_modal.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController searchController = TextEditingController();
  String searchTerm = '';

  List<Post> _allPosts = [];
  bool _isLoadingPosts = true;
  String? _postsErrorMessage;

  final List<String> _astucesCategories = ['Économies', 'Transport', 'Santé'];
  final List<String> _actualitesCategories = ['Aménagement', 'Circulation', 'Événements'];
  

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _fetchPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _isLoadingPosts = true;
      _postsErrorMessage = null;
    });
    try {
      final String apiUrl = '${ApiConfig.baseUrl}/posts';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          _allPosts = jsonResponse.map((data) => Post.fromJson(data)).toList();
        });
      } else {
        setState(() {
          _postsErrorMessage = 'Échec du chargement des posts: ${response.statusCode} - ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _postsErrorMessage = 'Impossible de se connecter au serveur ou erreur de parsing: $e';
      });
    } finally {
      setState(() {
        _isLoadingPosts = false;
      });
    }
  }

  List<Post> getFilteredData() {
    List<Post> currentTabPosts;

    if (_tabController.index == 0) {
      currentTabPosts = _allPosts.where((post) => _astucesCategories.contains(post.category)).toList();
    } else {
      currentTabPosts = _allPosts.where((post) => _actualitesCategories.contains(post.category)).toList();
    }

    if (searchTerm.isEmpty) return currentTabPosts;

    return currentTabPosts.where((item) {
      final lowerSearch = searchTerm.toLowerCase();
      return item.title.toLowerCase().contains(lowerSearch) ||
          item.content.toLowerCase().contains(lowerSearch);
    }).toList();
  }

  void _showAddPostModal() async { 
    int? currentUserId; 

    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user'); 

      if (userString != null && userString.isNotEmpty) {
        final user = jsonDecode(userString); 
        currentUserId = user['id'] as int?; 
      } else {
        print('User data not found in SharedPreferences or is empty.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez vous connecter pour publier un post.')),
        );
        return; 
      }
    } catch (e) {
      print('Error retrieving user ID from SharedPreferences: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la récupération de l\'ID utilisateur.')),
      );
      return; 
    }

    if (currentUserId == null) {
      print('currentUserId is null after retrieval. Cannot open AddPostModal.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID utilisateur introuvable. Impossible de publier.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return AddPostModal(
          currentUserId: currentUserId!, 
          onPostAdded: (newPost) {
            _fetchPosts();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final astucesCount = _allPosts.where((post) => _astucesCategories.contains(post.category)).length;
    final actualitesCount = _allPosts.where((post) => _actualitesCategories.contains(post.category)).length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(150),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[600]!, Colors.indigo[700]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mon Quartier',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Astuces & Actualités',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          onPressed: _showAddPostModal,
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {
                          searchTerm = value;
                        });
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Rechercher...',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.7)),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.blue[600],
              indicatorWeight: 3,
              labelColor: Colors.blue[600],
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('💡 Astuces'),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$astucesCount',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('📰 Actualités'),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$actualitesCount',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoadingPosts
                ? const Center(child: CircularProgressIndicator())
                : _postsErrorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 48),
                              const SizedBox(height: 16),
                              Text(
                                _postsErrorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red, fontSize: 16),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _fetchPosts,
                                child: const Text('Réessayer'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _buildContentList(),
          ),
        ],
      ),
    );
  }

  Widget _buildContentList() {
    final filteredData = getFilteredData();

    if (filteredData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              searchTerm.isNotEmpty
                  ? '🔍'
                  : (_tabController.index == 0 ? '💡' : '📰'),
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              searchTerm.isNotEmpty
                  ? 'Aucun résultat trouvé'
                  : 'Aucune ${_tabController.index == 0 ? 'astuce' : 'actualité'} pour le moment',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              searchTerm.isNotEmpty
                  ? 'Essayez avec d\'autres mots-clés'
                  : 'Soyez le premier à partager !',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            if (searchTerm.isEmpty) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _showAddPostModal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text('Publier maintenant'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredData.length,
      itemBuilder: (context, index) {
        final item = filteredData[index];
        return PostCard(post: item);
      },
    );
  }
}
