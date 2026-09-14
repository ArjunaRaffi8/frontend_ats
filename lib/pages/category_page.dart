import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List _categories = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse(ApiConfig.categoriesUrl));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        setState(() {
          _categories = body['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat kategori';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Tidak dapat terhubung ke server';
        _isLoading = false;
      });
    }
  }

  Future<void> _addCategory() async {
    final nameController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Tambah Kategori',
          style: TextStyle(fontFamily: 'Comic Relief'),
        ),
        content: TextField(
          controller: nameController,
          autofocus: true,
          style: const TextStyle(fontFamily: 'Comic Relief'),
          decoration: const InputDecoration(
            hintText: 'Nama kategori',
            hintStyle: TextStyle(fontFamily: 'Comic Relief'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, nameController.text.trim()),
            child: const Text(
              'Simpan',
              style: TextStyle(color: Color.fromARGB(255, 157, 98, 40)),
            ),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.categoriesUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': result}),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kategori berhasil ditambahkan'),
              backgroundColor: Color.fromARGB(255, 157, 98, 40),
            ),
          );
        }
        _fetchCategories();
      } else {
        throw Exception('Gagal menambahkan kategori');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _editCategory(Map category) async {
    final nameController = TextEditingController(text: category['name']);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Edit Kategori',
          style: TextStyle(fontFamily: 'Comic Relief'),
        ),
        content: TextField(
          controller: nameController,
          autofocus: true,
          style: const TextStyle(fontFamily: 'Comic Relief'),
          decoration: const InputDecoration(
            hintText: 'Nama kategori',
            hintStyle: TextStyle(fontFamily: 'Comic Relief'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, nameController.text.trim()),
            child: const Text(
              'Simpan',
              style: TextStyle(color: Color.fromARGB(255, 157, 98, 40)),
            ),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;

    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.categoriesUrl}/${category['id']}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': result}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kategori berhasil diperbarui'),
              backgroundColor: Color.fromARGB(255, 157, 98, 40),
            ),
          );
        }
        _fetchCategories();
      } else {
        throw Exception('Gagal memperbarui kategori');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _deleteCategory(Map category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text('Hapus kategori "${category['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.categoriesUrl}/${category['id']}'),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kategori berhasil dihapus'),
              backgroundColor: Color.fromARGB(255, 157, 98, 40),
            ),
          );
        }
        _fetchCategories();
      } else {
        throw Exception('Gagal menghapus kategori');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color.fromARGB(255, 157, 98, 40);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primaryColor),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 56, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          fontFamily: 'Comic Relief',
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _fetchCategories,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
                        label: const Text(
                          'Coba Lagi',
                          style: TextStyle(fontFamily: 'Comic Relief', color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: primaryColor,
                  onRefresh: _fetchCategories,
                  child: _categories.isEmpty
                      ? ListView(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 80),
                              child: Column(
                                children: [
                                  Icon(Icons.category_outlined,
                                      size: 60, color: Colors.grey.shade300),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Belum ada kategori',
                                    style: TextStyle(
                                      fontFamily: 'Comic Relief',
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(255, 245, 233, 220),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.label_outline,
                                      color: primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      category['name'] ?? '',
                                      style: const TextStyle(
                                        fontFamily: 'Comic Relief',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 20),
                                    color: Colors.grey.shade600,
                                    onPressed: () => _editCategory(category),
                                    tooltip: 'Edit',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 20),
                                    color: Colors.red.shade400,
                                    onPressed: () => _deleteCategory(category),
                                    tooltip: 'Hapus',
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}
