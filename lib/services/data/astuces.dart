import 'package:flutter/material.dart';
import '../../models/post_model.dart';

final List<Post> astuces = [
  Post(
    id: 1,
    title: 'Optimiser ses courses au marché local',
    category: 'Économies',
    author: 'Marie L.',
    time: '2h',
    content: 'Allez au marché 30 minutes avant la fermeture...',
    likes: 24,
    comments: 8,
    emoji: '🛒',
    color: Colors.green,
  ),


   Post(
      id: 2,
      title: 'Parking gratuit près de la gare',
      category: 'Transport',
      author: 'Pierre M.',
      time:'5h',
      content: 'Rue des Tilleuls, places gratuites après 18h et le weekend. À 3 minutes à pied de la gare !',
      likes: 31,
      comments: 12,
      emoji: '🚗',
      color: Colors.blue,
   ),
     Post(
      id: 3,
      title: 'Pharmacie de garde ce weekend',
      category: 'Santé',
      author: 'Dr. Sophie',
      time: '1j',
      content: 'Pharmacie Centrale ouverte dimanche 9h-12h pour les urgences. Pensez à apporter votre ordonnance !',
      likes: 18,
      comments: 3,
      emoji: '💊',
      color: Colors.red,
     ),
 
];
