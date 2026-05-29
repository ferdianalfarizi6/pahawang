class Villa {
  final String id;
  final String name;
  final String description;
  final String location;
  final String thumbnail;
  final List<String> gallery;
  final double pricePerNight;
  final int maxGuest;
  final int availableRoom;
  final List<String> facilities;
  final DateTime createdAt;

  const Villa({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.thumbnail,
    required this.gallery,
    required this.pricePerNight,
    required this.maxGuest,
    required this.availableRoom,
    required this.facilities,
    required this.createdAt,
  });

  factory Villa.fromJson(Map<String, dynamic> json) {
    return Villa(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      gallery: List<String>.from(json['gallery'] ?? []),
      pricePerNight: (json['price_per_night'] as num?)?.toDouble() ?? 0.0,
      maxGuest: json['max_guest'] ?? 0,
      availableRoom: json['available_room'] ?? 0,
      facilities: List<String>.from(json['facilities'] ?? []),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'thumbnail': thumbnail,
      'gallery': gallery,
      'price_per_night': pricePerNight,
      'max_guest': maxGuest,
      'available_room': availableRoom,
      'facilities': facilities,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
