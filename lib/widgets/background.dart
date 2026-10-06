import 'dart:math';
import 'package:flutter/material.dart';

/// Professional animated background for a Library Management System.
/// - Deep navy / teal gradient
/// - Bookshelves on the left & right sides
/// - Floating books (closed + open) and soft glowing particles
///
/// Usage:
///   Background(child: YourLoginOrHomeContent())
class Background extends StatefulWidget {
  final Widget? child;
  const Background({super.key, this.child});

  @override
  State<Background> createState() => _BackgroundState();
}

class _BackgroundState extends State<Background>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final Random _random = Random(7);

  late final List<_Particle> _particles;
  late final List<_FloatingBook> _books;
  late final List<_Spine> _spines;

  static const List<Color> _particleColors = [
    Color(0xFFD9F9FF),
    Color(0xFFE0F2FE),
    Color(0xFFEDE9FE),
    Color(0xFFD1FAE5),
    Color(0xFFF0FDFA),
  ];

  // Muted, classic book colors
  static const List<Color> _bookColors = [
    Color(0xFFB91C1C), // crimson
    Color(0xFFB45309), // amber brown
    Color(0xFF0F766E), // teal
    Color(0xFF1D4ED8), // blue
    Color(0xFF6D28D9), // violet
    Color(0xFFBE185D), // rose
    Color(0xFF15803D), // green
    Color(0xFFCA8A04), // gold
  ];

  @override
  void initState() {
    super.initState();

    // One full loop = 40s (integer loop counts keep animation seamless)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();

    _particles = List.generate(
      35,
          (i) => _Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 2 + _random.nextDouble() * 3.5,
        loops: 1 + _random.nextInt(2),
        sway: 1 + _random.nextInt(3),
        phase: _random.nextDouble() * 2 * pi,
        opacity: 0.18 + _random.nextDouble() * 0.30,
        color: _particleColors[_random.nextInt(_particleColors.length)],
      ),
    );

    _books = List.generate(
      9,
          (i) => _FloatingBook(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 26 + _random.nextDouble() * 20,
        loops: 1,
        phase: _random.nextDouble() * 2 * pi,
        baseAngle: (_random.nextDouble() - 0.5) * 0.8,
        isOpen: i % 3 == 0,
        opacity: 0.30 + _random.nextDouble() * 0.20,
        color: _bookColors[_random.nextInt(_bookColors.length)],
      ),
    );

    _spines = List.generate(
      80,
          (i) => _Spine(
        width: 6 + _random.nextDouble() * 6,
        heightFactor: 0.55 + _random.nextDouble() * 0.45,
        color: _bookColors[_random.nextInt(_bookColors.length)],
        hasBand: _random.nextBool(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0B1B3A), // deep navy
            Color(0xFF1E3A8A), // royal blue
            Color(0xFF0F766E), // teal
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: ClipRect(
                child: CustomPaint(
                  painter: _LibraryPainter(
                    controller: _controller,
                    particles: _particles,
                    books: _books,
                    spines: _spines,
                  ),
                ),
              ),
            ),
          ),
          if (widget.child != null) Positioned.fill(child: widget.child!),
        ],
      ),
    );
  }
}

// ───────────────────────── Data models ─────────────────────────

class _Particle {
  final double x, y, size, opacity, phase;
  final int loops, sway;
  final Color color;
  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.loops,
    required this.sway,
    required this.phase,
    required this.opacity,
    required this.color,
  });
}

class _FloatingBook {
  final double x, y, size, phase, baseAngle, opacity;
  final int loops;
  final bool isOpen;
  final Color color;
  _FloatingBook({
    required this.x,
    required this.y,
    required this.size,
    required this.loops,
    required this.phase,
    required this.baseAngle,
    required this.isOpen,
    required this.opacity,
    required this.color,
  });
}

class _Spine {
  final double width, heightFactor;
  final Color color;
  final bool hasBand;
  _Spine({
    required this.width,
    required this.heightFactor,
    required this.color,
    required this.hasBand,
  });
}

// ───────────────────────── Painter ─────────────────────────

class _LibraryPainter extends CustomPainter {
  final AnimationController controller;
  final List<_Particle> particles;
  final List<_FloatingBook> books;
  final List<_Spine> spines;

  _LibraryPainter({
    required this.controller,
    required this.particles,
    required this.books,
    required this.spines,
  }) : super(repaint: controller);

  double get t => controller.value;

