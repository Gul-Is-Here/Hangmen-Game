import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:confetti/confetti.dart' as confetti;

import '../controllers/game_controller.dart';

/// Put this in your screen's Stack: `const GameConfettiOverlay()`
class GameConfettiOverlay extends StatefulWidget {
  const GameConfettiOverlay({super.key});

  @override
  State<GameConfettiOverlay> createState() => _GameConfettiOverlayState();
}

class _GameConfettiOverlayState extends State<GameConfettiOverlay> {
  final GameController _controller = Get.find();
  late final confetti.ConfettiController _confettiController;

  /// Keep a handle to the GetX worker so we can dispose it.
  Worker? _confettiWorker;

  @override
  void initState() {
    super.initState();
    _confettiController = confetti.ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Listen to the flag and play when it flips true.
    _confettiWorker = ever<bool>(_controller.showConfetti, (show) {
      if (!mounted) return; // widget gone? don't touch the controller
      if (show) {
        // Try/catch avoids noisy logs if someone toggles during teardown.
        try {
          _confettiController.play();
        } catch (_) {}
        // Optional: auto-reset so it can be triggered again later
        // Future.microtask(() => _controller.showConfetti.value = false);
      }
    });
  }

  @override
  void dispose() {
    // Stop receiving events BEFORE disposing the controller.
    _confettiWorker?.dispose();
    _confettiWorker = null;

    _confettiController.stop(); // optional, a no-op if not playing
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: confetti.ConfettiWidget(
        confettiController: _confettiController,
        blastDirectionality: confetti.BlastDirectionality.explosive,
        shouldLoop: false,
        emissionFrequency: 0.0, // single burst
        numberOfParticles: 25,
        gravity: 0.6,
        colors: const [
          Colors.green,
          Colors.blue,
          Colors.pink,
          Colors.orange,
          Colors.purple,
        ],
      ),
    );
  }
}
