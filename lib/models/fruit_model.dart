class Fruit {
  final String name;
  final int stock;

  Fruit({required this.name, required this.stock});

  factory Fruit.fromJson(Map<String, dynamic> json) {
    return Fruit(name: json['name'], stock: json['stock']);
  }
}
