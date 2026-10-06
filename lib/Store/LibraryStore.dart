import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/books_model.dart';


class LibraryException implements Exception {
  final String message;
  LibraryException(this.message);

  @override
  String toString() => message;
}

/// Saari screens isi se data leti hain. Firestore ke live streams sunta hai
/// aur data badalte hi listeners ko bata deta hai.
class LibraryStore extends ChangeNotifier {
  LibraryStore._();
  static final LibraryStore instance = LibraryStore._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Book> books = [];
  List<Member> members = [];
  List<Loan> loans = [];
  LibrarySettings settings = const LibrarySettings();

  bool _booksLoaded = false;
  bool _membersLoaded = false;
  bool _loansLoaded = false;
  String? error;

  final List<StreamSubscription> _subs = [];

  bool get loading => !(_booksLoaded && _membersLoaded && _loansLoaded);

  // ───────────── Start / stop ─────────────
  void start() {
    if (_subs.isNotEmpty) return;

    _subs.add(_db.collection('books').snapshots().listen((s) {
      books = s.docs.map(Book.fromDoc).toList()
        ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      _booksLoaded = true;
      notifyListeners();
    }, onError: _onError));

    _subs.add(_db.collection('members').snapshots().listen((s) {
      members = s.docs.map(Member.fromDoc).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      _membersLoaded = true;
      notifyListeners();
    }, onError: _onError));

    _subs.add(_db.collection('loans').snapshots().listen((s) {
      loans = s.docs.map(Loan.fromDoc).toList()
        ..sort((a, b) => b.activityTime.compareTo(a.activityTime));
      _loansLoaded = true;
      notifyListeners();
    }, onError: _onError));

    _subs.add(_db.collection('settings').doc('library').snapshots().listen((s) {
      settings = LibrarySettings.fromMap(s.data());
      notifyListeners();
    }, onError: _onError));
  }

  Future<void> stop() async {
    for (final s in _subs) {
      await s.cancel();
    }
    _subs.clear();
    books = [];
    members = [];
    loans = [];
    settings = const LibrarySettings();
    _booksLoaded = _membersLoaded = _loansLoaded = false;
    error = null;
    notifyListeners();
  }

  void _onError(Object e) {
    error = e.toString();
    // error aane par bhi loading band kar do taake spinner na atka rahe
    _booksLoaded = _membersLoaded = _loansLoaded = true;
    notifyListeners();
  }

  // ───────────── Read helpers ─────────────
  List<Loan> get activeLoans => loans.where((l) => l.isActive).toList();
  List<Loan> get overdueLoans => loans.where((l) => l.isOverdue).toList();

  int get totalCopies => books.fold(0, (sum, b) => sum + b.totalCopies);

  List<Loan> activeLoansOfMember(String memberDocId) =>
      activeLoans.where((l) => l.memberId == memberDocId).toList();

  Book? bookById(String id) {
    for (final b in books) {
      if (b.id == id) return b;
    }
    return null;
  }

  Member? memberById(String id) {
    for (final m in members) {
      if (m.id == id) return m;
    }
    return null;
  }

  String nextMemberId() {
    int max = 1000;
    for (final m in members) {
      final n = int.tryParse(m.memberId.replaceAll(RegExp(r'[^0-9]'), ''));
      if (n != null && n > max) max = n;
    }
    return 'LIB-${max + 1}';
  }

  // ───────────── Books ─────────────
  Future<void> addBook(Book book) async {
    await _db.collection('books').add(book.toMap());
  }

  Future<void> deleteBook(String bookId) async {
    if (activeLoans.any((l) => l.bookId == bookId)) {
      throw LibraryException('Ye book abhi issued hai, pehle return karwayein');
    }
    await _db.collection('books').doc(bookId).delete();
  }

  // ───────────── Members ─────────────
  Future<void> addMember(Member member) async {
    await _db.collection('members').add(member.toMap());
  }

  Future<void> setSuspended(String memberDocId, bool suspended) async {
    await _db
        .collection('members')
        .doc(memberDocId)
        .update({'status': suspended ? 'suspended' : 'active'});
  }

  Future<void> deleteMember(String memberDocId) async {
    if (activeLoansOfMember(memberDocId).isNotEmpty) {
      throw LibraryException('Is member ke paas books issued hain');
    }
    await _db.collection('members').doc(memberDocId).delete();
  }

  // ───────────── Issue / Return ─────────────
  Future<void> issueBook(String bookId, String memberDocId) async {
    final member = memberById(memberDocId);
    if (member == null) throw LibraryException('Member nahi mila');
    if (member.suspended) throw LibraryException('Ye member suspended hai');

    final memberLoans = activeLoansOfMember(memberDocId);
    if (memberLoans.length >= settings.maxBooks) {
      throw LibraryException(
          'Is member ki limit (${settings.maxBooks} books) poori ho chuki hai');
    }
    if (memberLoans.any((l) => l.bookId == bookId)) {
      throw LibraryException('Ye book is member ke paas pehle se issued hai');
    }

    final bookRef = _db.collection('books').doc(bookId);
    final loanRef = _db.collection('loans').doc();
    final now = DateTime.now();

    await _db.runTransaction((tx) async {
      final snap = await tx.get(bookRef);
      if (!snap.exists) throw LibraryException('Book nahi mili');

      final data = snap.data() as Map<String, dynamic>;
      final available = (data['availableCopies'] ?? 0) as int;
      if (available <= 0) throw LibraryException('Is book ki koi copy available nahi');

      tx.update(bookRef, {'availableCopies': available - 1});
      tx.set(loanRef, {
        'bookId': bookId,
        'bookTitle': data['title'] ?? '',
        'memberId': memberDocId,
        'memberName': member.name,
        'issuedAt': Timestamp.fromDate(now),
        'dueDate': Timestamp.fromDate(now.add(Duration(days: settings.loanDays))),
        'returnedAt': null,
      });
    });
  }

  /// Return karta hai aur fine (agar hai) wapas deta hai.
  Future<int> returnLoan(Loan loan) async {
    final fine = loan.overdueDays * settings.finePerDay;
    final bookRef = _db.collection('books').doc(loan.bookId);
    final loanRef = _db.collection('loans').doc(loan.id);

    await _db.runTransaction((tx) async {
      final bookSnap = await tx.get(bookRef);

      tx.update(loanRef, {'returnedAt': Timestamp.now()});
      if (bookSnap.exists) {
        final data = bookSnap.data() as Map<String, dynamic>;
        final available = (data['availableCopies'] ?? 0) as int;
        final total = (data['totalCopies'] ?? 1) as int;
        tx.update(bookRef, {
          'availableCopies': available + 1 > total ? total : available + 1,
        });
      }
    });
    return fine;
  }

  // ───────────── Settings ─────────────
  Future<void> updateSettings({int? loanDays, int? finePerDay, int? maxBooks}) async {
    final map = <String, dynamic>{};
    if (loanDays != null) map['loanDays'] = loanDays;
    if (finePerDay != null) map['finePerDay'] = finePerDay;
    if (maxBooks != null) map['maxBooks'] = maxBooks;
    await _db.collection('settings').doc('library').set(map, SetOptions(merge: true));
  }
}