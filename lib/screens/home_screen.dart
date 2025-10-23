import 'package:flutter/material.dart';
import 'scan_screen.dart'; // Pastikan import ini benar

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Mengubah judul dan menambahkan warna agar konsisten
        title: const Text('Beranda'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        // Menambahkan Padding agar tidak terlalu menempel ke tepi
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          // Membungkus ListTile dengan Card agar terlihat rapi
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                // --- Soal 1 Poin 1 Pengubahan Navigasi Home ---
                // Mengganti ElevatedButton menjadi ListTile
                ListTile(
              // Atur leading
              leading: const Icon(Icons.camera_alt, color: Colors.blue, size: 30),
              // Atur title
              title: const Text(
                'Mulai Pindai Teks Baru',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              // Fungsi onTap menggunakan Navigator.push()
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ScanScreen()),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

