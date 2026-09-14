import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'pages/home_page.dart';
import 'pages/add_post_page.dart';
import 'pages/category_page.dart';

void main() {
  runApp(const BlogApp());
}

class BlogApp extends StatelessWidget {
  const BlogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blog App',
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    AddPostPage(),
    CategoryPage(),
  ];

  final _items = [
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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header Banner Full Kanan-Kiri
            Stack(
              children: [
                Image.asset(
                  'asset/images/bencana_alam.png',
                  width: double.infinity,
                  height: 120, // Sesuaikan tinggi banner yang diinginkan
                  fit: BoxFit.cover,
                ),
                // Judul "BlogId" di atas banner
                Positioned(
                  top: 16,
                  right: 16,
                  child: Row(
                    children: const [
                      Text(
                        'Blog',
                        style: TextStyle(
                          fontFamily: 'Comic Relief',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Id',
                        style: TextStyle(
                          fontFamily: 'Comic Relief',
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // 2. Halaman Utama
            Expanded(
              child: _pages[_currentIndex],
            ),
          ],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 400,
              child: SalomonBottomBar(
                currentIndex: _currentIndex,
                items: _items,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}