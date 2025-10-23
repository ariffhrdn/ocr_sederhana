import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Import HomeScreen untuk navigasi kembali
import 'home_screen.dart';

// --- Soal 3 Poin 2 ---
// 1. Import plugin TTS
import 'package:flutter_tts/flutter_tts.dart';

// 2. Ubah dari StatelessWidget menjadi StatefulWidget
class ResultScreen extends StatefulWidget {
  final String ocrText;

  const ResultScreen({super.key, required this.ocrText});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  // 3. Inisialisasi FlutterTts
  late FlutterTts flutterTts;
  bool isPlaying = false; // State untuk melacak apakah TTS sedang berbicara

  @override
  void initState() {
    super.initState();
    // 4. Inisialisasi di initState
    flutterTts = FlutterTts();
    _initializeTts();

    // Handler untuk mendeteksi kapan TTS selesai berbicara
    flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          isPlaying = false;
        });
      }
    });
  }

  // Fungsi helper untuk mengatur bahasa
  void _initializeTts() async {
    // 5. Atur bahasa pembacaan menjadi Bahasa Indonesia
    await flutterTts.setLanguage("id-ID");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5); // Atur kecepatan normal
  }

  @override
  void dispose() {
    // 6. Implementasikan dispose() untuk menghentikan mesin TTS
    flutterTts.stop();
    super.dispose();
  }

  // --- Soal 3 Poin 3 ---
  // 7. Fungsi untuk membacakan teks
  Future<void> _speak() async {
    // Gunakan widget.ocrText untuk mengakses ocrText di dalam State
    if (widget.ocrText.isNotEmpty) {
      if (isPlaying) {
        // Jika sedang berbicara, hentikan
        await flutterTts.stop();
        setState(() {
          isPlaying = false;
        });
      } else {
        // Jika tidak berbicara, mulai berbicara
        await flutterTts.speak(widget.ocrText);
        setState(() {
          isPlaying = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Scan Teks'),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Salin Teks',
            onPressed: () {
              // Gunakan widget.ocrText
              Clipboard.setData(ClipboardData(text: widget.ocrText));
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
            // Gunakan widget.ocrText
            widget.ocrText.isEmpty
                ? 'Tidak ada teks yang ditemukan.'
                : widget.ocrText,
            style: const TextStyle(fontSize: 18, height: 1.5),
            textAlign: TextAlign.justify,
          ),
        ),
      ),

      // --- Soal 3 Poin 3 ---
      // 8. Tambahkan FAB kedua
      // Kita gunakan Column untuk menampung kedua FAB
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // FAB untuk TTS 
          FloatingActionButton(
            onPressed: _speak, // Panggil fungsi _speak
            tooltip: 'Bacakan Teks',
            backgroundColor: isPlaying ? Colors.red : Colors.green, // Ganti warna
            // Ganti ikon berdasarkan state isPlaying
            child: Icon(isPlaying ? Icons.stop : Icons.volume_up),
          ),
          const SizedBox(height: 16), // Jarak antar FAB
          // FAB untuk Home 
          FloatingActionButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (Route<dynamic> route) => false,
              );
            },
            backgroundColor: Colors.blue,
            tooltip: 'Kembali ke Home',
            child: const Icon(Icons.home),
          ),
        ],
      ),
    );
  }
}

