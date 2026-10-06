import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/background.dart';
import 'Home_Screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color gold = Color(0xFFFDE68A);
  static const Color amber = Color(0xFFF59E0B);

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _obscure = true;
  int _mode = 0; // 0 = Sign In, 1 = Create Account
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _msg(String text, {bool error = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
        error ? const Color(0xFFB91C1C) : const Color(0xFF0F766E),
        content: Text(text),
      ),
    );
  }

  String _errorText(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Email sahi nahi hai';
      case 'user-not-found':
        return 'Is email ka account nahi mila';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ya password ghalat hai';
      case 'email-already-in-use':
        return 'Ye email pehle se registered hai';
      case 'weak-password':
        return 'Password kam az kam 6 characters ka rakhein';
      case 'network-request-failed':
        return 'Internet connection check karein';
      case 'too-many-requests':
        return 'Bohat zyada koshishein, baad mein try karein';
      default:
        return e.message ?? 'Kuch ghalat ho gaya';
    }
  }

  Future<void> _signIn() async {
    final email = _email.text.trim();
    final pass = _password.text;

    if (email.isEmpty || pass.isEmpty) {
      _msg('Email aur password likhein');
      return;
    }

    setState(() => _loading = true);
    try {
      if (_mode == 0) {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: pass);
      } else {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: pass);
      }
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } on FirebaseAuthException catch (e) {
      _msg(_errorText(e));
    } catch (_) {
      _msg('Kuch ghalat ho gaya, dobara try karein');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _email.text.trim();
    if (email.isEmpty) {
      _msg('Pehle apna email likhein');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _msg('Password reset email bhej di gayi hai', error: false);
    } on FirebaseAuthException catch (e) {
      _msg(_errorText(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Background(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 18),
                    Text(
                      _mode == 0 ? 'Welcome Back' : 'Create Account',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _mode == 0
                          ? 'Sign in to your library account'
                          : 'Register to manage your library',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('Select Mode for Account creation',style: GoogleFonts.poppins(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildRoleSelector(),
                    const SizedBox(height: 18),
                    _field(
                      controller: _email,
                      hint: 'Email address',
                      icon: Icons.mail_outline_rounded,
                      keyboard: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                    _field(
                      controller: _password,
                      hint: 'Password',
                      icon: Icons.lock_outline_rounded,
                      obscure: _obscure,
                      suffix: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: Colors.white70,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_mode == 0)
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: _forgotPassword,
                          child: Text(
                            'Forgot password?',
                            style: TextStyle(
                              color: gold.withOpacity(0.95),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 22),
                    _buildSignInButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ───────────── Logo ─────────────
  Widget _buildLogo() {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [gold, amber],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: amber.withOpacity(0.45),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(Icons.menu_book_rounded,
          size: 40, color: Color(0xFF1E1B0B)),
    );
  }

  // ───────────── Mode selector ─────────────
  Widget _buildRoleSelector() {
    Widget item(int i, IconData icon, String label) {
      final selected = _mode == i;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _mode = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient:
              selected ? const LinearGradient(colors: [gold, amber]) : null,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: selected ? const Color(0xFF1E1B0B) : Colors.white70,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? const Color(0xFF1E1B0B) : Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _GlassCard(
      padding: const EdgeInsets.all(5),
      radius: 18,
      child: Row(
        children: [
          item(0, Icons.login_rounded, 'Sign In'),
          item(1, Icons.person_add_alt_1_rounded, 'Sign Up'),
        ],
      ),
    );
  }

  // ───────────── Text field ─────────────
  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboard,
  }) {
    return _GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      radius: 16,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        cursorColor: gold,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.55)),
          icon: Icon(icon, color: Colors.white.withOpacity(0.75)),
          suffixIcon: suffix,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  // ───────────── Sign in button ─────────────

// ───────────── Sign in button ─────────────
  Widget _buildSignInButton() {
    return InkWell(
      onTap: _loading ? null : _signIn,
      child: Ink(
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF59E0B),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: _loading
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.6,
              color: Color(0xFF1E1B0B),
            ),
          )
              : Text(
            _mode == 0 ? 'Sign In' : 'Create Account',
            style: const TextStyle(
              color: Color(0xFF1E1B0B),
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
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
          width: double.infinity,
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