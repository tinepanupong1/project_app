// maintain_weight_screen.dart
import 'package:flutter/material.dart';

class MaintainWeightScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รักษาน้ำหนัก'),
        backgroundColor: Colors.green.shade100,
      ),
      body: Center(
        child: Text(
          'หน้ารักษาน้ำหนัก',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
