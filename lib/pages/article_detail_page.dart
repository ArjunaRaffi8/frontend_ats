import 'package:flutter/material.dart';


class ArticleDetailPage extends StatelessWidget {
  final Map article;

  const ArticleDetailPage({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(''),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar artikel
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: article['imageUrl'] != null &&
                      article['imageUrl'].toString().isNotEmpty
                  ? Image.network(
                      article['imageUrl'].toString(),
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _imagePlaceholder();
                      },
                    )
                  : _imagePlaceholder(),
            ),

            const SizedBox(height: 24),

            // Judul
            Text(
              article['title'] ?? 'Tanpa Judul',
              style: const TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Content
            Text(
              article['content'] ?? 'Tidak ada isi artikel.',
              style: const TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: 18,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 32),

          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Icon(
        Icons.image_outlined,
        size: 60,
        color: Colors.grey,
      ),
    );
  }
}