import 'package:flutter/material.dart';
import 'package:flutterrr/Utils/constants.dart';
import 'package:flutterrr/Views/FavoriteRecetteSreen.dart';
import 'package:flutterrr/Views/my_app_home_screen.dart';
import 'package:iconsax/iconsax.dart';

import 'AvisScreen.dart';
import 'DateSearchScreen.dart';

class AppMainScreen extends StatefulWidget {
  const AppMainScreen({super.key});

  @override
  State<AppMainScreen> createState() => _AppMainScreenState();
}

class _AppMainScreenState extends State<AppMainScreen> {
  int selectedIndex = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    pages = [
      const MyAppHomeScreen(),
      FavoriteRecetteScreen(),
      const DateSearchScreen(), // Remplacer Meal Plan par DateSearchScreen
      const AvisScreen(),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconSize: 28,
        currentIndex: selectedIndex,
        selectedItemColor: kprimaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          color: kprimaryColor,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 0 ? Iconsax.home5 : Iconsax.home_1,
            ),
            label: "Accueil",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 1 ? Iconsax.heart5 : Iconsax.heart,
            ),
            label: "Favoris",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 2
                  ? Iconsax.search_normal
                  : Iconsax.search_normal1, // Nouvelle icône de recherche
            ),
            label: "Recherche par Date",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 3 ? Iconsax.message5 : Iconsax.message,
            ),
            label: "Feedbacks",
          ),
        ],
      ),
      body: pages[selectedIndex],
    );
  }

  Widget navBarPage(IconData iconName) {
    return Center(
      child: Icon(
        iconName,
        size: 100,
        color: kprimaryColor,
      ),
    );
  }
}
