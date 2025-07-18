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
  });
}
