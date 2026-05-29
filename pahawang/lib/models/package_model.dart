class TourPackage {
  final String id;
  final String title;
  final String description;
  final String duration;
  final String location;
  final double price;
  final int quota;
  final String thumbnail;
  final List<String> gallery;
  final List<String> facilities;
  final DateTime createdAt;

  const TourPackage({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.location,
    required this.price,
    required this.quota,
    required this.thumbnail,
    required this.gallery,
    required this.facilities,
    required this.createdAt,
  });

  factory TourPackage.fromJson(Map<String, dynamic> json) {
    return TourPackage(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? '',
      location: json['location'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quota: json['quota'] ?? 0,
      thumbnail: json['thumbnail'] ?? '',
      gallery: List<String>.from(json['gallery'] ?? []),
      facilities: List<String>.from(json['facilities'] ?? []),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'duration': duration,
      'location': location,
      'price': price,
      'quota': quota,
      'thumbnail': thumbnail,
      'gallery': gallery,
      'facilities': facilities,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
