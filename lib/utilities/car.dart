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
  final bool isAvailable;

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
    required this.isAvailable,
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
      'isAvailable': isAvailable, // Assuming all cars are available by default
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
      description: json['discription'] != null
          ? json['discription']
          : json['description'],
      topSpeed: json['topSpeed'] ?? 0,
      image: json['image'] ??
          'https://img.freepik.com/premium-vector/no-photo-available-vector-icon-default-image-symbol-picture-coming-soon-web-site-mobile-app_87543-18055.jpg',
      category: json['Category'] ?? 'Unknown',
      year: json['year'] ?? 'Unknown',
      id: json['id'] ?? 'Unknown',
      isAvailable: json['available'] ?? true, // Default to true if not provided
    );
  }
}
