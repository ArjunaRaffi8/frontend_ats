import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class CustomNavbar extends StatelessWidget {
  final int currentIndex;

  const CustomNavbar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 400,
            child: SalomonBottomBar(
              currentIndex: currentIndex,
              onTap: (value) {
                if (value == currentIndex) return;
                if (value == 0) {Navigator.pushReplacementNamed(context, "/home");}
                if (value == 1) {Navigator.pushReplacementNamed(context, "/add");}
                if (value == 2) {Navigator.pushReplacementNamed(context, "/category");}
              },
              
              items: [
                SalomonBottomBarItem(
                  icon: const Icon(Icons.home_outlined),
                  title: const Text("Home"),
                  selectedColor: const Color.fromARGB(255, 157, 98, 40),
                ),
                SalomonBottomBarItem(
                  icon: const Icon(Icons.add),
                  title: const Text("Tambah"),
                  selectedColor: const Color.fromARGB(255, 157, 98, 40),
                ),
                SalomonBottomBarItem(
                  icon: const Icon(Icons.category_outlined),
                  title: const Text("Category"),
                  selectedColor: const Color.fromARGB(255, 157, 98, 40),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}