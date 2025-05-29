import 'package:flutter/material.dart';

class MenuCard extends StatelessWidget {
  final Map<String, dynamic> menu;

  const MenuCard({required this.menu});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: menu['img'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(menu['img'], fit: BoxFit.cover),
                  )
                : Container(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(menu['food_name'], style: TextStyle(fontWeight: FontWeight.bold)),
          Text("แคลอรี่: ${menu['calories']} kcal"),
          Text("วัตถุดิบ: ${menu['ingredients'].join(', ')}", maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
