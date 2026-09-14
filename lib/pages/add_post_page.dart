import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../config/api_config.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List _categories = [];
  int? _selectedCategoryId;
  File? _selectedImage;
  bool _isLoading = false;
  bool _isCategoriesLoading = true;

  @override
   void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.categoriesUrl));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        setState(() {
          _categories = body['data'] ?? [];
          _isCategoriesLoading = false;
        });
      } else {
        setState(() {
          _isCategoriesLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isCategoriesLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kategori terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.postsUrl),
      );

      request.fields['categoryId'] = _selectedCategoryId.toString();
      request.fields['title'] = _titleController.text.trim();
      request.fields['content'] = _contentController.text.trim();

      if (_selectedImage != null) {
        var multipartFile = await http.MultipartFile.fromPath(
          'image',
          _selectedImage!.path,
        );
        request.files.add(multipartFile);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Artikel berhasil ditambahkan!'),
              backgroundColor: Color.fromARGB(255, 157, 98, 40),
            ),
          );
          _clearForm();
          Navigator.pop(context, true);
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
    setState(() {
      _selectedImage = null;
      _selectedCategoryId = null;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
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
              const Text(
                'Buat Artikel Baru',
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

              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 245, 233, 220),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: primaryColor.withOpacity(0.3)),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : _buildImagePlaceholder('Tap untuk memilih gambar'),
                ),
              ),

              const SizedBox(height: 20),

              // Category Dropdown
              _isCategoriesLoading
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      decoration: _inputDecoration(
                        label: 'Kategori',
                        hint: 'Pilih kategori',
                        icon: Icons.category_outlined,
                      ),
                      items: _categories.map<DropdownMenuItem<int>>((cat) {
                        return DropdownMenuItem<int>(
                          value: cat['id'],
                          child: Text(
                            cat['name'],
                            style: const TextStyle(fontFamily: 'Comic Relief'),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) return 'Pilih kategori';
                        return null;
                      },
                    ),

              const SizedBox(height: 16),

              // Title Input
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

              // Content Input
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

              // Submit Button
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
