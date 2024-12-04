import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterrr/Utils/constants.dart';
import 'package:flutterrr/Views/view_all_items.dart';
import 'package:flutterrr/Widget/banner.dart';
import 'package:flutterrr/Widget/food_items_display.dart';
import 'package:flutterrr/Widget/my_icon_button.dart';
import 'package:iconsax/iconsax.dart';

class MyAppHomeScreen extends StatefulWidget {
  const MyAppHomeScreen({super.key});

  @override
  State<MyAppHomeScreen> createState() => _MyAppHomeScreenState();
}

class _MyAppHomeScreenState extends State<MyAppHomeScreen> {
  String category = "All";
  String searchQuery = "";

  // Firebase Firestore references
  final CollectionReference categoriesItems =
      FirebaseFirestore.instance.collection("App-Category");

  Query get filteredRecipes => FirebaseFirestore.instance
      .collection("Complete-Flutter-App")
      .where('category', isEqualTo: category);

  Query get allRecipes =>
      FirebaseFirestore.instance.collection("Complete-Flutter-App");

  Query get selectedRecipes => category == "All" ? allRecipes : filteredRecipes;

  Query get searchFilteredRecipes =>
      selectedRecipes.where("name", isGreaterThanOrEqualTo: searchQuery);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  headerWidget(),
                  searchBarWidget(),
                  const BannerToExplore(),
                  const SizedBox(height: 20),
                  const Text(
                    "Categories",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  categorySelectorWidget(),
                  const SizedBox(height: 20),
                  sectionHeader("Quick & Easy"),
                ],
              ),
            ),
            Expanded(
              child: recipeListWidget(),
            ),
          ],
        ),
      ),
    );
  }

  /// Header Widget
  Row headerWidget() {
    return Row(
      children: [
        const Text(
          "What are you\ncooking today?",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
        const Spacer(),
        MyIconButton(
          icon: Icons.exit_to_app, // Logout icon
          pressed: () async {
            await FirebaseAuth.instance.signOut(); // Sign out from Firebase
            Navigator.pushReplacementNamed(
                context, '/login'); // Navigate to login
          },
        ),
      ],
    );
  }

  /// Search Bar Widget
  Padding searchBarWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: InputDecoration(
          filled: true,
          prefixIcon: const Icon(Iconsax.search_normal),
          fillColor: Colors.white,
          border: InputBorder.none,
          hintText: "Search recipes by name",
          hintStyle: const TextStyle(
            color: Colors.grey,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  /// Category Selector Widget
  StreamBuilder<QuerySnapshot<Object?>> categorySelectorWidget() {
    return StreamBuilder(
      stream: categoriesItems.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: snapshot.data!.docs.map((doc) {
                final categoryName = doc['name'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      category = categoryName;
                      searchQuery =
                          ""; // Reset search query when category changes
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: category == categoryName
                          ? kprimaryColor
                          : Colors.white,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    margin: const EdgeInsets.only(right: 15),
                    child: Text(
                      categoryName,
                      style: TextStyle(
                        color: category == categoryName
                            ? Colors.white
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  /// Section Header Widget
  Row sectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            letterSpacing: 0.1,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ViewAllItems(),
              ),
            );
          },
          child: const Text(
            "View all",
            style: TextStyle(
              color: kBannerColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Recipe List Widget
  StreamBuilder<QuerySnapshot<Object?>> recipeListWidget() {
    return StreamBuilder(
      stream: searchFilteredRecipes.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          final recipes = snapshot.data!.docs;
          if (recipes.isEmpty) {
            return const Center(
              child: Text(
                "No recipes found",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              return FoodItemsDisplay(
                documentSnapshot: recipes[index],
              );
            },
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
