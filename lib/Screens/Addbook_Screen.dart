import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Pickers/Library_Pickers.dart';
import '../Store/LibraryStore.dart';
import '../models/books_model.dart';
import '../widgets/background.dart';


class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  static const Color gold = Color(0xFFFDE68A);
  static const Color amber = Color(0xFFF59E0B);

  final _title = TextEditingController();
  final _author = TextEditingController();
  final _isbn = TextEditingController();
  final _publisher = TextEditingController();
  final _year = TextEditingController();
  final _pages = TextEditingController();
  final _shelf = TextEditingController();
  final _description = TextEditingController();

  final List<String> _categories = [
    'Science',
    'Fiction',
    'Tech',
    'Self Help',
    'History',
    'Other',
  ];

  final List<List<Color>> _coverColors = const [
    [Color(0xFFB91C1C), Color(0xFF7F1D1D)],
    [Color(0xFF1D4ED8), Color(0xFF1E3A8A)],
    [Color(0xFF0F766E), Color(0xFF134E4A)],
    [Color(0xFF6D28D9), Color(0xFF4C1D95)],
    [Color(0xFFB45309), Color(0xFF78350F)],
    [Color(0xFFBE185D), Color(0xFF831843)],
  ];

  String _category = 'Science';
  int _colorIndex = 0;
  int _copies = 1;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [
      _title,
      _author,
      _isbn,
      _publisher,
      _year,
      _pages,
      _shelf,
      _description
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty || _author.text.trim().isEmpty) {
      showMsg(context, 'Book title aur author zaroori hain', error: true);
      return;
    }

    setState(() => _saving = true);
    try {
      final book = Book(
        title: _title.text.trim(),
        author: _author.text.trim(),
        category: _category,
        isbn: _isbn.text.trim(),
        publisher: _publisher.text.trim(),
        description: _description.text.trim(),
        shelf: _shelf.text.trim(),
        year: int.tryParse(_year.text.trim()) ?? 0,
        pages: int.tryParse(_pages.text.trim()) ?? 0,
        totalCopies: _copies,
        availableCopies: _copies,
        colorIndex: _colorIndex,
      );

      await LibraryStore.instance.addBook(book);

      if (!mounted) return;
      showMsg(context, '"${book.title}" added successfully');
      Navigator.pop(context);
    } catch (e) {
      if (mounted) showMsg(context, friendlyError(e), error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

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
                      _buildCoverSection(),
                      const SizedBox(height: 24),
                      _sectionTitle('Basic Information'),
                      const SizedBox(height: 12),
                      _field(
                        label: 'Book Title *',
                        hint: 'e.g. Atomic Habits',
                        icon: Icons.title_rounded,
                        controller: _title,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 14),
                      _field(
                        label: 'Author *',
                        hint: 'e.g. James Clear',
                        icon: Icons.person_outline_rounded,
                        controller: _author,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 14),
                      _field(
                        label: 'ISBN',
                        hint: '978-0735211292',
                        icon: Icons.qr_code_rounded,
                        controller: _isbn,
                        keyboard: TextInputType.number,
                      ),
                      const SizedBox(height: 14),
                      _field(
                        label: 'Publisher',
                        hint: 'e.g. Penguin Random House',
                        icon: Icons.business_rounded,
                        controller: _publisher,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _field(
                              label: 'Year',
                              hint: '2018',
                              icon: Icons.calendar_today_rounded,
                              controller: _year,
                              keyboard: TextInputType.number,
                              digitsOnly: true,
                              maxLength: 4,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _field(
                              label: 'Pages',
                              hint: '320',
                              icon: Icons.menu_book_rounded,
                              controller: _pages,
                              keyboard: TextInputType.number,
                              digitsOnly: true,
                              maxLength: 5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _sectionTitle('Category'),
                      const SizedBox(height: 12),
                      _buildCategoryChips(),
                      const SizedBox(height: 24),
                      _sectionTitle('Inventory'),
                      const SizedBox(height: 12),
                      _buildCopiesStepper(),
                      const SizedBox(height: 14),
                      _field(
                        label: 'Shelf Location',
                        hint: 'e.g. Shelf B-12',
                        icon: Icons.location_on_outlined,
                        controller: _shelf,
                      ),
                      const SizedBox(height: 24),
                      _sectionTitle('Description'),
                      const SizedBox(height: 12),
                      _field(
                        label: '',
                        hint: 'Write a short summary of the book…',
                        icon: null,
                        controller: _description,
                        maxLines: 5,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 14,
                child: _buildSaveBar(),
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
          'Add New Book',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 44),
      ],
    );
  }

  // ───────────── Cover preview + color picker ─────────────
  Widget _buildCoverSection() {
    final colors = _coverColors[_colorIndex];
    final title = _title.text.trim().isEmpty ? 'Book Title' : _title.text.trim();
    final author =
    _author.text.trim().isEmpty ? 'Author Name' : _author.text.trim();

    return _GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Live preview
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 108,
            height: 154,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colors.first.withOpacity(0.45),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 11,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.28),
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(12)),
                    ),
                  ),
                ),
                Positioned(
                  left: 22,
                  right: 14,
                  top: 22,
                  child: Column(
                    children: List.generate(
                      3,
                          (i) => Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        height: 2.5,
                        color: gold.withOpacity(i == 2 ? 0.35 : 0.8),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 22,
                  right: 10,
                  bottom: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cover Preview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pick a cover color',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(_coverColors.length, (i) {
                    final selected = i == _colorIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _colorIndex = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: _coverColors[i]),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? gold : Colors.white24,
                            width: selected ? 2.5 : 1.5,
                          ),
                        ),
                        child: selected
                            ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────── Category chips ─────────────
  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: _categories.map((c) {
        final selected = c == _category;
        return GestureDetector(
          onTap: () => setState(() => _category = c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              gradient:
              selected ? const LinearGradient(colors: [gold, amber]) : null,
              color: selected ? null : Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? Colors.transparent
                    : Colors.white.withOpacity(0.15),
              ),
            ),
            child: Text(
              c,
              style: TextStyle(
                color: selected ? const Color(0xFF1E1B0B) : Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ───────────── Copies stepper ─────────────
  Widget _buildCopiesStepper() {
    Widget btn(IconData icon, VoidCallback onTap) {
      return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white),
        ),
      );
    }

    return _GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.inventory_2_rounded,
                color: Colors.white, size: 21),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Number of Copies',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          btn(Icons.remove_rounded, () {
            if (_copies > 1) setState(() => _copies--);
          }),
          SizedBox(
            width: 46,
            child: Text(
              '$_copies',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: gold,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          btn(Icons.add_rounded, () => setState(() => _copies++)),
        ],
      ),
    );
  }

  // ───────────── Section title + field ─────────────
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

  Widget _field({
    required String label,
    required String hint,
    required IconData? icon,
    required TextEditingController controller,
    TextInputType? keyboard,
    int maxLines = 1,
    int? maxLength,
    bool digitsOnly = false,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
        ],
        _GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          radius: 14,
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: keyboard,
            maxLines: maxLines,
            maxLength: maxLength,
            inputFormatters:
            digitsOnly ? [FilteringTextInputFormatter.digitsOnly] : null,
            cursorColor: gold,
            style: const TextStyle(color: Colors.white, fontSize: 14.5),
            decoration: InputDecoration(
              border: InputBorder.none,
              counterText: '',
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              icon: icon == null
                  ? null
                  : Icon(icon, color: Colors.white.withOpacity(0.75), size: 21),
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ],
    );
  }

  // ───────────── Save bar ─────────────
  Widget _buildSaveBar() {
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
            onTap: _saving ? null : _save,
            child: Ink(
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [gold, amber]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.library_add_rounded,
                        color: Color(0xFF1E1B0B), size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Save Book',
                      style: TextStyle(
                        color: Color(0xFF1E1B0B),
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