  @override
  void paint(Canvas canvas, Size size) {
    _paintGlows(canvas, size);
    _paintShelf(canvas, size, left: true);
    _paintShelf(canvas, size, left: false);
    _paintParticles(canvas, size);
    _paintFloatingBooks(canvas, size);
  }

  // ---------- Glows ----------
  void _glow(Canvas canvas, Offset c, double r, Color color, double o) {
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [color.withOpacity(o), color.withOpacity(0)],
        ).createShader(rect),
    );
  }

  void _paintGlows(Canvas canvas, Size size) {
    _glow(canvas, Offset(size.width * 0.15, size.height * 0.2), 220,
        const Color(0xFF67E8F9), 0.16);
    _glow(canvas, Offset(size.width * 0.9, size.height * 0.45), 260,
        const Color(0xFFE0F2FE), 0.12);
    _glow(canvas, Offset(size.width * 0.5, size.height * 1.0), 240,
        const Color(0xFFC4B5FD), 0.16);

    // Soft moving "reading lamp" light
    final lx = size.width * (0.5 + 0.2 * sin(t * 2 * pi));
    final ly = size.height * (0.3 + 0.08 * cos(t * 2 * pi));
    _glow(canvas, Offset(lx, ly), 150, const Color(0xFFFDE68A), 0.10);
  }

  // ---------- Side bookshelves ----------
  double _shelfWidth(Size size) => min(64.0, size.width * 0.14);

  void _paintShelf(Canvas canvas, Size size, {required bool left}) {
    final shelfW = _shelfWidth(size);
    final x0 = left ? 0.0 : size.width - shelfW;

    // dark gradient panel fading toward the center
    final panel = Rect.fromLTWH(x0, 0, shelfW, size.height);
    canvas.drawRect(
      panel,
      Paint()
        ..shader = LinearGradient(
          begin: left ? Alignment.centerLeft : Alignment.centerRight,
          end: left ? Alignment.centerRight : Alignment.centerLeft,
          colors: [
            Colors.black.withOpacity(0.32),
            Colors.black.withOpacity(0.0),
          ],
        ).createShader(panel),
    );

    const rowH = 78.0;
    final rows = (size.height / rowH).ceil();
    final boardPaint = Paint()..color = const Color(0xFFFDE68A).withOpacity(0.22);

    for (int r = 0; r < rows; r++) {
      final boardTop = (r + 1) * rowH - 6;
      double cx = x0 + 4;
      int i = r * 5 + (left ? 0 : 11);

      while (true) {
        final s = spines[i % spines.length];
        i++;
        if (cx + s.width > x0 + shelfW - 4) break;

        final h = (rowH - 16) * s.heightFactor;
        final rect = Rect.fromLTWH(cx, boardTop - h, s.width, h);
        final rrect =
        RRect.fromRectAndRadius(rect, const Radius.circular(1.5));

        canvas.drawRRect(
            rrect, Paint()..color = s.color.withOpacity(0.55));
        // edge highlight
        canvas.drawRect(
          Rect.fromLTWH(cx, boardTop - h, 1.2, h),
          Paint()..color = Colors.white.withOpacity(0.12),
        );
        if (s.hasBand) {
          canvas.drawRect(
            Rect.fromLTWH(cx, boardTop - h * 0.78, s.width, 2),
            Paint()..color = const Color(0xFFFDE68A).withOpacity(0.45),
          );
          canvas.drawRect(
            Rect.fromLTWH(cx, boardTop - h * 0.22, s.width, 2),
            Paint()..color = const Color(0xFFFDE68A).withOpacity(0.45),
          );
        }
        cx += s.width + 1.2;
      }

      // shelf board
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x0, boardTop, shelfW, 6),
          const Radius.circular(2),
        ),
        boardPaint,
      );
    }
  }

  // ---------- Particles ----------
  void _paintParticles(Canvas canvas, Size size) {
    for (final p in particles) {
      final sway = sin(t * 2 * pi * p.sway + p.phase) * 22;
      final x = p.x * size.width + sway;
      final y = ((p.y - t * p.loops) % 1.0) * size.height;

      canvas.drawCircle(
        Offset(x, y),
        p.size * 2.6,
        Paint()..color = p.color.withOpacity(0.07),
      );
      canvas.drawCircle(
        Offset(x, y),
        p.size,
        Paint()..color = p.color.withOpacity(p.opacity),
      );
    }
  }

  // ---------- Floating books ----------
  void _paintFloatingBooks(Canvas canvas, Size size) {
    final shelfW = _shelfWidth(size);
    final usable = max(size.width - 2 * shelfW - 40, 40.0);
    const margin = 70.0;

    for (final b in books) {
      final x = shelfW + 20 + b.x * usable + sin(t * 2 * pi + b.phase) * 18;
      final frac = (b.y - t * b.loops) % 1.0;
      final y = frac * (size.height + 2 * margin) - margin;
      final angle = b.baseAngle + 0.15 * sin(t * 2 * pi + b.phase);

      if (b.isOpen) {
        _drawOpenBook(canvas, Offset(x, y), b.size, angle, b.color, b.opacity);
      } else {
        _drawClosedBook(
            canvas, Offset(x, y), b.size, angle, b.color, b.opacity);
      }
    }
  }

  void _drawClosedBook(Canvas c, Offset center, double s, double angle,
      Color color, double o) {
    c.save();
    c.translate(center.dx, center.dy);
    c.rotate(angle);

    final w = s * 0.75;
    final h = s;
    final cover = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: w, height: h),
      Radius.circular(s * 0.07),
    );

    // glow
    c.drawRRect(
      cover,
      Paint()
        ..color = color.withOpacity(o * 0.5)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.3),
    );
    // cover
    c.drawRRect(cover, Paint()..color = color.withOpacity(o));

    c.save();
    c.clipRRect(cover);
    // spine shade
    c.drawRect(
      Rect.fromLTWH(-w / 2, -h / 2, w * 0.14, h),
      Paint()..color = Colors.black.withOpacity(o * 0.28),
    );
    // gold title lines
    final line = Paint()
      ..color = const Color(0xFFFDE68A).withOpacity(o * 0.9)
      ..strokeWidth = max(1.2, s * 0.045)
      ..strokeCap = StrokeCap.round;
    c.drawLine(Offset(-w * 0.18, -h * 0.22), Offset(w * 0.30, -h * 0.22), line);
    c.drawLine(Offset(-w * 0.18, -h * 0.10), Offset(w * 0.18, -h * 0.10), line);
    c.restore();

    // page edge
    c.drawRect(
      Rect.fromLTWH(w / 2 - 1.5, -h / 2 + 2, 1.5, h - 4),
      Paint()..color = Colors.white.withOpacity(o * 0.8),
    );
    c.restore();
  }

  void _drawOpenBook(Canvas c, Offset center, double s, double angle,
      Color color, double o) {
    c.save();
    c.translate(center.dx, center.dy);
    c.rotate(angle);

    final w = s * 1.3;
    final h = s * 0.85;

    // soft glow
    c.drawOval(
      Rect.fromCenter(center: Offset.zero, width: w, height: h * 0.9),
      Paint()
        ..color = Colors.white.withOpacity(o * 0.18)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.3),
    );

    for (final sign in [-1.0, 1.0]) {
      // cover under the pages
      final coverPath = Path()
        ..moveTo(0, -h * 0.30)
        ..quadraticBezierTo(sign * w * 0.25, -h * 0.46, sign * w * 0.54, -h * 0.34)
        ..lineTo(sign * w * 0.54, h * 0.46)
        ..quadraticBezierTo(sign * w * 0.25, h * 0.36, 0, h * 0.52)
        ..close();
      c.drawPath(coverPath, Paint()..color = color.withOpacity(o));

      // page
      final page = Path()
        ..moveTo(0, -h * 0.35)
        ..quadraticBezierTo(sign * w * 0.25, -h * 0.50, sign * w * 0.50, -h * 0.40)
        ..lineTo(sign * w * 0.50, h * 0.40)
        ..quadraticBezierTo(sign * w * 0.25, h * 0.30, 0, h * 0.45)
        ..close();
      c.drawPath(page, Paint()..color = const Color(0xFFF8FAFC).withOpacity(o));

      // text lines
      final line = Paint()
        ..color = const Color(0xFF64748B).withOpacity(o * 0.7)
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round;
      for (int i = 0; i < 4; i++) {
        final ly = -h * 0.22 + i * h * 0.15;
        c.drawLine(Offset(sign * w * 0.10, ly),
            Offset(sign * w * 0.42, ly - 1.5), line);
      }
    }

    // center fold
    c.drawLine(
      Offset(0, -h * 0.35),
      Offset(0, h * 0.45),
      Paint()
        ..color = Colors.black.withOpacity(o * 0.25)
        ..strokeWidth = 1.2,
    );
    c.restore();
  }

  @override
  bool shouldRepaint(covariant _LibraryPainter oldDelegate) => true;
}