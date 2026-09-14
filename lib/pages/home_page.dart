import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'article_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List articles = [];
  bool isLoading = true;

  Future<void> getPosts() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.postsUrl),
      );

      if (response.statusCode == 200) {
        setState(() {
          articles = jsonDecode(response.body)['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getPosts();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color.fromARGB(255, 157, 98, 40),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color.fromARGB(255, 157, 98, 40),
      onRefresh: getPosts,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          // Header: greeting + avatar
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi! Good day! 👋',
                      style: TextStyle(
                        fontFamily: 'Comic Relief',
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Temukan dan baca artikel menarik hari ini.',
                      style: TextStyle(
                        fontFamily: 'Comic Relief',
                        fontSize: 14,
                        color: Color.fromARGB(255, 157, 98, 40),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 245, 233, 220),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color.fromARGB(255, 157, 98, 40),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Color.fromARGB(255, 157, 98, 40),
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),

          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Articles',
                style: TextStyle(
                  fontFamily: 'Comic Relief',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 245, 233, 220),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${articles.length} artikel',
                  style: const TextStyle(
                    fontFamily: 'Comic Relief',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 157, 98, 40),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Empty state
          if (articles.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Column(
                children: [
                  Icon(Icons.article_outlined,
                      size: 60, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada artikel',
                    style: TextStyle(
                      fontFamily: 'Comic Relief',
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
          else
            // List vertikal, satu artikel per baris
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: articles.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final article = articles[index];
                return ArticleCard(article: article);
              },
            ),
        ],
      ),
    );
  }
}

class ArticleCard extends StatelessWidget {
  final Map article;

  const ArticleCard({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    final String title = article['title'] ?? 'Tanpa Judul';
    final dynamic image = article['imageUrl'] ?? article['image_url'];
    final String content = article['content'] ?? '';

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailPage(article: article),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar di kiri
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 100,
                height: 100,
                child: image != null && image.toString().isNotEmpty
                    ? Image.network(
                        image.toString(),
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color.fromARGB(255, 157, 98, 40),
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return _imagePlaceholder();
                        },
                      )
                    : _imagePlaceholder(),
              ),
            ),

            const SizedBox(width: 14),

            // Judul + cuplikan konten di kanan
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Comic Relief',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (content.isNotEmpty)
                    Text(
                      content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Comic Relief',
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        height: 1.3,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 12,
                        color: Color.fromARGB(255, 157, 98, 40),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Baca selengkapnya',
                        style: TextStyle(
                          fontFamily: 'Comic Relief',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 157, 98, 40),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 28,
          color: Colors.grey,
        ),
      ),
    );
  }
}