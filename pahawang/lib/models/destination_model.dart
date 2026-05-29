class Destination {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double rating;
  final String category;

  Destination({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.category,
  });
}

List<Destination> destinations = [
  Destination(
    id: '1',
    name: 'Pantai Pasir Putih',
    description: 'Pantai dengan pasir putih lembut dan air laut jernih',
    imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
    rating: 4.8,
    category: 'Pantai',
  ),
  Destination(
    id: '2',
    name: 'Spot Snorkeling',
    description: 'Nikmati keindahan terumbu karang dan ikan warna-warni',
    imageUrl: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800',
    rating: 4.9,
    category: 'Bahari',
  ),
  Destination(
    id: '3',
    name: 'Hutan Mangrove',
    description: 'Jelajahi ekosistem mangrove yang asri dan menakjubkan',
    imageUrl: 'https://images.unsplash.com/photo-1500375592092-40eb2168fd21?w=800',
    rating: 4.5,
    category: 'Alam',
  ),
  Destination(
    id: '4',
    name: 'Sunset Point',
    description: 'Spot terbaik untuk menikmati matahari terbenam',
    imageUrl: 'https://images.unsplash.com/photo-1507400492013-162706c8c05e?w=800',
    rating: 4.7,
    category: 'Viewpoint',
  ),
];