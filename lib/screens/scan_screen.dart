import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  late CameraController _controller;
  // Variabel _initializeControllerFuture akan ditangani oleh FutureBuilder
  late Future<void> _initializeControllerFuture;
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // Fungsi untuk menginisialisasi kamera
  void _initializeCamera() async {
    // Mendapatkan daftar kamera yang tersedia
    final cameras = await availableCameras();
    // Menggunakan kamera utama (biasanya kamera belakang)
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      // Mengubah ke high untuk kualitas yang lebih baik
      ResolutionPreset.high,
    );

    // Inisialisasi controller akan mengembalikan sebuah Future
    _initializeControllerFuture = _controller.initialize();

    // Memanggil setState jika widget masih ada di tree untuk me-refresh UI
    // Ini penting agar FutureBuilder tahu ada perubahan
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    // Pastikan untuk dispose controller saat widget di-dispose
    _controller.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  // Fungsi untuk mengambil gambar dan melakukan OCR
  Future<void> _takePictureAndScan() async {
    try {
      // Pastikan kamera sudah terinisialisasi sebelum mengambil gambar
      await _initializeControllerFuture;

      if (!mounted) return;

      // Menampilkan notifikasi bahwa proses sedang berjalan
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Memproses OCR, mohon tunggu...'),
          duration: Duration(seconds: 3),
        ),
      );

      // Mengambil gambar
      final XFile image = await _controller.takePicture();

      // Melakukan proses OCR dari file gambar
      final recognizedText = await _recognizeTextFromFile(File(image.path));

      if (!mounted) return;

      // Berpindah ke layar hasil dengan membawa teks hasil OCR
      // Menggunakan pushReplacement agar saat di ResultScreen,
      // menekan 'kembali' tidak akan ke halaman kamera, tapi ke home (jika FAB ditekan)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(ocrText: recognizedText),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // --- Soal 2 Poin 2  Spesifikasi Pesan Error ---
      // Memodifikasi pesan error SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Pemindaian Gagal! Periksa Izin Kamera atau coba lagi.",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fungsi untuk memproses gambar dan mengenali teks di dalamnya
  Future<String> _recognizeTextFromFile(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText =
        await _textRecognizer.processImage(inputImage);
    return recognizedText.text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pindai Teks'),
        backgroundColor: Colors.blue, // Menyamakan tema warna
      ),
      // Menggunakan FutureBuilder untuk menangani state loading kamera
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Jika Future selesai, tampilkan preview kamera
            // Menggunakan Stack untuk menumpuk tombol di atas preview
            return Stack(
              fit: StackFit.expand,
              children: [
                // Preview Kamera
                CameraPreview(_controller),
                // Overlay Bingkai (opsional, untuk estetika)
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.height * 0.5,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.yellow, width: 3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                // Tombol Ambil Foto (dipindahkan ke FAB)
              ],
            );
          } else {
            // --- Soal 2 Poin 1 Custom Loading Screen di ScanScreen ---
            // Selama proses inisialisasi, tampilkan loading screen kustom
            // Background
            return Scaffold(
              backgroundColor: Colors.grey[900],
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // CircularProgressIndicator
                    CircularProgressIndicator(color: Colors.yellow),
                    const SizedBox(height: 24), // Memberi jarak
                    // Teks di bawah indikator
                    Text(
                      'Memuat Kamera... Harap tunggu.',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
      // Memindahkan tombol ke FloatingActionButton agar di atas preview
      floatingActionButton: FloatingActionButton.large(
        onPressed: _takePictureAndScan,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

