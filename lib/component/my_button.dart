import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  const MyButton({
    super.key, 
    required this.onTap, 
    required this.hintText
  });

  final Function()? onTap;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 0, 0),
          borderRadius: BorderRadius.zero,
          border: Border.all(
            color: Color.fromARGB(255, 255, 0, 0),
            width: 2.0,
          ),
        ),
        child: Center(
          child: Text(
            hintText,
            style: TextStyle(
              fontFamily: 'Jua',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
