import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:audioplayers/audioplayers.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint("Erro ao buscar câmeras: $e");
  }
  
  runApp(const AirDrumApp());
}

class AirDrumApp extends StatelessWidget {
  const AirDrumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Air Drum App',
      theme: ThemeData.dark(),
      home: const DrumScreen(),
    );
  }
}

class DrumScreen extends StatefulWidget {
  const DrumScreen({super.key});

  @override
  State<DrumScreen> createState() => _DrumScreenState();
}

class _DrumScreenState extends State<DrumScreen> {
  CameraController? _controller;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (cameras.isEmpty) return;

    CameraDescription frontCamera = cameras.firstWhere(
      (CameraDescription camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(frontCamera, ResolutionPreset.medium);
    await _controller?.initialize();
    if (!mounted) return;
    setState(() {});
  }

  // Função para reproduzir o som real
  Future<void> _playSound(String drumType) async {
    try {
      // Nota: Certifique-se de colocar os ficheiros de som em assets/sounds/ e declará-los no pubspec.yaml
      // Exemplo: hihat.mp3 e snare.mp3
      await _audioPlayer.stop(); // Para o som anterior para tocar imediatamente
      await _audioPlayer.play(AssetSource('sounds/$drumType.mp3'));
      debugPrint("Tocando bateria: $drumType");
    } catch (e) {
      debugPrint("Erro ao tocar áudio: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Câmara em fundo total
          SizedBox.expand(
            child: CameraPreview(_controller!),
          ),
          // Interface por cima da câmara
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 50.0),
                child: Text(
                  "Air Drum - Aponte para os Pads!",
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    backgroundColor: Colors.black54,
                    color: Colors.white
                  ),
                ),
              ),
              const Spacer(),
              // Zona dos Pads (Prato e Caixa)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Hi-Hat (Prato)
                    GestureDetector(
                      onTap: () => _playSound('hihat'),
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.4),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blueAccent, width: 3),
                        ),
                        child: const Center(
                          child: Text(
                            "Prato\n(Hi-Hat)", 
                            textAlign: TextAlign.center, 
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                          ),
                        ),
                      ),
                    ),
                    // Snare (Caixa)
                    GestureDetector(
                      onTap: () => _playSound('snare'),
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.4),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.redAccent, width: 3),
                        ),
                        child: const Center(
                          child: Text(
                            "Caixa\n(Snare)", 
                            textAlign: TextAlign.center, 
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
