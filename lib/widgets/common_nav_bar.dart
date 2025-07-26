import 'package:flutter/material.dart';

class CommonNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap; // 👈 Made optional

  const CommonNavBar({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
          top: false,
        child: Container(
          height: 60,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Home
              IconButton(
                onPressed: () => onTap?.call(0),
                icon: Image.asset(
                  "assets/images/home.png",
                  height: 25,
                  color: currentIndex == 0 ? Colors.red : Colors.grey,
                ),
              ),
              // Favorites
              IconButton(
                onPressed: () => onTap?.call(1),
                icon: Icon(
                  currentIndex == 1
                      ? Icons.favorite
                      : Icons.favorite_border_outlined,
                  color: Colors.red,
                  size: 30,
                ),
              ),
              // Email
              IconButton(
                onPressed: () => onTap?.call(2),
                icon: const Icon(Icons.email_outlined, color: Colors.red),
              ),
              // My Account
              IconButton(
                onPressed: () => onTap?.call(3),
                icon: Icon(
                  Icons.dehaze,
                  color: currentIndex == 3 ? Colors.red : Colors.grey,
                  size: 35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
