class Car {
  final String brand;
  final String model;
  final int price;
  final String gearSystem;
  final String fuel;
  final String power;
  final String accelaritionBySec;
  final List<String> features;
  final String description;
  final int topSpeed;
  final String image;
  final String category;
  final String year;
  final String id;

  Car({
    required this.brand,
    required this.model,
    required this.price,
    required this.gearSystem,
    required this.fuel,
    required this.power,
    required this.accelaritionBySec,
    required this.features,
    required this.description,
    required this.topSpeed,
    required this.image,
    required this.category,
    required this.year,
    required this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'year': year,
      'price': price,
      'gearSystem': gearSystem,
      'fuel': fuel,
      'power': power,
      'accelaritionBySec': accelaritionBySec,
      'features': features,
      'description': description,
      'topSpeed': topSpeed,
      'image': image,
      'category': category,
      // أضف باقي الخصائص هنا
    };
  }

  // تحويل البيانات من JSON إلى Car object
  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      brand: json['Brand'] ?? 'Unknown',
      model: json['model'] ?? 'Unknown',
      price: json['price'] != null ? int.parse(json['price'].toString()) : 0,
      gearSystem: json['gearSystem'] ?? 'Unknown',
      fuel: json['fuel'] ?? 'Unknown',
      power: json['power'] ?? 'Unknown',
      accelaritionBySec: json['accelaritionBySec'] ?? 'Unknown',
      features:
          json['features'] != null ? List<String>.from(json['features']) : [],
      description: json['discription'] ?? 'No description',
      topSpeed: json['topSpeed'] ?? 0,
      image: json['image'] ?? 'https://via.placeholder.com/150',
      category: json['Category'] ?? 'Unknown',
      year: json['year'] ?? 'Unknown',
      id: json['id'] ?? 'Unknown',
    );
  }
}
