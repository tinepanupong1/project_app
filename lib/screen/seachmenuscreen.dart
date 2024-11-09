import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'menuscreen.dart';

class SearchMenuScreen extends StatefulWidget {
  @override
  _SearchMenuScreenState createState() => _SearchMenuScreenState();
}

class _SearchMenuScreenState extends State<SearchMenuScreen> {
  String? selectedDisease;
  List<Map<String, dynamic>> menuItems = [];
  List<Map<String, dynamic>> filteredMenuItems = [];
  List<Map<String, dynamic>> favoriteFoods = [];
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _loadFavoriteFoods();
    filteredMenuItems = menuItems;
  }

  // Load user's favorite foods from Firebase
  void _loadFavoriteFoods() async {
    if (userId.isEmpty) {
      print("User not logged in");
      return;
    }

    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .get();

    setState(() {
      favoriteFoods = snapshot.docs.map((doc) => {
        'food_name': doc['food_name'].toString(),
        'calories': doc['calories'] is num ? doc['calories'] : int.tryParse(doc['calories'] ?? '0') ?? 0
      }).toList();
    });
  }

  // Toggle favorite food in Firebase
  void _toggleFavorite(String foodName, dynamic calories) async {
    if (userId.isEmpty) {
      print("User not logged in");
      return;
    }

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(foodName);

    final parsedCalories = calories is num ? calories : int.tryParse(calories.toString()) ?? 0;

    if (favoriteFoods.any((food) => food['food_name'] == foodName)) {
      await docRef.delete();
      setState(() {
        favoriteFoods.removeWhere((food) => food['food_name'] == foodName);
      });
    } else {
      await docRef.set({
        'food_name': foodName,
        'calories': parsedCalories
      });
      setState(() {
        favoriteFoods.add({
          'food_name': foodName,
          'calories': parsedCalories
        });
      });
    }
  }

  // Filter menu based on selected disease
  void _filterMenuByDisease(String disease) async {
    List<Map<String, dynamic>> allItems = [];

    var mealsSnapshot = await FirebaseFirestore.instance
        .collection('disease')
        .doc(disease)
        .collection('meals')
        .get();

    for (var doc in mealsSnapshot.docs) {
      allItems.add(doc.data());
    }

    var snacksSnapshot = await FirebaseFirestore.instance
        .collection('disease')
        .doc(disease)
        .collection('snacks')
        .get();

    for (var doc in snacksSnapshot.docs) {
      allItems.add(doc.data());
    }

    allItems.sort((a, b) => a['food_name'].compareTo(b['food_name']));

    setState(() {
      menuItems = allItems;
      filteredMenuItems = allItems;
    });
  }

  // Filter menu items based on search query
  void _filterMenuItems(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredMenuItems = menuItems;
      } else {
        filteredMenuItems = menuItems
            .where((item) => item['food_name'].toString().startsWith(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Thai Food',
          style: TextStyle(
            fontFamily: 'Jua',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: _filterMenuItems,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      hintText: "Search Menu",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.grey),
                  onPressed: () {
                    _showFilterDialog();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filteredMenuItems.isEmpty ? favoriteFoods.length : filteredMenuItems.length,
                itemBuilder: (context, index) {
                  final foodData = filteredMenuItems.isEmpty ? favoriteFoods[index] : filteredMenuItems[index];
                  final foodName = foodData['food_name'];
                  final calories = foodData['calories'] ?? 'N/A';
                  final isFavorite = favoriteFoods.any((food) => food['food_name'] == foodName);

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MenuScreen(
                            foodName: foodName,
                            calories: calories is num ? calories : (int.tryParse(calories.toString()) ?? 0),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      margin: const EdgeInsets.symmetric(vertical: 5.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: Colors.transparent,
                                radius: 20,
                                backgroundImage: AssetImage('assets/images/dish.png'),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                foodName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 80,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${calories.toString()} kcal',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : Colors.grey,
                                ),
                                onPressed: () {
                                  _toggleFavorite(foodName, calories);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Filter dialog function
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('เลือกโรค'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('โรคความดันโลหิตสูง'),
                onTap: () {
                  _filterMenuByDisease('Hypertension');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('โรคอ้วน'),
                onTap: () {
                  _filterMenuByDisease('Obesity');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('โรคไต'),
                onTap: () {
                  _filterMenuByDisease('kidney disease');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
