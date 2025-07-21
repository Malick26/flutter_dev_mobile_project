import 'package:flutter/material.dart';

class Post {
  final int id;
  final String title;
  final String category;
  final String author;
  final String time;
  final String content;
  final int likes;
  final int comments;
  final String emoji;
  final Color color;
  final int? userId;

  Post({
    required this.id,
    required this.title,
    required this.category,
    required this.author,
    required this.time,
    required this.content,
    required this.likes,
    required this.comments,
    required this.emoji,
    required this.color,
    this.userId,
  });

  factory Post.fromJson(Map<String, dynamic> json) {

    String getSafeString(Map<String, dynamic> json, String key, {String defaultValue = ''}) {
      return (json[key] as String?) ?? defaultValue;
    }

   
    Color colorFromHex(dynamic hexColor) {
      if (hexColor is! String || hexColor.isEmpty) {
        return Colors.grey; 
      }
      String colorString = hexColor.toUpperCase().replaceAll("#", "");
      if (colorString.length == 6) {
        colorString = "FF" + colorString;
      }
      try {
        return Color(int.parse(colorString, radix: 16));
      } catch (e) {
        print('Erreur de parsing de la couleur hex: $hexColor. Utilisation du gris par défaut. Erreur: $e');
        return Colors.grey;
      }
    }

    return Post(
      id: json['id'] as int,
      title: getSafeString(json, 'title'),
      category: getSafeString(json, 'category'),
      author: (json['user'] != null && json['user']['name'] != null)
          ? json['user']['name'] as String
          : 'Auteur Inconnu',
      time: getSafeString(json, 'time'),
      content: getSafeString(json, 'content'),
      likes: json['likes'] as int, 
      comments: json['comments'] as int,
      emoji: getSafeString(json, 'emoji', defaultValue: '❓'),
      color: colorFromHex(json['color']),
      userId: json['user'] != null && json['user']['id'] != null ? json['user']['id'] as int : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'content': content,
      'time': time,
      'user_id': userId,
    };
  }
}
