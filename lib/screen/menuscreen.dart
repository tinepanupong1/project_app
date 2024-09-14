import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
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
            Navigator.pop(context); // ปุ่มเพื่อปิดหน้าจอ
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // ส่วนของการค้นหาเมนู
            Row(
              children: [
                Expanded(
                  child: TextField(
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
                    // ฟังก์ชันสำหรับการกรองเมนู
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // ปุ่ม Favorite
            Center(
              child: Column(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 40,
                    ),
                    onPressed: () {
                      // ฟังก์ชันสำหรับ Favorite
                    },
                  ),
                  const Text(
                    "Favorite",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // เมนูอาหารไทย
            const Text(
              'เมนูอาหารไทย',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  buildMenuItem('ข้าวมันไก่ต้ม 1 จาน', '585 kcal'),
                  buildMenuItem('ข้าวผัดอเมริกัน 1 จาน', '700 kcal'),
                  buildMenuItem('ผัดซีอิ๊วหมู 1 จาน', '679 kcal'),
                  buildMenuItem('ผัดไทยกุ้งสด 1 จาน', '590 kcal'),
                  buildMenuItem('ข้าวคลุกกะปิ 1 จาน', '614 kcal'),
                  buildMenuItem('ข้าวหมกไก่ 1 จาน', '540 kcal'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันสำหรับสร้างรายการเมนูอาหาร
  Widget buildMenuItem(String foodName, String calories) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.blueAccent,
                radius: 20,
                child: Icon(
                  Icons.food_bank,
                  color: Colors.white,
                ),
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
          Text(
            calories,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
