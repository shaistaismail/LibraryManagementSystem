import 'package:flutter/material.dart';
import '../Store/LibraryStore.dart';
import '../models/books_model.dart';
// Agar Member aur Loan classes alag files mein hain to unke imports yahan add karein:
// import '../models/member_model.dart';
// import '../models/loan_model.dart';

const Color _gold = Color(0xFFFDE68A);

void showMsg(BuildContext context, String text, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
        error ? const Color(0xFFB91C1C) : const Color(0xFF0F766E),
        content: Text(text),
      ),
    );
}

String friendlyError(Object e) {
  final s = e.toString();
  if (s.contains('permission-denied')) {
    return 'Firestore permission denied. Rules check karein.';
  }
  return s.replaceFirst('Exception: ', '');
}

// ───────────── Generic searchable picker ─────────────
Future<T?> _pick<T>(
    BuildContext context, {
      required String title,
      required String emptyText,
      required List<T> items,
      required String Function(T) titleOf,
      required String Function(T) subtitleOf,
      required IconData icon,
      Widget Function(T)? trailing,
    }) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF0F1B33),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) {
      String query = '';
      return StatefulBuilder(
        builder: (ctx, setSheet) {
          final q = query.toLowerCase();
          final filtered = items
              .where((i) =>
          titleOf(i).toLowerCase().contains(q) ||
              subtitleOf(i).toLowerCase().contains(q))
              .toList();

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.7,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                    child: TextField(
                      onChanged: (v) => setSheet(() => query = v),
                      style: const TextStyle(color: Colors.white),
                      cursorColor: _gold,
                      decoration: InputDecoration(
                        hintText: 'Search…',
                        hintStyle: const TextStyle(color: Colors.white54),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.08),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                      child: Text(
                        emptyText,
                        style: const TextStyle(color: Colors.white60),
                      ),
                    )
                        : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final item = filtered[i];
                        return ListTile(
                          onTap: () => Navigator.pop(ctx, item),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          leading: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child:
                            Icon(icon, color: Colors.white, size: 21),
                          ),
                          title: Text(
                            titleOf(item),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(
                            subtitleOf(item),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white60),
                          ),
                          trailing:
                          trailing == null ? null : trailing(item),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

// ───────────── Issue flow (COMPLETE) ─────────────
/// Agar [bookId] diya ho to sirf member chunta hai, warna pehle book chunta hai.
/// Success par true return karta hai.
Future<bool> issueFlow(BuildContext context, {String? bookId}) async {
  final store = LibraryStore.instance;

  // ---- Step 1: book chunein (agar pehle se nahi di gayi) ----
  String? selectedBookId = bookId;
  if (selectedBookId == null) {
    final available =
    store.books.where((b) => (b.availableCopies ?? 0) > 0).toList();

    final book = await _pick<Book>(
      context,
      title: 'Select Book',
      emptyText: 'Koi available book nahi',
      items: available,
      titleOf: (b) => b.title ?? '',
      subtitleOf: (b) => b.author ?? '',
      icon: Icons.menu_book_rounded,
      trailing: (b) => Text(
        '${b.availableCopies ?? 0} left',
        style: const TextStyle(color: _gold, fontWeight: FontWeight.w700),
      ),
    );
    if (book == null || !context.mounted) return false;
    selectedBookId = book.id;
  }

  final bId = selectedBookId;
  if (bId == null || bId.isEmpty) return false;

  // ---- Step 2: member chunein ----
  final active = store.members.where((m) => m.suspended != true).toList();

  final member = await _pick<Member>(
    context,
    title: 'Select Member',
    emptyText: 'Koi active member nahi',
    items: active,
    titleOf: (m) => m.name ?? '',
    subtitleOf: (m) => '${m.memberId ?? ''} · ${m.type ?? ''}',
    icon: Icons.person_rounded,
  );
  if (member == null || !context.mounted) return false;

  final mId = member.id;
  if (mId == null || mId.isEmpty) return false;

  // ---- Step 3: issue karein ----
  try {
    await store.issueBook(bId, mId);
    if (context.mounted) {
      final title = store.bookById(bId)?.title ?? 'Book';
      showMsg(
        context,
        '"$title" ${member.name ?? 'member'} ko issue ho gayi '
            '(${store.settings.loanDays} days)',
      );
    }
    return true;
  } catch (e) {
    if (context.mounted) showMsg(context, friendlyError(e), error: true);
    return false;
  }
}

// ───────────── Return flow ─────────────
Future<void> returnFlow(BuildContext context) async {
  final store = LibraryStore.instance;
  final active = List<Loan>.from(store.activeLoans)
    ..sort((a, b) => (a.dueDate ?? DateTime.now())
        .compareTo(b.dueDate ?? DateTime.now()));

  final loan = await _pick<Loan>(
    context,
    title: 'Return a Book',
    emptyText: 'Koi issued book nahi',
    items: active,
    titleOf: (l) => l.bookTitle ?? '',
    subtitleOf: (l) => l.memberName ?? '',
    icon: Icons.assignment_return_rounded,
    trailing: (l) {
      final late = l.isOverdue == true;
      return Text(
        late ? '${l.overdueDays ?? 0}d late' : 'On time',
        style: TextStyle(
          color: late ? const Color(0xFFFCA5A5) : const Color(0xFF6EE7B7),
          fontWeight: FontWeight.w700,
        ),
      );
    },
  );
  if (loan == null || !context.mounted) return;

  try {
    final int fine = (await store.returnLoan(loan)) ?? 0;
    if (context.mounted) {
      showMsg(
        context,
        fine > 0
            ? '"${loan.bookTitle}" return hui · Fine: Rs. $fine'
            : '"${loan.bookTitle}" return ho gayi',
      );
    }
  } catch (e) {
    if (context.mounted) showMsg(context, friendlyError(e), error: true);
  }
}