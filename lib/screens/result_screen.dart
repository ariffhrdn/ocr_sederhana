import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResultScreen extends StatelessWidget {
  final String ocrText;

  const ResultScreen({super.key, required this.ocrText});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Scan Teks'),
        actions: [
          // Menambahkan tombol untuk menyalin teks
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
        // Menggunakan SingleChildScrollView agar konten bisa di-scroll jika panjang
        child: SingleChildScrollView(
          child: SelectableText(
            // Menampilkan pesan jika tidak ada teks yang terdeteksi
            ocrText.isEmpty ? 'Tidak ada teks yang ditemukan.' : ocrText,
            style: const TextStyle(fontSize: 18, height: 1.5),
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    );
  }
}
