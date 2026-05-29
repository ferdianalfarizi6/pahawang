import 'package:flutter/material.dart';
import '../utils/colors.dart';

class ManageVillasScreen extends StatelessWidget {
  const ManageVillasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Villa'),
        backgroundColor: AppColors.primary,
      ),
      body: const Center(
        child: Text('Anda dapat menambah, mengedit, dan menghapus villa di sini.',
            style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
