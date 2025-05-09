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
  List<Map<String, dynamic>> mealItems = [];
  List<Map<String, dynamic>> snackItems = [];
  List<Map<String, dynamic>> riceItems = []; // เพิ่มรายการข้าว
  List<Map<String, dynamic>> filteredMealItems = [];
  List<Map<String, dynamic>> filteredSnackItems = [];
  List<Map<String, dynamic>> filteredRiceItems = []; // เพิ่มรายการข้าว
  List<Map<String, dynamic>> favoriteMeals = [];
  List<Map<String, dynamic>> favoriteSnacks = [];
  List<Map<String, dynamic>> favoriteRices = []; // เพิ่มรายการข้าวที่ชื่นชอบ
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  bool showFavoritesOnly = false;

  @override
  void initState() {
    super.initState();
    _loadAllMenuItems();
    _loadFavoriteFoods();
  }

  void _loadAllMenuItems() async {
    List<Map<String, dynamic>> allMealItems = [];
    List<Map<String, dynamic>> allSnackItems = [];
    List<Map<String, dynamic>> allRiceItems = []; // เพิ่มรายการข้าว
    var diseases = ['Hypertension', 'Obesity', 'kidney disease'];

    for (var disease in diseases) {
      var mealsSnapshot = await FirebaseFirestore.instance
          .collection('disease')
          .doc(disease)
          .collection('meals')
          .get();
      var snacksSnapshot = await FirebaseFirestore.instance
          .collection('disease')
          .doc(disease)
          .collection('snacks')
          .get();

      for (var doc in mealsSnapshot.docs) {
        allMealItems.add(doc.data());
      }
      for (var doc in snacksSnapshot.docs) {
        allSnackItems.add(doc.data());
      }
    }

    // โหลดข้อมูลชนิดข้าว
    var riceSnapshot = await FirebaseFirestore.instance
        .collection('menu')
        .doc('rices')
        .collection('Types of Rice')
        .get();

    for (var doc in riceSnapshot.docs) {
      allRiceItems.add(doc.data());
    }

    allMealItems.sort((a, b) =>
        a['food_name'].toString().compareTo(b['food_name'].toString()));
    allSnackItems.sort((a, b) =>
        a['food_name'].toString().compareTo(b['food_name'].toString()));
    allRiceItems.sort((a, b) =>
        a['food_name'].toString().compareTo(b['food_name'].toString()));

    setState(() {
      mealItems = allMealItems;
      snackItems = allSnackItems;
      riceItems = allRiceItems; // จัดเก็บข้อมูลชนิดข้าว
      filteredMealItems = allMealItems;
      filteredSnackItems = allSnackItems;
      filteredRiceItems = allRiceItems; // จัดเก็บข้อมูลชนิดข้าว
    });
  }

  void _loadFavoriteFoods() async {
    if (userId.isEmpty) {
      print("User not logged in");
      return;
    }

    var mealsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorite_meals')
        .get();

    var snacksSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorite_snacks')
        .get();

    var ricesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorite_rices')
        .get();

    setState(() {
      favoriteMeals = mealsSnapshot.docs
          .map((doc) => {
                'food_name': doc['food_name'].toString(),
                'calories': doc['calories'] is num
                    ? doc['calories']
                    : int.tryParse(doc['calories'] ?? '0') ?? 0
              })
          .toList();

      favoriteSnacks = snacksSnapshot.docs
          .map((doc) => {
                'food_name': doc['food_name'].toString(),
                'calories': doc['calories'] is num
                    ? doc['calories']
                    : int.tryParse(doc['calories'] ?? '0') ?? 0
              })
          .toList();

      favoriteRices = ricesSnapshot.docs
          .map((doc) => {
                'food_name': doc['food_name'].toString(),
                'calories': doc['calories'] is num
                    ? doc['calories']
                    : int.tryParse(doc['calories'] ?? '0') ?? 0
              })
          .toList();
    });
  }

  void _filterMenuItems(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredMealItems = mealItems;
        filteredSnackItems = snackItems;
        filteredRiceItems = riceItems;
      } else {
        filteredMealItems = mealItems
            .where((item) => item['food_name'].toString().contains(query))
            .toList();
        filteredSnackItems = snackItems
            .where((item) => item['food_name'].toString().contains(query))
            .toList();
        filteredRiceItems = riceItems
            .where((item) => item['food_name'].toString().contains(query))
            .toList();
      }
    });
  }

  void _filterMenuByDisease(String disease) async {
    if (disease == "ทั้งหมด") {
      setState(() {
        filteredMealItems = mealItems;
        filteredSnackItems = snackItems;
        filteredRiceItems = riceItems;
        selectedDisease = null;
      });
      return;
    }

    List<Map<String, dynamic>> diseaseMealItems = [];
    List<Map<String, dynamic>> diseaseSnackItems = [];
    List<Map<String, dynamic>> diseaseRiceItems = [];

    var mealsSnapshot = await FirebaseFirestore.instance
        .collection('disease')
        .doc(disease)
        .collection('meals')
        .get();
    var snacksSnapshot = await FirebaseFirestore.instance
        .collection('disease')
        .doc(disease)
        .collection('snacks')
        .get();

    // โหลดเฉพาะเมนูข้าวตามโรคที่เลือก
    var riceSnapshot = await FirebaseFirestore.instance
        .collection('disease')
        .doc(disease)
        .collection('rice')
        .get();

    for (var doc in mealsSnapshot.docs) {
      diseaseMealItems.add(doc.data());
    }
    for (var doc in snacksSnapshot.docs) {
      diseaseSnackItems.add(doc.data());
    }
    for (var doc in riceSnapshot.docs) {
      diseaseRiceItems.add(doc.data());
    }

    diseaseMealItems.sort((a, b) =>
        a['food_name'].toString().compareTo(b['food_name'].toString()));
    diseaseSnackItems.sort((a, b) =>
        a['food_name'].toString().compareTo(b['food_name'].toString()));
    diseaseRiceItems.sort((a, b) =>
        a['food_name'].toString().compareTo(b['food_name'].toString()));

    setState(() {
      selectedDisease = disease;
      filteredMealItems = diseaseMealItems;
      filteredSnackItems = diseaseSnackItems;
      filteredRiceItems = diseaseRiceItems; // กรองเมนูข้าวเฉพาะโรค
    });
  }

  void _showFilterDialog() {
    List<String> diseases = [
      "ทั้งหมด",
      "โรคความดันโลหิตสูง",
      "โรคอ้วน",
      "โรคไต"
    ];
    diseases.sort((a, b) => a.compareTo(b));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('เลือกโรค'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: diseases.map((disease) {
              return ListTile(
                title: Text(disease),
                onTap: () {
                  if (disease == "ทั้งหมด") {
                    _filterMenuByDisease("ทั้งหมด");
                  } else if (disease == "โรคความดันโลหิตสูง") {
                    _filterMenuByDisease("Hypertension");
                  } else if (disease == "โรคอ้วน") {
                    _filterMenuByDisease("Obesity");
                  } else if (disease == "โรคไต") {
                    _filterMenuByDisease("kidney disease");
                  }
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _toggleShowFavorites() {
    setState(() {
      showFavoritesOnly = !showFavoritesOnly;
    });
  }

  void _toggleFavorite(
      String foodName, dynamic calories, String imageUrl, bool isMeal,
      {bool isRice = false}) async {
    if (userId.isEmpty) {
      print("User not logged in");
      return;
    }

    final collection = isMeal
        ? 'favorite_meals'
        : (isRice ? 'favorite_rices' : 'favorite_snacks');
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection(collection)
        .doc(foodName);

    final parsedCalories =
        calories is num ? calories : int.tryParse(calories.toString()) ?? 0;
    List<Map<String, dynamic>> favoriteList =
        isMeal ? favoriteMeals : (isRice ? favoriteRices : favoriteSnacks);

    if (favoriteList.any((food) => food['food_name'] == foodName)) {
      await docRef.delete();
      setState(() {
        favoriteList.removeWhere((food) => food['food_name'] == foodName);
      });
    } else {
      await docRef.set({
        'food_name': foodName,
        'calories': parsedCalories,
        'img': imageUrl, // ✅ เพิ่มรูปภาพไปยัง Firebase
      });
      setState(() {
        favoriteList.add({
          'food_name': foodName,
          'calories': parsedCalories,
          'img': imageUrl, // ✅ เพิ่มข้อมูลรูปภาพเข้า favoriteList
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> displayedMealItems =
        showFavoritesOnly ? favoriteMeals : filteredMealItems;
    List<Map<String, dynamic>> displayedSnackItems =
        showFavoritesOnly ? favoriteSnacks : filteredSnackItems;
    List<Map<String, dynamic>> displayedRiceItems =
        showFavoritesOnly ? favoriteRices : filteredRiceItems;

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
          children: [
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
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.grey),
                  onPressed: _showFilterDialog,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: _toggleShowFavorites,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/favorite.png',
                      width: 50,
                      height: 50,
                    ),
                    const Text(
                      'Favorite',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: const Text(
                      'เมนูอาหารไทย',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...displayedMealItems.map((foodData) {
                    final foodName = foodData['food_name'];
                    final calories = foodData['calories'] ?? 'N/A';
                    final isFavorite = favoriteMeals
                        .any((food) => food['food_name'] == foodName);
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MenuScreen(
                              foodName: foodData['food_name'] ?? 'Unknown',
                              calories: foodData['calories'] is num
                                  ? foodData['calories']
                                  : int.tryParse(
                                          foodData['calories'].toString()) ??
                                      0,
                              imageUrl: foodData['img'] ?? '',
                              ingredients: List<String>.from(
                                  foodData['ingredients'] ??
                                      []), // ✅ ส่งค่าเข้า
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
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
                                  backgroundImage:
                                      AssetImage('assets/images/dish.png'),
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
                                Text(
                                  '${calories.toString()} kcal',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color:
                                        isFavorite ? Colors.red : Colors.grey,
                                  ),
                                  onPressed: () {
                                    _toggleFavorite(foodName, calories,
                                        foodData['img'] ?? '', true);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    color: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: const Text(
                      'เมนูของกินเล่น/ขนม',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...displayedSnackItems.map((snackData) {
                    final snackName = snackData['food_name'];
                    final calories = snackData['calories'] ?? 'N/A';
                    final isFavorite = favoriteSnacks
                        .any((food) => food['food_name'] == snackName);
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MenuScreen(
                              foodName: snackData['food_name'] ?? 'Unknown',
                              calories: snackData['calories'] is num
                                  ? snackData['calories']
                                  : int.tryParse(
                                          snackData['calories'].toString()) ??
                                      0,
                              imageUrl: snackData['img'] ??
                                  '', ingredients: List<String>.from(snackData['ingredients'] ?? []),

                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
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
                                  backgroundImage:
                                      AssetImage('assets/images/dish.png'),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  snackName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  '${calories.toString()} kcal',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color:
                                        isFavorite ? Colors.red : Colors.grey,
                                  ),
                                  onPressed: () {
                                    _toggleFavorite(
                                        snackName,
                                        calories,
                                        snackData['img'] ??
                                            '', // ✅ ส่ง URL ของรูปภาพ
                                        false);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    color: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: const Text(
                      'เมนูชนิดข้าว',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...displayedRiceItems.map((riceData) {
                    final riceName = riceData['food_name'];
                    final calories = riceData['calories'] ?? 'N/A';
                    final isFavorite = favoriteRices
                        .any((food) => food['food_name'] == riceName);
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MenuScreen(
                              foodName: riceData['food_name'] ?? 'Unknown',
                              calories: riceData['calories'] is num
                                  ? riceData['calories']
                                  : int.tryParse(
                                          riceData['calories'].toString()) ??
                                      0,
                              imageUrl: riceData['img'] ??
                                  '', ingredients: List<String>.from(riceData['ingredients'] ?? []),

                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
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
                                  backgroundImage:
                                      AssetImage('assets/images/dish.png'),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  riceName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  '${calories.toString()} kcal',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color:
                                        isFavorite ? Colors.red : Colors.grey,
                                  ),
                                  onPressed: () {
                                    _toggleFavorite(
                                        riceName,
                                        calories,
                                        riceData['img'] ??
                                            '', // ✅ ส่ง URL ของรูปภาพไปด้วย
                                        false,
                                        isRice: true);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
