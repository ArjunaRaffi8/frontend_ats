import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/api_service.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  static const Color brown = Color.fromARGB(255, 157, 98, 40);

  List<Category> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final categories = await ApiService.getCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat kategori';
        _isLoading = false;
      });
    }
  }

  void _showCategoryDialog({Category? category}) {
    final controller = TextEditingController(text: category?.name ?? '');
    final isEdit = category != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isEdit ? 'Edit Kategori' : 'Tambah Kategori',
          style: const TextStyle(fontFamily: 'Comic Relief', fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(fontFamily: 'Comic Relief'),
          decoration: InputDecoration(
            hintText: 'Nama kategori',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(fontFamily: 'Comic Relief')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: brown),
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(context);

              try {
                if (isEdit) {
                  await ApiService.updateCategory(category.id, name);
                } else {
                  await ApiService.createCategory(name);
                }
                _loadCategories();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(content: Text('Gagal menyimpan: $e')),
                );
              }
            },
            child: const Text('Simpan',
                style: TextStyle(fontFamily: 'Comic Relief', color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Kategori',
            style: TextStyle(fontFamily: 'Comic Relief', fontWeight: FontWeight.bold)),
        content: Text(
          'Yakin ingin menghapus kategori "${category.name}"?',
          style: const TextStyle(fontFamily: 'Comic Relief'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(fontFamily: 'Comic Relief')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ApiService.deleteCategory(category.id);
                _loadCategories();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(content: Text('Gagal menghapus: $e')),
                );
              }
            },
            child: const Text('Hapus',
                style: TextStyle(fontFamily: 'Comic Relief', color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kelola Kategori',
          style: TextStyle(fontFamily: 'Comic Relief', fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: brown))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_off_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(_errorMessage!,
                          style: const TextStyle(fontFamily: 'Comic Relief', color: Colors.grey)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: brown),
                        onPressed: _loadCategories,
                        child: const Text('Coba Lagi',
                            style: TextStyle(fontFamily: 'Comic Relief', color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : _categories.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.category_outlined, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text('Belum ada kategori',
                              style: TextStyle(fontFamily: 'Comic Relief', color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundColor: const Color.fromARGB(255, 235, 220, 205),
                              child: Text(
                                category.name.isNotEmpty ? category.name[0].toUpperCase() : '#',
                                style: const TextStyle(
                                  color: brown,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Comic Relief',
                                ),
                              ),
                            ),
                            title: Text(
                              category.name,
                              style: const TextStyle(fontFamily: 'Comic Relief', fontWeight: FontWeight.w600),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 20, color: brown),
                                  onPressed: () => _showCategoryDialog(category: category),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                                  onPressed: () => _confirmDelete(category),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: brown,
        onPressed: () => _showCategoryDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}