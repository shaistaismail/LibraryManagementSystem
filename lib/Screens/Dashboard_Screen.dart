import 'dart:ui';
import 'package:flutter/material.dart';
import '../Pickers/Library_Pickers.dart';
import '../Store/LibraryStore.dart';
import 'Addbook_Screen.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const Color gold = Color(0xFFFDE68A);
  static const Color amber = Color(0xFFF59E0B);

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 22),
                _buildStats(),
                const SizedBox(height: 26),
                _sectionTitle('Quick Actions'),
                const SizedBox(height: 12),
                _buildQuickActions(),
                const SizedBox(height: 26),
                _sectionTitle('Recent Activity', action: 'See all'),
                const SizedBox(height: 12),
                ..._buildActivity(),
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
              Text(
                'WellCome all coming in Library👋',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Admin Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        _GlassCard(
          padding: const EdgeInsets.all(10),
          radius: 14,
          child: Stack(
            children: [
              const Icon(Icons.notifications_none_rounded,
                  color: Colors.white, size: 26),
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: amber,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ───────────── Stats (live from Firestore) ─────────────
  Widget _buildStats() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.3,
      children: [
        _StatCard(
          icon: Icons.library_books_rounded,
          value: '${_store.totalCopies}',
          label: 'Total Books',
        ),
        _StatCard(
          icon: Icons.swap_horiz_rounded,
          value: '${_store.activeLoans.length}',
          label: 'Issued',
        ),
        _StatCard(
          icon: Icons.groups_rounded,
          value: '${_store.members.length}',
          label: 'Members',
        ),
        _StatCard(
          icon: Icons.alarm_rounded,
          value: '${_store.overdueLoans.length}',
          label: 'Overdue',
          highlight: true,
        ),
      ],
    );
  }

  // ───────────── Recent activity (live) ─────────────
  List<Widget> _buildActivity() {
    if (_store.error != null) {
      return [
        Text(
          _store.error!.contains('permission-denied')
              ? 'Firestore permission denied. Rules check karein.'
              : 'Data load nahi hua: ${_store.error}',
          style: const TextStyle(color: Color(0xFFFCA5A5)),
        ),
      ];
    }
    if (_store.loading) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator(color: gold)),
        ),
      ];
    }
    final recent = _store.loans.take(4).toList();
    if (recent.isEmpty) {
      return [
        Text(
          'Abhi koi activity nahi. Book add karein aur issue karke dekhein.',
          style: TextStyle(color: Colors.white.withOpacity(0.65)),
        ),
      ];
    }
    return recent.map((l) {
      if (l.returnedAt != null) {
        return _activityTile(
          icon: Icons.book_rounded,
          title: l.bookTitle,
          subtitle: 'Returned by ${l.memberName}',
          status: 'Returned',
          color: const Color(0xFFFCD34D),
        );
      }
      if (l.isOverdue) {
        return _activityTile(
          icon: Icons.auto_stories_rounded,
          title: l.bookTitle,
          subtitle: 'Overdue · ${l.memberName}',
          status: 'Overdue',
          color: const Color(0xFFFCA5A5),
        );
      }
      return _activityTile(
        icon: Icons.menu_book_rounded,
        title: l.bookTitle,
        subtitle: 'Issued to ${l.memberName}',
        status: 'Issued',
        color: const Color(0xFF6EE7B7),
      );
    }).toList();
  }

  // ───────────── Quick actions ─────────────
  Widget _buildQuickActions() {
    return Row(
      children: [
        _actionButton(
          Icons.add_rounded,
          'Add Book',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddBookScreen()),
          ),
        ),
        const SizedBox(width: 12),
        _actionButton(
          Icons.north_east_rounded,
          'Issue',
          onTap: () => issueFlow(context),
        ),
        const SizedBox(width: 12),
        _actionButton(
          Icons.south_west_rounded,
          'Return',
          onTap: () => returnFlow(context),
        ),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label, {VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap ?? () {},
        child: _GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [gold, amber]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF1E1B0B), size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────── Section title ─────────────
  Widget _sectionTitle(String title, {String? action}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (action != null)
          Text(
            action,
            style: const TextStyle(
              color: gold,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  // ───────────── Activity tile ─────────────
  Widget _activityTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _GlassCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withOpacity(0.18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: color,
                  fontSize: 11.5,
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

// ───────────── Reusable widgets ─────────────

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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool highlight;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent =
    highlight ? const Color(0xFFFDE68A) : Colors.white;

    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: accent.withOpacity(0.9), size: 26),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: accent,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}