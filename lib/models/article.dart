class Article {
  final int id;
  final int categoryId;
  final String title;
  final String content;
  final String? imageUrl;
  final String status;
  final String createdAt;
  final String updatedAt;

  Article({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      categoryId: json['categoryId'],
      title: json['title'],
      content: json['content'],
      imageUrl: json['imageUrl'],
      status: json['status'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}