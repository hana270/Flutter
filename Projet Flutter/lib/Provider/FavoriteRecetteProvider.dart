import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FavoriteProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = "user123"; // Remplacez par l'ID utilisateur réel

  // Vérifier si une recette existe dans les favoris
  Future<bool> isExist(DocumentSnapshot<Object?> recipe) async {
    final favoriteDoc = await _firestore
        .collection('favorites')
        .doc(userId)
        .collection('userFavorites')
        .doc(recipe.id)
        .get();
    return favoriteDoc.exists;
  }

  // Ajouter ou supprimer une recette des favoris
  Future<void> toggleFavorite(DocumentSnapshot<Object?> recipe) async {
    final recipeId = recipe.id;
    final favoriteDoc = _firestore
        .collection('favorites')
        .doc(userId)
        .collection('userFavorites')
        .doc(recipeId);

    final exists = await isExist(recipe);

    if (exists) {
      await favoriteDoc.delete();
    } else {
      await favoriteDoc.set({
        'recipeId': recipeId,
        'name': recipe['name'],
        'image': recipe['image'],
        'category': recipe['category'] ?? 'Uncategorized',
        'cal': recipe['cal'],
        'time': recipe['time'],
        'rate': recipe['rate'],
        'addedAt': DateTime.now(),
      });
    }
    notifyListeners();
  }
}
