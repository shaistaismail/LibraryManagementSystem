import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Pickers/Library_Pickers.dart';
import '../Store/LibraryStore.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const SettingsScreen({super.key, required this.onLogout});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color gold = Color(0xFFFDE68A);
  static const Color amber = Color(0xFFF59E0B);

  bool _pushNotifications = true;
  bool _dueReminders = true;
  bool _emailUpdates = false;

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
    super.dispose();
  }

  User? get _user => FirebaseAuth.instance.currentUser;
  String get _email => _user?.email ?? '';
  String get _name {
    final n = _user?.displayName;
    if (n != null && n.trim().isNotEmpty) return n;
    return _email.contains('@') ? _email.split('@').first : 'User';
  }

  String get _initials {
    final parts = _name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Future<void> _editName() async {
    final c = TextEditingController(text: _name);
    final res = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F1B33),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Name',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: TextField(
          controller: c,
          autofocus: true,
          cursorColor: gold,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Your name',
            hintStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, c.text.trim()),
            child: const Text('Save', style: TextStyle(color: gold)),
          ),
        ],
      ),
    );
    if (res == null || res.isEmpty) return;
    try {
      await _user?.updateDisplayName(res);
      await _user?.reload();
      if (mounted) {
        setState(() {});
        showMsg(context, 'Name update ho gaya');
      }
    } catch (e) {
      if (mounted) showMsg(context, friendlyError(e), error: true);
    }
  }

  Future<void> _resetPassword() async {
    if (_email.isEmpty) return;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
      if (mounted) showMsg(context, 'Password reset email $_email par bhej di gayi');
    } catch (e) {
      if (mounted) showMsg(context, friendlyError(e), error: true);
    }
  }

  Future<void> _editNumber(
      String title,
      int current,
      Future<void> Function(int) save,
      ) async {
    final c = TextEditingController(text: '$current');
    final res = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F1B33),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800)),
        content: TextField(
          controller: c,
          autofocus: true,
          keyboardType: TextInputType.number,
          cursorColor: gold,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, int.tryParse(c.text.trim())),
            child: const Text('Save', style: TextStyle(color: gold)),
          ),
        ],
      ),
    );
    if (res == null || res < 0) return;
    try {
      await save(res);
      if (mounted) showMsg(context, '$title update ho gaya');
    } catch (e) {
      if (mounted) showMsg(context, friendlyError(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage your account and preferences',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13.5,
              ),
            ),
            const SizedBox(height: 20),
            _buildProfileCard(),
            const SizedBox(height: 24),

            _sectionTitle('Account'),
            _group([
              _tile(
                icon: Icons.person_outline_rounded,
                title: 'Edit Profile',
                subtitle: 'Change your display name',
                onTap: _editName,
              ),
              _tile(
                icon: Icons.lock_outline_rounded,
                title: 'Change Password',
                subtitle: 'Send reset link to your email',
                onTap: _resetPassword,
              ),
            ]),
            const SizedBox(height: 22),

            _sectionTitle('Library Rules'),
            _group([
              _tile(
                icon: Icons.event_available_rounded,
                title: 'Loan Period',
                trailingText: '${_store.settings.loanDays} days',
                onTap: () => _editNumber('Loan Period (days)',
                    _store.settings.loanDays,
                        (v) => _store.updateSettings(loanDays: v)),
              ),
              _tile(
                icon: Icons.payments_outlined,
                title: 'Fine per Day',
                trailingText: 'Rs. ${_store.settings.finePerDay}',
                onTap: () => _editNumber('Fine per Day (Rs.)',
                    _store.settings.finePerDay,
                        (v) => _store.updateSettings(finePerDay: v)),
              ),
              _tile(
                icon: Icons.menu_book_rounded,
                title: 'Max Books per Member',
                trailingText: '${_store.settings.maxBooks}',
                onTap: () => _editNumber('Max Books per Member',
                    _store.settings.maxBooks,
                        (v) => _store.updateSettings(maxBooks: v)),
              ),
            ]),
            const SizedBox(height: 22),

            _sectionTitle('Notifications'),
            _group([
              _switchTile(
                icon: Icons.notifications_none_rounded,
                title: 'Push Notifications',
                value: _pushNotifications,
                onChanged: (v) => setState(() => _pushNotifications = v),
              ),
              _switchTile(
                icon: Icons.alarm_rounded,
                title: 'Due Date Reminders',
                value: _dueReminders,
                onChanged: (v) => setState(() => _dueReminders = v),
              ),
              _switchTile(
                icon: Icons.mail_outline_rounded,
                title: 'Email Updates',
                value: _emailUpdates,
                onChanged: (v) => setState(() => _emailUpdates = v),
              ),
            ]),
            const SizedBox(height: 22),

            _sectionTitle('About'),
            _group([
              _tile(
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
                onTap: () {},
              ),
              _tile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () {},
              ),
              _tile(
                icon: Icons.info_outline_rounded,
                title: 'App Version',
                trailingText: '1.0.0',
              ),
            ]),
            const SizedBox(height: 26),

            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  // ───────────── Profile card ─────────────
  Widget _buildProfileCard() {
    return _GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [gold, amber],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: amber.withOpacity(0.4),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              _initials,
              style: TextStyle(
                color: Color(0xFF1E1B0B),
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: gold.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Librarian',
                    style: TextStyle(
                      color: gold,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.edit_rounded, color: Colors.white.withOpacity(0.7)),
        ],
      ),
    );
  }

  // ───────────── Section helpers ─────────────
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: gold.withOpacity(0.9),
          fontSize: 12.5,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _group(List<Widget> children) {
    final items = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i != children.length - 1) {
        items.add(Divider(
          height: 1,
          thickness: 1,
          indent: 66,
          color: Colors.white.withOpacity(0.08),
        ));
      }
    }
    return _GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(children: items),
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: 21),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailingText,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            _iconBox(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.white.withOpacity(0.5)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          _iconBox(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF1E1B0B),
            activeTrackColor: gold,
            inactiveThumbColor: Colors.white70,
            inactiveTrackColor: Colors.white.withOpacity(0.15),
          ),
        ],
      ),
    );
  }

  // ───────────── Logout ─────────────
  Widget _buildLogoutButton() {
    const red = Color(0xFFFCA5A5);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: _confirmLogout,
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: red.withOpacity(0.14),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: red.withOpacity(0.35)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.logout_rounded, color: red, size: 22),
            SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(
                color: red,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F1B33),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        title: const Text(
          'Logout?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Are you sure you want to logout from your account?',
          style: TextStyle(color: Colors.white.withOpacity(0.75)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onLogout();
            },
            child: const Text('Logout',
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