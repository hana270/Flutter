import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterrr/Provider/favorite_provider.dart';
import 'package:flutterrr/Provider/quantity.dart';
import 'package:flutterrr/Utils/constants.dart';
import 'package:flutterrr/Widget/my_icon_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../Widget/quantity_increment_decrement.dart';

class RecipeDetailScreen extends StatefulWidget {
  final DocumentSnapshot<Object?> documentSnapshot;

  const RecipeDetailScreen({Key? key, required this.documentSnapshot})
      : super(key: key);

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize base ingredient amounts in the provider after widget build
    Future.delayed(Duration.zero, () {
      List<double> baseAmounts = List<double>.from(
        widget.documentSnapshot['ingredientsAmount']
            .map<double>((amount) => double.parse(amount.toString())),
      );
      Provider.of<QuantityProvider>(context, listen: false)
          .setBaseIngredientAmounts(baseAmounts);
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final quantityProvider = Provider.of<QuantityProvider>(context);

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton:
          _buildStartCookingAndFavoriteButton(favoriteProvider),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderSection(),
            _buildRecipeDetails(favoriteProvider, quantityProvider),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Header section with recipe image and navigation buttons
  Widget _buildHeaderSection() {
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height / 2.1,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(widget.documentSnapshot['image']),
            ),
          ),
        ),
        Positioned(
          top: 40,
          left: 10,
          right: 10,
          child: Row(
            children: [
              MyIconButton(
                icon: Icons.arrow_back_ios_new,
                pressed: () {
                  Navigator.pop(context);
                },
              ),
              const Spacer(),
              MyIconButton(
                icon: Icons.exit_to_app,
                pressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Recipe details section including name, metadata, and ingredients
  Widget _buildRecipeDetails(
      FavoriteProvider favoriteProvider, QuantityProvider quantityProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.documentSnapshot['name'],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildRecipeMetaData(),
          const SizedBox(height: 20),
          _buildIngredientsSection(quantityProvider),
        ],
      ),
    );
  }

  // Meta-data for calories, time, and reviews
  Widget _buildRecipeMetaData() {
    return Row(
      children: [
        const Icon(Iconsax.flash_1, size: 20, color: Colors.grey),
        Text(
          "${widget.documentSnapshot['cal']} Cal",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const Text(" · ",
            style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey)),
        const Icon(Iconsax.clock, size: 20, color: Colors.grey),
        const SizedBox(width: 5),
        Text(
          "${widget.documentSnapshot['time']} Min",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const Spacer(),
        Row(
          children: [
            const Icon(Iconsax.star1, color: Colors.amberAccent),
            const SizedBox(width: 5),
            Text(
              widget.documentSnapshot['rate']?.toString() ?? '0',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text("/5"),
            const SizedBox(width: 5),
            Text(
              "${widget.documentSnapshot['reviews'] ?? 0} Reviews",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  // Ingredients section
  Widget _buildIngredientsSection(QuantityProvider quantityProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Ingredients",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Text("How many servings?",
                style: TextStyle(color: Colors.grey)),
            const Spacer(),
            QuantityIncrementDecrement(
              currentNumber: quantityProvider.currentNumber,
              onAdd: quantityProvider.increaseQuantity,
              onRemov: quantityProvider.decreaseQuanity,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildIngredientImages(),
            const SizedBox(width: 20),
            _buildIngredientNames(),
            const Spacer(),
            _buildIngredientAmounts(quantityProvider),
          ],
        ),
      ],
    );
  }

  // Floating action button for cooking and favorites
  FloatingActionButton _buildStartCookingAndFavoriteButton(
      FavoriteProvider provider) {
    return FloatingActionButton.extended(
      backgroundColor: Colors.transparent,
      elevation: 0,
      onPressed: () {},
      label: Row(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kprimaryColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 100, vertical: 13),
              foregroundColor: Colors.white,
            ),
            onPressed: () {},
            child: const Text(
              "Start Cooking",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () {
              provider.toggleFavorite(widget.documentSnapshot);
            },
            icon: Icon(
              provider.isExist(widget.documentSnapshot)
                  ? Iconsax.heart5
                  : Iconsax.heart,
              color: provider.isExist(widget.documentSnapshot)
                  ? Colors.red
                  : Colors.black,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  // Ingredient images
  Widget _buildIngredientImages() {
    return Column(
      children: widget.documentSnapshot['ingredientsImage']
          .map<Widget>((imageUrl) => Container(
                height: 60,
                width: 60,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(imageUrl),
                  ),
                ),
              ))
          .toList(),
    );
  }

  // Ingredient names
  Widget _buildIngredientNames() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.documentSnapshot['ingredientsName']
          .map<Widget>((ingredient) => SizedBox(
                height: 60,
                child: Center(
                  child: Text(
                    ingredient,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  // Ingredient amounts
  Widget _buildIngredientAmounts(QuantityProvider quantityProvider) {
    return Column(
      children: quantityProvider.updateIngredientAmounts
          .map<Widget>((amount) => SizedBox(
                height: 60,
                child: Center(
                  child: Text(
                    "$amount gm",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}
