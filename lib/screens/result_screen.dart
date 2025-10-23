import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Import HomeScreen untuk navigasi kembali
import 'home_screen.dart';

class ResultScreen extends StatelessWidget {
  final String ocrText;

  const ResultScreen({super.key, required this.ocrText});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Scan Teks'),
        backgroundColor: Colors.blue, // Menambahkan warna agar konsisten
        // Nonaktifkan tombol kembali bawaan agar pengguna terbiasa menggunakan FAB untuk kembali ke Home.
        automaticallyImplyLeading: false,
        actions: [
          // Tombol Salin Teks ke Clipboard
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Salin Teks',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: ocrText));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Teks berhasil disalin!')),
              );
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: SelectableText(
            // --- Soal 1 Poin 2 Teks utuh dan navigasi balik ---
            // Menampilkan teks utuh.
            // ocrText.replaceAll('\n', ' ') tidak ada, jadi \n akan tampil.
            ocrText.isEmpty ? 'Tidak ada teks yang ditemukan.' : ocrText,
            style: const TextStyle(fontSize: 18, height: 1.5),
            textAlign: TextAlign.justify,
          ),
        ),
      ),

      // Menambahkan FloatingActionButton
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Gunakan Navigator.pushAndRemoveUntil untuk kembali ke HomeScreen dan menghapus semua halaman di atasnya.
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (Route<dynamic> route) => false, // Predikat ini menghapus semua rute
          );
        },
        backgroundColor: Colors.blue,
        // Ikon Icons.home
        child: const Icon(Icons.home),
      ),
    );
  }
}

