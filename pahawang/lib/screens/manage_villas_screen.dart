import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/villas_provider.dart';
import '../models/villa_model.dart';
import '../utils/colors.dart';

class ManageVillasScreen extends StatefulWidget {
  const ManageVillasScreen({super.key});

  @override
  State<ManageVillasScreen> createState() => _ManageVillasScreenState();
}

class _ManageVillasScreenState extends State<ManageVillasScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VillasProvider>(context, listen: false).fetchVillas();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshVillas() async {
    await Provider.of<VillasProvider>(context, listen: false)
        .fetchVillas(search: _searchController.text);
  }

  String _formatRupiah(num val) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(val);
  }

  void _showVillaForm({Villa? villa}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => VillaFormSheet(
        villa: villa,
        onSaved: () {
          _refreshVillas();
        },
      ),
    );
  }

  Future<void> _handleDelete(Villa villa) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Villa?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin menghapus "${villa.name}" dari sistem?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final villasProvider = Provider.of<VillasProvider>(context, listen: false);
      final success = await villasProvider.deleteVilla(villa.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Villa berhasil dihapus.'), backgroundColor: AppColors.success),
        );
      } else {
        if (mounted) {
          final error = villasProvider.error ?? 'Gagal menghapus villa.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final villasProvider = Provider.of<VillasProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kelola Villa',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            tooltip: 'Tambah Villa',
            onPressed: () => _showVillaForm(),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Search box
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: 'Cari nama atau lokasi villa...',
                hintStyle: const TextStyle(color: AppColors.textLight),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMedium),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: AppColors.textMedium),
                        onPressed: () {
                          _searchController.clear();
                          _refreshVillas();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => _refreshVillas(),
            ),
          ),

          // Villa lists
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshVillas,
              color: AppColors.primary,
              child: villasProvider.isLoading && villasProvider.villas.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : villasProvider.error != null && villasProvider.villas.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline_rounded, size: 64, color: Colors.redAccent),
                                const SizedBox(height: 16),
                                Text(
                                  'Gagal memuat villa:\n${villasProvider.error}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 16, color: AppColors.textMedium),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: _refreshVillas,
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('Coba Lagi'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : villasProvider.villas.isEmpty
                          ? Center(
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.holiday_village_rounded, size: 80, color: AppColors.textLight),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Belum ada villa terdaftar',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMedium),
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton.icon(
                                        onPressed: () => _showVillaForm(),
                                        icon: const Icon(Icons.add_rounded),
                                        label: const Text('Tambah Villa Pertama'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: villasProvider.villas.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final villa = villasProvider.villas[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Row(
                                      children: [
                                        // Image thumbnail
                                        Container(
                                          width: 100,
                                          height: 110,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            image: DecorationImage(
                                              image: NetworkImage(villa.thumbnail),
                                              fit: BoxFit.cover,
                                              onError: (_, __) => const Icon(Icons.broken_image_rounded, color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                        // Text details
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  villa.name,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.location_on_rounded, size: 12, color: AppColors.primary),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        villa.location,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  _formatRupiah(villa.pricePerNight),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.primary,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                Text(
                                                  'Tersedia: ${villa.availableRoom} Kamar | Maks: ${villa.maxGuest} Tamu',
                                                  style: const TextStyle(fontSize: 10, color: AppColors.textMedium),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Action buttons
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                                              onPressed: () => _showVillaForm(villa: villa),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                              onPressed: () => _handleDelete(villa),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 4),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
          ),
        ),
      ],
    ),
    );
  }
}

class VillaFormSheet extends StatefulWidget {
  final Villa? villa;
  final VoidCallback onSaved;

  const VillaFormSheet({super.key, this.villa, required this.onSaved});

  @override
  State<VillaFormSheet> createState() => _VillaFormSheetState();
}

class _VillaFormSheetState extends State<VillaFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _locationController;
  late TextEditingController _thumbnailController;
  late TextEditingController _priceController;
  late TextEditingController _maxGuestController;
  late TextEditingController _roomController;
  late TextEditingController _facilitiesController;
  late TextEditingController _galleryController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final v = widget.villa;
    _nameController = TextEditingController(text: v?.name ?? '');
    _descController = TextEditingController(text: v?.description ?? '');
    _locationController = TextEditingController(text: v?.location ?? '');
    _thumbnailController = TextEditingController(text: v?.thumbnail ?? '');
    _priceController = TextEditingController(text: v != null ? '${v.pricePerNight.toInt()}' : '');
    _maxGuestController = TextEditingController(text: v != null ? '${v.maxGuest}' : '');
    _roomController = TextEditingController(text: v != null ? '${v.availableRoom}' : '');
    _facilitiesController = TextEditingController(text: v?.facilities.join(', ') ?? '');
    _galleryController = TextEditingController(text: v?.gallery.join(', ') ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _thumbnailController.dispose();
    _priceController.dispose();
    _maxGuestController.dispose();
    _roomController.dispose();
    _facilitiesController.dispose();
    _galleryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final facilities = _facilitiesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final gallery = _galleryController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final payload = {
      'name': _nameController.text.trim(),
      'description': _descController.text.trim(),
      'location': _locationController.text.trim(),
      'thumbnail': _thumbnailController.text.trim(),
      'price_per_night': double.parse(_priceController.text),
      'max_guest': int.parse(_maxGuestController.text),
      'available_room': int.parse(_roomController.text),
      'facilities': facilities,
      'gallery': gallery,
    };

    final villasProvider = Provider.of<VillasProvider>(context, listen: false);
    bool success;

    if (widget.villa != null) {
      success = await villasProvider.updateVilla(widget.villa!.id, payload);
    } else {
      success = await villasProvider.createVilla(payload);
    }

    setState(() => _isSaving = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.villa != null ? 'Villa berhasil diperbarui.' : 'Villa berhasil ditambahkan.'),
          backgroundColor: AppColors.success,
        ),
      );
      widget.onSaved();
      Navigator.pop(context);
    } else {
      if (mounted) {
        final error = villasProvider.error ?? 'Gagal menyimpan data villa.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Top Notch indicator
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 16),
            Text(
              widget.villa != null ? 'Edit Data Villa' : 'Tambah Villa Baru',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark),
            ),
            const Divider(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nama Villa', border: OutlineInputBorder()),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Nama villa wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Deskripsi Villa', border: OutlineInputBorder()),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Deskripsi wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(labelText: 'Lokasi Villa', border: OutlineInputBorder()),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Lokasi wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _thumbnailController,
                      decoration: const InputDecoration(labelText: 'URL Gambar Thumbnail', border: OutlineInputBorder()),
                      validator: (v) => v == null || v.trim().isEmpty ? 'URL thumbnail wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Harga per Malam (Rp)', border: OutlineInputBorder()),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Harga wajib diisi';
                              final parsed = double.tryParse(v);
                              if (parsed == null || parsed <= 0) return 'Format harga tidak valid';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _maxGuestController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Maks. Tamu', border: OutlineInputBorder()),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Maks. tamu wajib diisi';
                              final parsed = int.tryParse(v);
                              if (parsed == null || parsed < 1) return 'Kapasitas minimal 1';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _roomController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Jumlah Kamar Tersedia', border: OutlineInputBorder()),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Jumlah kamar wajib diisi';
                        final parsed = int.tryParse(v);
                        if (parsed == null || parsed < 0) return 'Kamar minimal 0';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _facilitiesController,
                      decoration: const InputDecoration(
                        labelText: 'Fasilitas (pisahkan dengan koma)',
                        hintText: 'AC, WiFi, Kolam Renang, TV',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Fasilitas wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _galleryController,
                      decoration: const InputDecoration(
                        labelText: 'Galeri Gambar (pisahkan URL dengan koma)',
                        hintText: 'https://url1.com, https://url2.com',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            const Divider(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                    : Text(widget.villa != null ? 'Perbarui Villa' : 'Tambah Villa', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
