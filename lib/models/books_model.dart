import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const List<List<Color>> kCoverColors = [
  [Color(0xFFB91C1C), Color(0xFF7F1D1D)],
  [Color(0xFF1D4ED8), Color(0xFF1E3A8A)],
  [Color(0xFF0F766E), Color(0xFF134E4A)],
  [Color(0xFF6D28D9), Color(0xFF4C1D95)],
  [Color(0xFFB45309), Color(0xFF78350F)],
  [Color(0xFFBE185D), Color(0xFF831843)],
];

DateTime? _date(dynamic v) => v is Timestamp ? v.toDate() : null;

// ───────────── Book ─────────────
class Book {
  final String id;
  final String title;
  final String author;
  final String category;
  final String isbn;
  final String publisher;
  final String description;
  final String shelf;
  final int year;
  final int pages;
  final int totalCopies;
  final int availableCopies;
  final int colorIndex;

  const Book({
    this.id = '',
    required this.title,
    required this.author,
    this.category = 'Other',
    this.isbn = '',
    this.publisher = '',
    this.description = '',
    this.shelf = '',
    this.year = 0,
    this.pages = 0,
    this.totalCopies = 1,
    this.availableCopies = 1,
    this.colorIndex = 0,
  });

  List<Color> get colors => kCoverColors[colorIndex % kCoverColors.length];

  factory Book.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    return Book(
      id: d.id,
      title: m['title'] ?? '',
      author: m['author'] ?? '',
      category: m['category'] ?? 'Other',
      isbn: m['isbn'] ?? '',
      publisher: m['publisher'] ?? '',
      description: m['description'] ?? '',
      shelf: m['shelf'] ?? '',
      year: (m['year'] ?? 0) as int,
      pages: (m['pages'] ?? 0) as int,
      totalCopies: (m['totalCopies'] ?? 1) as int,
      availableCopies: (m['availableCopies'] ?? 0) as int,
      colorIndex: (m['colorIndex'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'author': author,
    'category': category,
    'isbn': isbn,
    'publisher': publisher,
    'description': description,
    'shelf': shelf,
    'year': year,
    'pages': pages,
    'totalCopies': totalCopies,
    'availableCopies': availableCopies,
    'colorIndex': colorIndex,
    'createdAt': FieldValue.serverTimestamp(),
  };
}

// ───────────── Member ─────────────
class Member {
  final String id; // Firestore document id
  final String memberId; // e.g. LIB-1001
  final String name;
  final String type;
  final String email;
  final String phone;
  final bool suspended;

  const Member({
    this.id = '',
    required this.memberId,
    required this.name,
    this.type = 'Student',
    this.email = '',
    this.phone = '',
    this.suspended = false,
  });

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  List<Color> get colors => kCoverColors[name.hashCode.abs() % kCoverColors.length];

  factory Member.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    return Member(
      id: d.id,
      memberId: m['memberId'] ?? '',
      name: m['name'] ?? '',
      type: m['type'] ?? 'Student',
      email: m['email'] ?? '',
      phone: m['phone'] ?? '',
      suspended: (m['status'] ?? 'active') == 'suspended',
    );
  }

  Map<String, dynamic> toMap() => {
    'memberId': memberId,
    'name': name,
    'type': type,
    'email': email,
    'phone': phone,
    'status': suspended ? 'suspended' : 'active',
    'createdAt': FieldValue.serverTimestamp(),
  };
}

// ───────────── Loan ─────────────
class Loan {
  final String id;
  final String bookId;
  final String bookTitle;
  final String memberId; // Member document id
  final String memberName;
  final DateTime issuedAt;
  final DateTime dueDate;
  final DateTime? returnedAt;

  const Loan({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.memberId,
    required this.memberName,
    required this.issuedAt,
    required this.dueDate,
    this.returnedAt,
  });

  bool get isActive => returnedAt == null;
  bool get isOverdue => isActive && dueDate.isBefore(DateTime.now());

  int get overdueDays =>
      isOverdue ? DateTime.now().difference(dueDate).inDays + 1 : 0;

  DateTime get activityTime => returnedAt ?? issuedAt;

  factory Loan.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    final issued = _date(m['issuedAt']) ?? DateTime.now();
    return Loan(
      id: d.id,
      bookId: m['bookId'] ?? '',
      bookTitle: m['bookTitle'] ?? '',
      memberId: m['memberId'] ?? '',
      memberName: m['memberName'] ?? '',
      issuedAt: issued,
      dueDate: _date(m['dueDate']) ?? issued.add(const Duration(days: 14)),
      returnedAt: _date(m['returnedAt']),
    );
  }
}

// ───────────── Library rules ─────────────
class LibrarySettings {
  final int loanDays;
  final int finePerDay;
  final int maxBooks;

  const LibrarySettings({
    this.loanDays = 14,
    this.finePerDay = 10,
    this.maxBooks = 5,
  });

  factory LibrarySettings.fromMap(Map<String, dynamic>? m) {
    if (m == null) return const LibrarySettings();
    return LibrarySettings(
      loanDays: (m['loanDays'] ?? 14) as int,
      finePerDay: (m['finePerDay'] ?? 10) as int,
      maxBooks: (m['maxBooks'] ?? 5) as int,
    );
  }
}