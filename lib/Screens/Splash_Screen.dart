import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practiceflutter/Screens/Signup_Screen.dart';

import '../widgets/background.dart';
import 'Home_Screen.dart';
import 'login_screen.dart';
import 'package:google_fonts/google_fonts.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const Color gold = Color(0xFFFDE68A);
  static const Color amber = Color(0xFFF59E0B);

  late final AnimationController _main; // one-time intro
  late final AnimationController _pulse; // looping glow rings

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _titleFade;
  late final Animation<double> _titleSlide;
  late final Animation<double> _taglineFade;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();

    _main = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _logoScale = Tween<double>(begin: 0.2, end: 1).animate(
      CurvedAnimation(
        parent: _main,
        curve: const Interval(0.0, 0.40, curve: Curves.elasticOut),
      ),
    );

    _logoFade = CurvedAnimation(
      parent: _main,
      curve: const Interval(0.0, 0.18, curve: Curves.easeIn),
    );

    _titleFade = CurvedAnimation(
      parent: _main,
      curve: const Interval(0.30, 0.55, curve: Curves.easeOut),
    );

    _titleSlide = Tween<double>(begin: 24, end: 0).animate(
      CurvedAnimation(
        parent: _main,
        curve: const Interval(0.30, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _taglineFade = CurvedAnimation(
      parent: _main,
      curve: const Interval(0.50, 0.72, curve: Curves.easeOut),
    );

    _progress = CurvedAnimation(
      parent: _main,
      curve: const Interval(0.55, 1.0, curve: Curves.easeInOut),
    );

    _main.addStatusListener((status) {
      if (status == AnimationStatus.completed) _goNext();
    });

    _main.forward();
  }

  Future<void> _goNext() async {
    await Future.delayed(const Duration(milliseconds: 350));
    // Firebase ka saved login restore hone ka intezar
    final user = await FirebaseAuth.instance.authStateChanges().first;
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) =>
        user == null ?  LoginScreen(): const MainScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _main.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Background(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: Listenable.merge([_main, _pulse]),
            builder: (context, _) {
              return Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLogo(),
                        const SizedBox(height: 28),
                        _buildTitle(),
                        const SizedBox(height: 14),
                        _buildTagline(),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 48,
                    child: _buildLoader(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ───────────── Logo with pulse rings ─────────────
  Widget _buildLogo() {
    const double logoSize = 70;

    Widget ring(double offset) {
      final p = (_pulse.value + offset) % 1.0;
      final size = logoSize + 130 * p;
      final opacity = (1 - p) * 0.38 * _logoFade.value;
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: gold.withOpacity(opacity), width: 2),
        ),
      );
    }

    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ring(0.0),
          ring(0.5),
          Opacity(
            opacity: _logoFade.value,
            child: Transform.scale(
              scale: _logoScale.value,
              child: Container(
                width: logoSize,
                height: logoSize,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [gold, amber],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: amber.withOpacity(0.5),
                      blurRadius: 40,
                      spreadRadius: 2,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  size: 54,
                  color: Color(0xFF1E1B0B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────── Title ─────────────
  Widget _buildTitle() {
    return Opacity(
      opacity: _titleFade.value,
      child: Transform.translate(
        offset: Offset(0, _titleSlide.value),
        child: Column(
          children: [
            Text(
              'LIBRARY',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w800,
                letterSpacing: 8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'MANAGEMENT SYSTEM',
              style: GoogleFonts.poppins(
                color: gold.withOpacity(0.95),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 4,
              ),
            ),

          ],
        ),
      ),
    );
  }

  // ───────────── Tagline ─────────────
  Widget _buildTagline() {
    return Opacity(
      opacity: _taglineFade.value,
      child: Text(
        'Read  •  Borrow  •  Grow',
        style: GoogleFonts.poppins(
          color: Colors.white.withOpacity(0.75),
          fontSize: 14,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  // ───────────── Loader ─────────────
  Widget _buildLoader() {
    return Opacity(
      opacity: _taglineFade.value,
      child: Column(
        children: [
          SizedBox(
            width: 180,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _progress.value,
                minHeight: 5,
                backgroundColor: Colors.amber,
                valueColor: const AlwaysStoppedAnimation<Color>(gold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Loading your library…',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.65),
              fontSize: 12.5,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}