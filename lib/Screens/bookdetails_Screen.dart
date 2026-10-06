import 'dart:ui';
import 'package:flutter/material.dart';
import '../Pickers/Library_Pickers.dart';
import '../Store/LibraryStore.dart';
import '../widgets/background.dart';


class BookDetailsScreen extends StatefulWidget {
  final String bookId;
  final String title;
  final String author;
  final String category;
  final List<Color> colors;
  final double rating;
  final int pages;
  final int year;
  final int availableCopies;
  final int totalCopies;
  final String description;
  final String publisher;
  final String isbn;
  final String shelf;

  const BookDetailsScreen({
    super.key,
    required this.bookId,
    this.title = 'Atomic Habits',
    this.author = 'James Clear',
    this.category = 'Self Help',
    this.colors = const [Color(0xFFB91C1C), Color(0xFF7F1D1D)],
    this.rating = 4.8,
    this.pages = 320,
    this.year = 2018,
    this.availableCopies = 5,
    this.totalCopies = 8,
    this.description =
    'A practical and proven guide to building good habits and breaking '
        'bad ones. Learn how tiny daily changes compound into remarkable '
        'results over time, and how to design your environment and '
        'identity for lasting success.',
    this.publisher = 'Penguin Random House',
    this.isbn = '978-0735211292',
    this.shelf = 'Shelf B-12',
  });

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  static const Color gold = Color(0xFFFDE68A);
  static const Color amber = Color(0xFFF59E0B);

  bool _expanded = false;

  bool get _available => widget.availableCopies > 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Background(
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(),
                      const SizedBox(height: 18),
                      Center(child: _buildCover()),
                      const SizedBox(height: 22),
                      _buildTitleBlock(),
                      const SizedBox(height: 20),
                      _buildMeta(),
                      const SizedBox(height: 22),
                      _sectionTitle('About this book'),
                      const SizedBox(height: 8),
                      _buildDescription(),
                      const SizedBox(height: 22),
                      _sectionTitle('Book Information'),
                      const SizedBox(height: 10),
                      _buildInfoCard(),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 14,
                child: _buildIssueBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────── Top bar ─────────────
  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.maybePop(context),
          child: const _GlassCard(
            padding: EdgeInsets.all(10),
            radius: 14,
            child: Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
          ),
        ),
        const Text(
          'Book Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _confirmDelete,
          child: const _GlassCard(
            padding: EdgeInsets.all(10),
            radius: 14,
            child: Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFFCA5A5),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  // ───────────── Big cover ─────────────
  Widget _buildCover() {
    return Container(
      width: 160,
      height: 228,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: widget.colors.first.withOpacity(0.45),
            blurRadius: 36,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // spine
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 16,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.28),
                borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(16)),
              ),
            ),
          ),
          // gold lines
          Positioned(
            left: 32,
            right: 22,
            top: 34,
            child: Column(
              children: List.generate(
                3,
                    (i) => Container(
                  margin: const EdgeInsets.only(bottom: 9),
                  height: 3,
                  color: gold.withOpacity(i == 2 ? 0.35 : 0.8),
                ),
              ),
            ),
          ),
          // title on cover
          Positioned(
            left: 32,
            right: 14,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────── Title / author / rating ─────────────
  Widget _buildTitleBlock() {
    return Center(
      child: Column(
        children: [
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'by ${widget.author}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _pill(widget.category, gold),
              const SizedBox(width: 8),
              _available
                  ? _pill('Available', const Color(0xFF6EE7B7))
                  : _pill('Issued', const Color(0xFFFCA5A5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ───────────── Meta row ─────────────
  Widget _buildMeta() {
    Widget item(IconData icon, String value, String label) {
      return Expanded(
        child: Column(
          children: [
            Icon(icon, color: gold, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    Widget divider() => Container(
      width: 1,
      height: 44,
      color: Colors.white.withOpacity(0.15),
    );

    return _GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          item(Icons.menu_book_rounded, '${widget.pages}', 'Pages'),
          divider(),
          item(Icons.calendar_today_rounded, '${widget.year}', 'Year'),
          divider(),
          item(Icons.inventory_2_rounded,
              '${widget.availableCopies}/${widget.totalCopies}', 'Copies'),
        ],
      ),
    );
  }

  // ───────────── Description ─────────────
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          alignment: Alignment.topCenter,
          child: Text(
            widget.description,
            maxLines: _expanded ? null : 3,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.78),
              fontSize: 14,
              height: 1.55,
            ),
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Text(
            _expanded ? 'Show less' : 'Read more',
            style: const TextStyle(
              color: gold,
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
          ),
        ),
      ],
    );
  }

  // ───────────── Info card ─────────────
  Widget _buildInfoCard() {
    Widget row(IconData icon, String label, String value, {bool last = false}) {
      return Padding(
        padding: EdgeInsets.only(bottom: last ? 0 : 14),
        child: Row(
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.7), size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontSize: 13.5,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _GlassCard(
      child: Column(
        children: [
          row(Icons.business_rounded, 'Publisher', widget.publisher),
          row(Icons.qr_code_rounded, 'ISBN', widget.isbn),
          row(Icons.category_rounded, 'Category', widget.category),
          row(Icons.location_on_rounded, 'Location', widget.shelf, last: true),
        ],
      ),
    );
  }

  // ───────────── Bottom issue bar ─────────────
  Widget _buildIssueBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1220).withOpacity(0.75),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _available ? _issue : null,
            child: Container(
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: _available
                    ? const LinearGradient(colors: [gold, amber])
                    : null,
                color: _available ? null : Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _available
                        ? Icons.bookmark_add_rounded
                        : Icons.lock_clock_rounded,
                    color: _available
                        ? const Color(0xFF1E1B0B)
                        : Colors.white60,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _available ? 'Issue This Book' : 'Currently Unavailable',
                    style: TextStyle(
                      color: _available
                          ? const Color(0xFF1E1B0B)
                          : Colors.white60,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _issue() async {
    final ok = await issueFlow(context, bookId: widget.bookId);
    if (ok && mounted) Navigator.pop(context);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F1B33),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        title: const Text(
          'Delete this book?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        content: Text(
          '"${widget.title}" library se hamesha ke liye hata di jayegi.',
          style: TextStyle(color: Colors.white.withOpacity(0.75)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await LibraryStore.instance.deleteBook(widget.bookId);
                if (!mounted) return;
                showMsg(context, '"${widget.title}" delete ho gayi');
                Navigator.pop(context);
              } catch (e) {
                if (mounted) showMsg(context, friendlyError(e), error: true);
              }
            },
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFFCA5A5))),
          ),
        ],
      ),
    );
  }
}

// ───────────── Glass card ─────────────

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 18,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.09),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: child,
        ),
      ),
    );
  }
}