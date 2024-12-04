import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterrr/Utils/constants.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class DateSearchScreen extends StatefulWidget {
  const DateSearchScreen({super.key});

  @override
  State<DateSearchScreen> createState() => _DateSearchScreenState();
}

class _DateSearchScreenState extends State<DateSearchScreen> {
  DateTime? selectedDate;
  List<DocumentSnapshot> recipes = [];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });

      _fetchRecipesByDate(selectedDate!);
    }
  }

  Future<void> _fetchRecipesByDate(DateTime date) async {
    final formattedDate =
        DateFormat('yyyy-MM-dd').format(date); // Formater la date
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('recipes') // Remplacez par votre collection Firebase
        .where('date', isEqualTo: formattedDate) // Filtrer selon la date
        .get();

    setState(() {
      recipes = snapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recherche par Date"),
        backgroundColor: kprimaryColor,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.search_normal),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Afficher la date sélectionnée
            if (selectedDate != null)
              Text(
                "Date sélectionnée: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 20),

            // Afficher la liste des recettes
            Expanded(
              child: recipes.isEmpty
                  ? const Center(
                      child: Text("Aucune recette trouvée pour cette date"))
                  : ListView.builder(
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = recipes[index];
                        return ListTile(
                          title: Text(recipe['name']),
                          subtitle: Text("Temps: ${recipe['time']} minutes"),
                          leading: Image.network(
                            recipe['image'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          onTap: () {},
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
