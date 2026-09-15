import 'package:flutter/material.dart';

class DetailArtikelPage extends StatefulWidget {
  final Map<String, dynamic> article;

  const DetailArtikelPage({super.key, required this.article});

  @override
  State<DetailArtikelPage> createState() => _DetailArtikelPageState();
}

class _DetailArtikelPageState extends State<DetailArtikelPage> {
  final TextEditingController _komentarController = TextEditingController();
  int likeCount = 1;
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Artikel'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.delete, color: Colors.redAccent)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.article['image'] != null && widget.article['image'].toString().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.article['image'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => const SizedBox(),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              widget.article['title'] ?? 'Judul Artikel',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Oleh ${widget.article['author'] ?? 'Admin'} • ${widget.article['date'] ?? ''}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const Divider(height: 32, color: Colors.grey),
            Text(
              widget.article['content'] ?? widget.article['description'] ?? 'Isi artikel tidak tersedia...',
              style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.white70),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isLiked = !isLiked;
                      isLiked ? likeCount++ : likeCount--;
                    });
                  },
                  child: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.redAccent : Colors.grey,
                  ),
                ),
                const SizedBox(width: 6),
                Text('$likeCount', style: const TextStyle(color: Colors.white)),
                const SizedBox(width: 24),
                const Icon(Icons.comment_outlined, size: 20, color: Colors.grey),
                const SizedBox(width: 6),
                const Text('0 komentar', style: TextStyle(color: Colors.grey)),
              ],
            ),
            const Divider(height: 32, color: Colors.grey),
            const Text('Komentar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _komentarController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Tulis komentar...',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurpleAccent),
                  onPressed: () {
                    if (_komentarController.text.isNotEmpty) {
                      _komentarController.clear();
                      FocusScope.of(context).unfocus();
                    }
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}