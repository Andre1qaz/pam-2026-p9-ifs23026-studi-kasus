class Shoe {
  final int id;
  final String name;
  final String brand;
  final String category;
  final double price;
  final String description;
  final String createdAt;

  Shoe({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.price,
    required this.description,
    required this.createdAt,
  });

  factory Shoe.fromJson(Map<String, dynamic> j) => Shoe(
        id:          j['id'] as int,
        name:        j['name'] as String,
        brand:       j['brand'] as String,
        category:    j['category'] as String,
        price:       (j['price'] as num).toDouble(),
        description: j['description'] as String,
        createdAt:   j['created_at'] as String,
      );
}
