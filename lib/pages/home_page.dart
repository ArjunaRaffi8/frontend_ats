import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/api_service.dart';
import 'create_article_page.dart';
import 'category_page.dart';
import 'detail_articel_page.dart'; // Pastikan file detail artikel sudah di-import

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Article> _articles = [];
  List<Article> _filteredArticles = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  Future<void> _fetchArticles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final articles = await ApiService.getPosts();
      setState(() {
        _articles = articles;
        _filteredArticles = articles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan koneksi ke server.';
        _isLoading = false;
      });
    }
  }

  void _filterArticles(String query) {
    setState(() {
      _filteredArticles = _articles
          .where((article) =>
              article.title.toLowerCase().contains(query.toLowerCase()) ||
              article.categoryName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _deleteArticle(int id) async {
    try {
      await ApiService.deletePost(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Artikel berhasil dihapus')),
      );
      _fetchArticles();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus artikel')),
      );
    }
  }

  void _openCreateArticle() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateArticlePage(onSaved: _fetchArticles),
      ),
    );
  }

  void _openEditArticle(Article article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateArticlePage(article: article, onSaved: _fetchArticles),
      ),
    );
  }

  void _openCategories() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CategoryPage()),
    ).then((_) => _fetchArticles());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Blog'),
        actions: [
          IconButton(
            tooltip: 'Kelola Kategori',
            icon: const Icon(Icons.category_outlined),
            onPressed: _openCategories,
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _fetchArticles,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _filterArticles,
              decoration: InputDecoration(
                hintText: 'Cari artikel atau kategori...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchController,
                  builder: (context, value, _) {
                    return value.text.isEmpty
                        ? const SizedBox.shrink()
                        : IconButton(
                            tooltip: 'Bersihkan',
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterArticles('');
                            },
                          );
                  },
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text(_errorMessage, style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _fetchArticles,
                              child: const Text('Coba Lagi'),
                            )
                          ],
                        ),
                      )
                    : _filteredArticles.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inbox_outlined,
                                    size: 48, color: Colors.grey.shade600),
                                const SizedBox(height: 12),
                                const Text('Tidak ada artikel ditemukan',
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchArticles,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                              itemCount: _filteredArticles.length,
                              itemBuilder: (context, index) {
                                final article = _filteredArticles[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  clipBehavior: Clip.antiAlias,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
                                        Image.network(
                                          article.imageUrl!,
                                          height: 170,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, progress) {
                                            if (progress == null) return child;
                                            return Container(
                                              height: 170,
                                              alignment: Alignment.center,
                                              child: const CircularProgressIndicator(),
                                            );
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              height: 170,
                                              color: Colors.grey.shade900,
                                              alignment: Alignment.center,
                                              child: const Icon(Icons.broken_image,
                                                  color: Colors.grey, size: 40),
                                            );
                                          },
                                        ),
                                      Padding(
                                        padding: const EdgeInsets.all(14),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    article.title,
                                                    style: const TextStyle(
                                                        fontWeight: FontWeight.bold, fontSize: 16),
                                                  ),
                                                ),
                                                PopupMenuButton<String>(
                                                  icon: const Icon(Icons.more_vert, size: 20),
                                                  onSelected: (value) {
                                                    if (value == 'delete') {
                                                      _deleteArticle(article.id);
                                                    } else if (value == 'edit') {
                                                      _openEditArticle(article);
                                                    }
                                                  },
                                                  itemBuilder: (context) => [
                                                    const PopupMenuItem(
                                                      value: 'edit',
                                                      child: Text('Edit'),
                                                    ),
                                                    const PopupMenuItem(
                                                      value: 'delete',
                                                      child: Text('Hapus',
                                                          style: TextStyle(color: Colors.redAccent)),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            // Ketika chip kategori ditekan, buka DetailArtikelPage
                                            ActionChip(
                                              label: Text(
                                                article.categoryName,
                                                style: const TextStyle(fontSize: 11, color: Colors.white),
                                              ),
                                              backgroundColor: Colors.deepPurple,
                                              visualDensity: VisualDensity.compact,
                                              padding: EdgeInsets.zero,
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => DetailArtikelPage(
                                                      article: {
                                                        'title': article.title,
                                                        'author': 'Admin', // Sesuaikan jika ada field author di model
                                                        'date': 'Hari ini', // Sesuaikan jika ada field date
                                                        'content': article.content,
                                                        'image': article.imageUrl ?? '',
                                                      },
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              article.content,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(color: Colors.grey.shade400, height: 1.4),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateArticle,
        child: const Icon(Icons.add),
      ),
    );
  }
}