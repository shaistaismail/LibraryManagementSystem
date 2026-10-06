import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Store/LibraryStore.dart';
import '../widgets/background.dart';
import 'Catalogscreen.dart';
import 'Setting_Screen.dart';

import 'dashboard_screen.dart';

import 'members_screen.dart';
import 'login_screen.dart';

/// Login ke baad yehi screen khulti hai.
/// Background aur bottom navigation bar sirf yahan ek baar hain,
/// aur bar ke icons se tabs (pages) badalte hain.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const Color gold = Color(0xFFFDE68A);

  int _index = 0;

  @override
  void initState() {
    super.initState();
    LibraryStore.instance.start(); // Firestore live data shuru
  }

  static const _icons = [
    Icons.home_rounded,
    Icons.library_books_rounded,
    Icons.groups_rounded,
    Icons.settings_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Background(
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: IndexedStack(
                  index: _index,
                  children: [
                    const DashboardScreen(),
                    const CatalogScreen(),
                    const MembersScreen(),
                    SettingsScreen(onLogout: _logout),
                  ],
                ),
              ),
              Positioned(
                left: 8,
                right: 8,
                bottom: 12,
                child: _buildBottomNav(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await LibraryStore.instance.stop();
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) =>  LoginScreen()),
          (route) => false,
    );
  }

  Widget _buildBottomNav() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1220).withOpacity(0.75),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_icons.length, (i) {
              final selected = i == _index;
              return GestureDetector(
                onTap: () => setState(() => _index = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? gold : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    _icons[i],
                    size: 24,
                    color: selected
                        ? const Color(0xFF1E1B0B)
                        : Colors.white.withOpacity(0.7),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}