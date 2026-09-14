import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  bool _isLoading = false;

  // Fungsi untuk mengirim data ke API Backend
  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/v1/posts/posts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': _titleController.text.trim(),
          'content': _contentController.text.trim(),
          'imageUrl': _imageUrlController.text.trim(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Artikel berhasil ditambahkan!'),
              backgroundColor: Color.fromARGB(255, 157, 98, 40),
            ),
          );
          _clearForm();
        }
      } else {
        throw Exception('Gagal menambahkan artikel');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearForm() {
    _titleController.clear();
    _contentController.clear();
    _imageUrlController.clear();
    setState(() {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color.fromARGB(255, 157, 98, 40);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title
              const Text(
                'Buat Artikel Baru ✍️',
                style: TextStyle(
                  fontFamily: 'Comic Relief',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Bagikan informasi atau kabar bencana alam terkini.',
                style: TextStyle(
                  fontFamily: 'Comic Relief',
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 20),

              // Preview Gambar Banner (jika URL terisi)
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _imageUrlController,
                builder: (context, value, child) {
                  final url = value.text.trim();
                  return Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 245, 233, 220),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: primaryColor.withOpacity(0.3)),
                    ),
                    child: url.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              url,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildImagePlaceholder('URL Gambar Tidak Valid'),
                            ),
                          )
                        : _buildImagePlaceholder('Pratinjau Gambar Banner'),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Input Judul Artikel
              TextFormField(
                controller: _titleController,
                style: const TextStyle(fontFamily: 'Comic Relief'),
                decoration: _inputDecoration(
                  label: 'Judul Artikel',
                  hint: 'Masukkan judul artikel...',
                  icon: Icons.title,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul artikel tidak boleh kosong';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Input URL Gambar Banner
              TextFormField(
                controller: _imageUrlController,
                style: const TextStyle(fontFamily: 'Comic Relief'),
                decoration: _inputDecoration(
                  label: 'URL Gambar Banner',
                  hint: 'https://example.com/gambar.jpg',
                  icon: Icons.image_outlined,
                ),
                onChanged: (val) => setState(() {}),
              ),

              const SizedBox(height: 16),

              // Input Konten / Isi Artikel
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                style: const TextStyle(fontFamily: 'Comic Relief'),
                decoration: _inputDecoration(
                  label: 'Isi Artikel / Penjelasan',
                  hint: 'Tuliskan detail penjelasan artikel di sini...',
                  icon: Icons.article_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Isi artikel tidak boleh kosong';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Tombol Submit
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  icon: _isLoading
                      ? const SizedBox.shrink()
                      : const Icon(Icons.send_rounded, color: Colors.white),
                  label: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Publish Artikel',
                          style: TextStyle(
                            fontFamily: 'Comic Relief',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(String text) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 40,
          color: const Color.fromARGB(255, 157, 98, 40).withOpacity(0.6),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Comic Relief',
            fontSize: 12,
            color: const Color.fromARGB(255, 157, 98, 40).withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    const primaryColor = Color.fromARGB(255, 157, 98, 40);
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(
        fontFamily: 'Comic Relief',
        color: primaryColor,
      ),
      hintStyle: TextStyle(
        fontFamily: 'Comic Relief',
        color: Colors.grey.shade400,
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, color: primaryColor),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
    );
  }
}