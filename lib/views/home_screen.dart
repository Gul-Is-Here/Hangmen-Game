import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hangman_game/views/game_screen.dart';

import 'settings_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          ),
        ),
        child: Stack(
          children: [
            // Animated background elements
            Positioned(
              top: -50,
              left: -50,
              child:
                  Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat())
                      .scale(
                        duration: NumDurationExtensions(10).seconds,
                        curve: Curves.easeInOut,
                      )
                      .fade(
                        duration: NumDurationExtensions(10).seconds,
                        curve: Curves.easeInOut,
                      ),
            ),
            Positioned(
              bottom: -100,
              right: -50,
              child:
                  Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat())
                      .scale(duration: NumDurationExtensions(15).seconds)
                      .fade(duration: NumDurationExtensions(15).seconds),
            ),

            // NEW: Info icon (top-right)
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, right: 12),
                  child: _GlassIconButton(
                    icon: Icons.info_outline_rounded,
                    tooltip: 'How to Play',
                    onPressed: () => _showHowToPlayDialog(context),
                  ).animate().fadeIn(duration: 300.ms).scale(),
                ),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Title
                    Text(
                          'HANGMAN',
                          style: GoogleFonts.pacifico(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .scaleXY(begin: 0.8, end: 1, curve: Curves.easeOutBack),

                    const SizedBox(height: 40),

                    // Glassmorphic Buttons
                    _GlassButton(
                      onPressed: () => Get.to(
                        () => GameScreen(),
                        transition: Transition.fadeIn,
                        duration: 800.ms,
                      ),
                      text: 'PLAY',
                      icon: Icons.play_arrow_rounded,
                    ).animate().slideY(
                      begin: 0.5,
                      end: 0,
                      duration: 500.ms,
                      curve: Curves.easeOutQuad,
                    ),

                    const SizedBox(height: 20),

                    _GlassButton(
                      onPressed: () => Get.to(
                        () => StatsScreen(),
                        transition: Transition.fadeIn,
                        duration: 800.ms,
                      ),
                      text: 'STATS',
                      icon: Icons.bar_chart_rounded,
                    ).animate().slideY(
                      begin: 0.5,
                      end: 0,
                      duration: 600.ms,
                      curve: Curves.easeOutQuad,
                    ),

                    const SizedBox(height: 20),

                    _GlassButton(
                      onPressed: () => Get.to(
                        () => const SettingsScreen(),
                        transition: Transition.fadeIn,
                        duration: 800.ms,
                      ),
                      text: 'SETTINGS',
                      icon: Icons.settings_rounded,
                    ).animate().slideY(
                      begin: 0.5,
                      end: 0,
                      duration: 700.ms,
                      curve: Curves.easeOutQuad,
                    ),

                    const SizedBox(height: 40),

                    // Animated subtitle
                    Text(
                          'Guess the hidden word!',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .fade(
                          delay: NumDurationExtensions(1).seconds,
                          duration: NumDurationExtensions(2).seconds,
                        )
                        .scaleXY(
                          delay: NumDurationExtensions(1).seconds,
                          duration: NumDurationExtensions(2).seconds,
                          begin: 1,
                          end: 1.05,
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== Info dialog ==========

void _showHowToPlayDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: Colors.black87.withOpacity(0.5),
    builder: (_) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.22),
                width: 1,
              ),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.16),
                  Colors.white.withOpacity(0.10),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.help_outline_rounded, color: Colors.white, size: 30),
                const SizedBox(height: 8),
                Text(
                  'How to Play',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                _HowToItem('Tap letters to guess the hidden word.'),
                _HowToItem('Wrong guesses draw parts of the hangman.'),
                _HowToItem(
                  'Attempts depend on difficulty: Easy (8), Medium (6), Hard (4).',
                ),
                _HowToItem(
                  'Use “Hint” when available; it reveals a correct letter.',
                ),
                _HowToItem('If timer is enabled, finish before time runs out.'),
                _HowToItem('Win by revealing all letters before attempts end.'),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Got it',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 180.ms).scale(),
  );
}

class _HowToItem extends StatelessWidget {
  final String text;
  const _HowToItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.95),
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ========== Reusable glass widgets ==========

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback onPressed;

  const _GlassIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.white.withOpacity(0.12),
            child: InkWell(
              onTap: onPressed,
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData icon;

  const _GlassButton({
    required this.onPressed,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                splashColor: Colors.white.withOpacity(0.2),
                highlightColor: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 18,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        text,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
