class Article {
  final int id;
  final int categoryId;
  final String title;
  final String content;
  final String categoryName;
  final String? imageUrl;

  Article({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.content,
    required this.categoryName,
    this.imageUrl,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      categoryId: json['categoryId'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      categoryName: json['categoryName'] ?? 'Umum',
      imageUrl: json['imageUrl'],
    );
  }
}

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }
}