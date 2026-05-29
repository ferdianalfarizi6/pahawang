import { PrismaClient, Role } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting database seeding...');

  // 1. Clear existing data to prevent duplicate constraints
  console.log('🧹 Clearing old data...');
  await prisma.payment.deleteMany({});
  await prisma.booking.deleteMany({});
  await prisma.user.deleteMany({});
  await prisma.villa.deleteMany({});
  await prisma.tourPackage.deleteMany({});

  // 2. Seed Users
  console.log('👤 Seeding Users...');
  await prisma.user.create({
    data: {
      firebase_uid: 'admin-firebase-uid',
      email: 'admin@gmail.com',
      full_name: 'Super Admin Pahawang',
      phone: '081234567890',
      avatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80',
      role: Role.admin,
    },
  });

  await prisma.user.create({
    data: {
      firebase_uid: 'user-firebase-uid-1',
      email: 'ferdian@gmail.com',
      full_name: 'Ferdian Alfarizi',
      phone: '082345678901',
      avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80',
      role: Role.user,
    },
  });

  await prisma.user.create({
    data: {
      firebase_uid: 'user-firebase-uid-2',
      email: 'user@gmail.com',
      full_name: 'Budi Santoso',
      phone: '083456789012',
      avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80',
      role: Role.user,
    },
  });

  // 3. Seed Villas
  console.log('🏡 Seeding Villas...');
  await prisma.villa.create({
    data: {
      name: 'Andreas Resort Terapung',
      description: 'Andreas Resort adalah resort terapung premium dengan pemandangan langsung ke perairan jernih Pulau Pahawang. Dilengkapi fasilitas kolam renang infinity privat dan akses langsung untuk snorkeling.',
      location: 'Pulau Pahawang, Pesawaran, Lampung',
      thumbnail: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=800&q=80',
      gallery: [
        'https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80'
      ],
      price_per_night: 1750000,
      max_guest: 4,
      available_room: 5,
      facilities: ['AC', 'Private Pool', 'Floating Breakfast', 'WiFi', 'Bathtub', 'Snorkeling Gear'],
    },
  });

  await prisma.villa.create({
    data: {
      name: 'Villa Bukit Pahawang',
      description: 'Terletak di atas bukit Pulau Pahawang, villa ini menawarkan pemandangan sunset dan matahari terbit 360 derajat yang memukau. Suasana sejuk, tenang, dan sangat private.',
      location: 'Bukit Pahawang Barat, Pesawaran, Lampung',
      thumbnail: 'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?auto=format&fit=crop&w=800&q=80',
      gallery: [
        'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1499793983690-e29da59ef1c2?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1439066615861-d1af74d74000?auto=format&fit=crop&w=800&q=80'
      ],
      price_per_night: 1200000,
      max_guest: 6,
      available_room: 3,
      facilities: ['AC', 'Balcony Sunset View', 'Kitchen Set', 'WiFi', 'Smart TV', 'Barbeque Area'],
    },
  });

  await prisma.villa.create({
    data: {
      name: 'Pahawang Beachfront Cottage',
      description: 'Cottage tradisional bambu estetik yang terletak persis di pinggir pantai pasir putih. Keluar dari pintu langsung menyentuh pasir putih bersih.',
      location: 'Pantai Pasir Putih Pahawang, Pesawaran, Lampung',
      thumbnail: 'https://images.unsplash.com/photo-1506929562872-bb421503ef21?auto=format&fit=crop&w=800&q=80',
      gallery: [
        'https://images.unsplash.com/photo-1506929562872-bb421503ef21?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1473448912268-2022ce9509d8?auto=format&fit=crop&w=800&q=80'
      ],
      price_per_night: 850000,
      max_guest: 2,
      available_room: 8,
      facilities: ['Fan / AC', 'Hammock', 'Beach View', 'WiFi', 'Outdoor Shower', 'Breakfast'],
    },
  });

  // 4. Seed Tour Packages
  console.log('🎒 Seeding Tour Packages...');
  await prisma.tourPackage.create({
    data: {
      title: 'One Day Snorkeling & Hopping Island',
      description: 'Rasakan petualangan snorkeling seharian penuh mengunjungi spot-spot terumbu karang terbaik seperti Taman Nemo, Candi Transplantasi, serta bersantai di Pulau Pahawang Kecil yang berpasir putih timbul.',
      duration: '1 Day (08:00 - 16:00)',
      location: 'Dermaga Ketapang - Pulau Pahawang',
      price: 250000,
      quota: 40,
      thumbnail: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&w=800&q=80',
      gallery: [
        'https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1559136555-9303baea8ebd?auto=format&fit=crop&w=800&q=80'
      ],
      facilities: ['Kapal Wisata AC/Non-AC', 'Alat Snorkeling Lengkap', 'Makan Siang Prasmanan', 'Pemandu / Guide Lokal', 'Dokumentasi Underwear & Mirrorless', 'Tiket Masuk Pulau'],
    },
  });

  await prisma.tourPackage.create({
    data: {
      title: 'VIP Exclusive Pahawang 2D1N',
      description: 'Nikmati liburan mewah selama 2 hari 1 malam. Menginap di resort terapung, makan malam romantis di pinggir pantai, private boat, dan pemandu bersertifikasi untuk menjelajah seluruh keindahan Pahawang.',
      duration: '2 Days 1 Night',
      location: 'Dermaga Ketapang & Resort Terapung',
      price: 1850000,
      quota: 15,
      thumbnail: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=800&q=80',
      gallery: [
        'https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1506929562872-bb421503ef21?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80'
      ],
      facilities: ['Akomodasi Resort Terapung', 'Private Speedboat', 'Makan 5x Premium Menu', 'Barbeque Seafood', 'Private Guide & Fotografer', 'Tiket & Perizinan', 'Merchandise Wisata'],
    },
  });

  await prisma.tourPackage.create({
    data: {
      title: 'Open Trip Seru Pahawang Weekend',
      description: 'Sangat cocok untuk solo traveler atau grup kecil yang ingin menambah teman baru. Jelajahi kelucuan ikan Nemo, foto di plang ikonik Pulau Pahawang, dan nikmati makan siang di gazebo pantai.',
      duration: '1 Day Weekend Trip',
      location: 'Dermaga Ketapang Lampung',
      price: 150000,
      quota: 50,
      thumbnail: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
      gallery: [
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&w=800&q=80'
      ],
      facilities: ['Kapal Wisata Gabungan', 'Alat Snorkeling standar', 'Lunch Box', 'Dokumentasi Gopro (Share)', 'Tour Leader', 'Asuransi Perjalanan'],
    },
  });

  console.log('✅ Seeding completed successfully!');
  console.log(`👤 Seeded: 3 Users`);
  console.log(`🏡 Seeded: 3 Villas`);
  console.log(`🎒 Seeded: 3 Tour Packages`);
}

main()
  .catch((e) => {
    console.error('❌ Error while seeding database:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
