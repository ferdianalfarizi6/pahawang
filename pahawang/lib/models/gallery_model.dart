class GalleryItem {
  final String id;
  final String title;
  final String imageUrl;
  final String category;
  final String date;
  final int likes;

  GalleryItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.category,
    required this.date,
    required this.likes,
  });
}

List<GalleryItem> galleryItems = [
  GalleryItem(
    id: '1',
    title: 'Keindahan Bawah Laut Pahawang',
    imageUrl: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800',
    category: 'Bahari',
    date: '2024-01-15',
    likes: 234,
  ),
  GalleryItem(
    id: '2',
    title: 'Sunset di Pulau Pahawang',
    imageUrl: 'https://images.unsplash.com/photo-1507400492013-162706c8c05e?w=800',
    category: 'Sunset',
    date: '2024-02-20',
    likes: 189,
  ),
  GalleryItem(
    id: '3',
    title: 'Festival Budaya Desa',
    imageUrl: 'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?w=800',
    category: 'Budaya',
    date: '2024-03-10',
    likes: 156,
  ),
  GalleryItem(
    id: '4',
    title: 'Pantai Pasir Putih',
    imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
    category: 'Pantai',
    date: '2024-04-05',
    likes: 312,
  ),
  GalleryItem(
    id: '5',
    title: 'Snorkeling Bersama Penyu',
    imageUrl: 'https://images.unsplash.com/photo-1596401057633-54a8fe8ef647?w=800',
    category: 'Bahari',
    date: '2024-05-18',
    likes: 278,
  ),
  GalleryItem(
    id: '6',
    title: 'Camping di Tepi Pantai',
    imageUrl: 'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=800',
    category: 'Camping',
    date: '2024-06-22',
    likes: 198,
  ),
  GalleryItem(
    id: '7',
    title: 'Perahu Nelayan Tradisional',
    imageUrl: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800',
    category: 'Budaya',
    date: '2024-07-14',
    likes: 145,
  ),
  GalleryItem(
    id: '8',
    title: 'Hutan Mangrove Pahawang',
    imageUrl: 'https://images.unsplash.com/photo-1500375592092-40eb2168fd21?w=800',
    category: 'Alam',
    date: '2024-08-30',
    likes: 167,
  ),
];