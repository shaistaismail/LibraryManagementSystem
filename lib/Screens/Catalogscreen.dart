import 'dart:ui';
import 'package:flutter/material.dart';
import '../Store/LibraryStore.dart';

import '../models/books_model.dart';
import 'bookdetails_Screen.dart';


// ───────────── Screen ─────────────

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  static const Color gold = Color(0xFFFDE68A);
  static const Color amber = Color(0xFFF59E0B);

  final TextEditingController _search = TextEditingController();
  final List<String> _categories = [
    'All',
    'Science',
    'Fiction',
    'Tech',
    'Self Help',
    'History',
    'Other',
  ];

  String _selected = 'All';
  String _query = '';

  final LibraryStore _store = LibraryStore.instance;

  void _onStore() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStore);
  }

  @override
  void dispose() {
    _store.removeListener(_onStore);
    _search.dispose();
    super.dispose();
  }

  List<Book> get _filtered {
    return _store.books.where((b) {
      final matchCat = _selected == 'All' || b.category == _selected;
      final q = _query.trim().toLowerCase();
      final matchSearch = q.isEmpty ||
          b.title.toLowerCase().contains(q) ||
          b.author.toLowerCase().contains(q);
      return matchCat && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final books = _filtered;

    return SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _buildHeader(),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildSearchBar(),
                ),
                const SizedBox(height: 14),
                _buildChips(),
                const SizedBox(height: 12),
                Expanded(
                  child: books.isEmpty
                      ? (_store.loading
                      ? const Center(
                      child: CircularProgressIndicator(color: gold))
                      : _buildEmpty())
                      : GridView.builder(
                    padding:
                    const EdgeInsets.fromLTRB(20, 4, 20, 110),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.66,
                    ),
                    itemCount: books.length,
                    itemBuilder: (context, i) =>
                        _BookCard(book: books[i]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────── Header ─────────────
  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Book Catalog',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_filtered.length} books found',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {},
          child: const _GlassCard(
            padding: EdgeInsets.all(10),
            radius: 14,
            child: Icon(Icons.tune_rounded, color: Colors.white, size: 24),
          ),
        ),
      ],
    );
  }

  // ───────────── Search ─────────────
  Widget _buildSearchBar() {
    return _GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      radius: 16,
      child: TextField(
        controller: _search,
        onChanged: (v) => setState(() => _query = v),
        style: const TextStyle(color: Colors.white, fontSize: 14.5),
        cursorColor: gold,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Search title, author…',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.55)),
          icon: Icon(Icons.search_rounded,
              color: Colors.white.withOpacity(0.75)),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white70),
            onPressed: () {
              _search.clear();
              setState(() => _query = '');
            },
          ),
        ),
      ),
    );
  }

  // ───────────── Category chips ─────────────
  Widget _buildChips() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = _categories[i];
          final selected = cat == _selected;
          return GestureDetector(
            onTap: () => setState(() => _selected = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                gradient: selected
                    ? const LinearGradient(colors: [gold, amber])
                    : null,
                color: selected ? null : Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? Colors.transparent
                      : Colors.white.withOpacity(0.15),
                ),
              ),
              child: Center(
                child: Text(
                  cat,
                  style: TextStyle(
                    color: selected ? const Color(0xFF1E1B0B) : Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ───────────── Empty state ─────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_rounded,
              size: 64, color: Colors.white.withOpacity(0.4)),
          const SizedBox(height: 12),
          const Text(
            'No books found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different title or category',
            style: TextStyle(color: Colors.white.withOpacity(0.65)),
          ),
        ],
      ),
    );
  }
}

// ───────────── Book card ─────────────

class _BookCard extends StatelessWidget {
  final Book book;
  const _BookCard({required this.book});

  (String, Color) get _statusInfo {
    if (book.availableCopies <= 0) {
      return ('Issued', const Color(0xFFFCA5A5));
    }
    if (book.availableCopies <= 2) {
      return ('${book.availableCopies} left', const Color(0xFFFCD34D));
    }
    return ('Available', const Color(0xFF6EE7B7));
  }

  @override
  Widget build(BuildContext context) {
    final (label, color) = _statusInfo;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookDetailsScreen(
            bookId: book.id,
            title: book.title,
            author: book.author,
            category: book.category,
            colors: book.colors,
            pages: book.pages,
            year: book.year,
            availableCopies: book.availableCopies,
            totalCopies: book.totalCopies,
            description: book.description.isEmpty
                ? 'No description added for this book.'
                : book.description,
            publisher: book.publisher.isEmpty ? '—' : book.publisher,
            isbn: book.isbn.isEmpty ? '—' : book.isbn,
            shelf: book.shelf.isEmpty ? '—' : book.shelf,
          ),
        ),
      ),
      child: _GlassCard(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: book.colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
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
                        width: 10,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.28),
                          borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(12)),
                        ),
                      ),
                    ),
                    // gold lines
                    Positioned(
                      left: 22,
                      right: 16,
                      top: 18,
                      child: Column(
                        children: List.generate(
                          3,
                              (i) => Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            height: 2,
                            width: double.infinity,
                            color: const Color(0xFFFDE68A)
                                .withOpacity(i == 2 ? 0.35 : 0.7),
                          ),
                        ),
                      ),
                    ),
                    // category
                    Positioned(
                      left: 22,
                      bottom: 10,
                      right: 8,
                      child: Text(
                        book.category.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFFDE68A),
                          fontSize: 9.5,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              book.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              book.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontSize: 11.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
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