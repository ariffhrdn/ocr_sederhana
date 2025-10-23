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
  late Future<void> _initializeControllerFuture;
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

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
      ResolutionPreset.medium,
    );

    // Inisialisasi controller akan mengembalikan sebuah Future
    _initializeControllerFuture = _controller.initialize();
    
    // Memanggil setState jika widget masih ada di tree untuk me-refresh UI
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(ocrText: recognizedText),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // Menampilkan pesan error jika terjadi masalah
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  
  // Fungsi untuk memproses gambar dan mengenali teks di dalamnya
  Future<String> _recognizeTextFromFile(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
    return recognizedText.text;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kamera OCR')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Jika Future selesai, tampilkan preview kamera
            return Column(
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: CameraPreview(_controller),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton.icon(
                    onPressed: _takePictureAndScan,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Ambil Foto & Scan'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Selama proses inisialisasi, tampilkan loading indicator
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
