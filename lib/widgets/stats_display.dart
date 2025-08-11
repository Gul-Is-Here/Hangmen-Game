import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';


import '../controllers/game_controller.dart';

class StatsDisplay extends StatelessWidget {
  final GameController _controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text('Score', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              Text('${_controller.game.value.score}'),
            ],
          ),
          Column(
            children: [
              Text('High Score', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              Text('${_controller.highScore.value}'),
            ],
          ),
          Column(
            children: [
              Text('Attempts', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              Text('${_controller.game.value.attemptsLeft}'),
            ],
          ),
          Column(
            children: [
              Text('Hints', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              Text('${_controller.game.value.hintsLeft}'),
            ],
          ),
        ],
      ),
    ));
  }
}