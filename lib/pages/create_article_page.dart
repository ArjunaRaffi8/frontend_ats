import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/article.dart';
import '../services/api_service.dart';

class CreateArticlePage extends StatefulWidget {
  // Kalau `article` diisi, berarti mode EDIT. Kalau null, mode CREATE.
  final Article? article;
  final VoidCallback? onSaved;

  const CreateArticlePage({super.key, this.article, this.onSaved});

  @override
  State<CreateArticlePage> createState() => _CreateArticlePageState();
}

class _CreateArticlePageState extends State<CreateArticlePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  List<Category> _categories = [];
  int? _selectedCategoryId;
  bool _isLoadingCategories = true;
  bool _isSaving = false;

  XFile? _pickedImage;
  Uint8List? _pickedImageBytes;

  bool get isEdit => widget.article != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _titleController.text = widget.article!.title;
      _contentController.text = widget.article!.content;
      _selectedCategoryId = widget.article!.categoryId;
    }
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ApiService.getCategories();
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
        // Kalau belum ada kategori terpilih (mode create), pilih yang pertama
        _selectedCategoryId ??= categories.isNotEmpty ? categories.first.id : null;
      });
    } catch (e) {
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _pickedImage = file;
      _pickedImageBytes = bytes;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ApiService.savePost(
        id: isEdit ? widget.article!.id : null,
        categoryId: _selectedCategoryId!,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        imageFile: _pickedImage,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEdit ? 'Artikel berhasil diperbarui' : 'Artikel berhasil dibuat')),
      );
      widget.onSaved?.call();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Artikel' : 'Buat Artikel Baru'),
      ),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PREVIEW GAMBAR
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _pickedImageBytes != null
                            ? Image.memory(_pickedImageBytes!, fit: BoxFit.cover)
                            : (isEdit && widget.article!.imageUrl != null
                                ? Image.network(widget.article!.imageUrl!, fit: BoxFit.cover)
                                : const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_photo_alternate_outlined,
                                            size: 40, color: Colors.grey),
                                        SizedBox(height: 8),
                                        Text('Ketuk untuk pilih gambar',
                                            style: TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  )),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // JUDUL
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Judul Artikel',
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty) ? 'Judul wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    // DROPDOWN KATEGORI
                    DropdownButtonFormField<int>(
                      value: _categories.any((c) => c.id == _selectedCategoryId)
                          ? _selectedCategoryId
                          : null,
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      items: _categories
                          .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedCategoryId = value),
                      validator: (value) => value == null ? 'Pilih kategori' : null,
                    ),
                    const SizedBox(height: 16),

                    // KONTEN
                    TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: 'Isi Artikel',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 8,
                      validator: (value) =>
                          (value == null || value.trim().isEmpty) ? 'Isi artikel wajib diisi' : null,
                    ),
                    const SizedBox(height: 24),

                    // TOMBOL SIMPAN
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _submit,
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(isEdit ? 'Simpan Perubahan' : 'Publikasikan'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}