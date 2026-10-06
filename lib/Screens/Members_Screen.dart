
import 'dart:ui';
import 'package:flutter/material.dart';
import '../Pickers/Library_Pickers.dart';
import '../Store/LibraryStore.dart';
import '../models/books_model.dart';


// ───────────── Dummy data model (baad mein apne data se replace karein) ─────────────

enum MemberStatus { active, overdue, suspended }

class _Member {
final String docId; // Firestore document id
final String name;
final String id;
final String type;
final String email;
final String phone;
final int issued;
final MemberStatus status;
final List<Color> colors;

const _Member({
required this.docId,
required this.name,
required this.id,
required this.type,
required this.email,
required this.phone,
required this.issued,
required this.status,
required this.colors,
});

String get initials {
final parts = name.trim().split(' ');
if (parts.length == 1) return parts.first[0].toUpperCase();
return (parts.first[0] + parts.last[0]).toUpperCase();
}
}

// ───────────── Screen ─────────────

class MembersScreen extends StatefulWidget {
const MembersScreen({super.key});

@override
State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
static const Color gold = Color(0xFFFDE68A);
static const Color amber = Color(0xFFF59E0B);

final TextEditingController _search = TextEditingController();
final List<String> _filters = ['All', 'Active', 'Overdue', 'Suspended'];

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

// Firestore ke members + loans se UI wale members banata hai
List<_Member> get _all {
return _store.members.map((m) {
final loans = _store.activeLoansOfMember(m.id);
final overdue = loans.any((l) => l.isOverdue);
return _Member(
docId: m.id,
name: m.name,
id: m.memberId,
type: m.type,
email: m.email.isEmpty ? '—' : m.email,
phone: m.phone.isEmpty ? '—' : m.phone,
issued: loans.length,
status: m.suspended
? MemberStatus.suspended
    : (overdue ? MemberStatus.overdue : MemberStatus.active),
colors: m.colors,
);
}).toList();
}

List<_Member> get _filtered {
return _all.where((m) {
final matchFilter = _selected == 'All' ||
(_selected == 'Active' && m.status == MemberStatus.active) ||
(_selected == 'Overdue' && m.status == MemberStatus.overdue) ||
(_selected == 'Suspended' && m.status == MemberStatus.suspended);
final q = _query.trim().toLowerCase();
final matchSearch = q.isEmpty ||
m.name.toLowerCase().contains(q) ||
m.id.toLowerCase().contains(q);
return matchFilter && matchSearch;
}).toList();
}

int _count(MemberStatus s) => _all.where((m) => m.status == s).length;

@override
Widget build(BuildContext context) {
final list = _filtered;

return SafeArea(
child:  Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Padding(
padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
child: _buildHeader(),
),
const SizedBox(height: 16),
Padding(
padding: const EdgeInsets.symmetric(horizontal: 20),
child: _buildSummary(),
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
child: list.isEmpty
? (_store.loading
? const Center(
child: CircularProgressIndicator(color: gold))
    : _buildEmpty())
    : ListView.separated(
padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
itemCount: list.length,
separatorBuilder: (_, __) => const SizedBox(height: 12),
itemBuilder: (context, i) => _MemberTile(
member: list[i],
onTap: () => _showDetails(list[i]),
),
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
const Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'Members',
style: TextStyle(
color: Colors.white,
fontSize: 26,
fontWeight: FontWeight.w800,
),
),
SizedBox(height: 4),
Text(
'Manage library members',
style: TextStyle(color: Colors.white70, fontSize: 13.5),
),
],
),
),
InkWell(
borderRadius: BorderRadius.circular(14),
onTap: _showAddMember,
child: Ink(
padding: const EdgeInsets.all(11),
decoration: BoxDecoration(
gradient: const LinearGradient(colors: [gold, amber]),
borderRadius: BorderRadius.circular(14),
),
child: const Icon(Icons.person_add_alt_1_rounded,
color: Color(0xFF1E1B0B), size: 24),
),
),
],
);
}

// ───────────── Summary ─────────────
Widget _buildSummary() {
Widget item(String value, String label, Color color) {
return Expanded(
child: _GlassCard(
padding: const EdgeInsets.symmetric(vertical: 14),
child: Column(
children: [
Text(
value,
style: TextStyle(
color: color,
fontSize: 22,
fontWeight: FontWeight.w800,
),
),
const SizedBox(height: 2),
Text(
label,
style: TextStyle(
color: Colors.white.withOpacity(0.7),
fontSize: 12,
),
),
],
),
),
);
}

return Row(
children: [
item('${_all.length}', 'Total', Colors.white),
const SizedBox(width: 10),
item('${_count(MemberStatus.active)}', 'Active',
const Color(0xFF6EE7B7)),
const SizedBox(width: 10),
item('${_count(MemberStatus.overdue)}', 'Overdue',
const Color(0xFFFCD34D)),
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
hintText: 'Search name or member ID…',
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

// ───────────── Filter chips ─────────────
Widget _buildChips() {
return SizedBox(
height: 38,
child: ListView.separated(
scrollDirection: Axis.horizontal,
padding: const EdgeInsets.symmetric(horizontal: 20),
itemCount: _filters.length,
separatorBuilder: (_, __) => const SizedBox(width: 8),
itemBuilder: (context, i) {
final f = _filters[i];
final selected = f == _selected;
return GestureDetector(
onTap: () => setState(() => _selected = f),
child: AnimatedContainer(
duration: const Duration(milliseconds: 220),
padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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
child: Center(
child: Text(
f,
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
Icon(Icons.person_search_rounded,
size: 64, color: Colors.white.withOpacity(0.4)),
const SizedBox(height: 12),
const Text(
'No members found',
style: TextStyle(
color: Colors.white,
fontSize: 17,
fontWeight: FontWeight.w700,
),
),
const SizedBox(height: 4),
Text(
'Try a different name or filter',
style: TextStyle(color: Colors.white.withOpacity(0.65)),
),
],
),
);
}

// ───────────── Confirm dialog ─────────────
Future<bool> _confirm(String title, String body) async {
final res = await showDialog<bool>(
context: context,
builder: (ctx) => AlertDialog(
backgroundColor: const Color(0xFF0F1B33),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(20),
side: BorderSide(color: Colors.white.withOpacity(0.12)),
),
title: Text(title,
style: const TextStyle(
color: Colors.white, fontWeight: FontWeight.w800)),
content:
Text(body, style: TextStyle(color: Colors.white.withOpacity(0.75))),
actions: [
TextButton(
onPressed: () => Navigator.pop(ctx, false),
child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
),
TextButton(
onPressed: () => Navigator.pop(ctx, true),
child: const Text('Confirm',
style: TextStyle(color: Color(0xFFFCA5A5))),
),
],
),
);
return res ?? false;
}

// ───────────── Add member sheet ─────────────
void _showAddMember() {
final name = TextEditingController();
final email = TextEditingController();
final phone = TextEditingController();
String type = 'Student';
bool saving = false;

Widget field(TextEditingController c, String hint, IconData icon,
{TextInputType? keyboard}) {
return Padding(
padding: const EdgeInsets.only(bottom: 12),
child: TextField(
controller: c,
keyboardType: keyboard,
cursorColor: gold,
style: const TextStyle(color: Colors.white),
decoration: InputDecoration(
hintText: hint,
hintStyle: const TextStyle(color: Colors.white54),
prefixIcon: Icon(icon, color: Colors.white70),
filled: true,
fillColor: Colors.white.withOpacity(0.08),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
borderSide: BorderSide.none,
),
),
),
);
}

showModalBottomSheet(
context: context,
isScrollControlled: true,
backgroundColor: const Color(0xFF0F1B33),
shape: const RoundedRectangleBorder(
borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
),
builder: (ctx) => StatefulBuilder(
builder: (ctx, setSheet) => Padding(
padding: EdgeInsets.fromLTRB(
24, 16, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
child: SingleChildScrollView(
child: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'Add New Member',
style: TextStyle(
color: Colors.white,
fontSize: 20,
fontWeight: FontWeight.w800,
),
),
const SizedBox(height: 16),
field(name, 'Full name *', Icons.person_outline_rounded),
field(email, 'Email', Icons.mail_outline_rounded,
keyboard: TextInputType.emailAddress),
field(phone, 'Phone', Icons.phone_outlined,
keyboard: TextInputType.phone),
Wrap(
spacing: 8,
children: ['Student', 'Teacher', 'Staff'].map((t) {
final sel = t == type;
return GestureDetector(
onTap: () => setSheet(() => type = t),
child: Container(
padding: const EdgeInsets.symmetric(
horizontal: 18, vertical: 9),
decoration: BoxDecoration(
gradient: sel
? const LinearGradient(colors: [gold, amber])
    : null,
color: sel ? null : Colors.white.withOpacity(0.12),
borderRadius: BorderRadius.circular(20),
),
child: Text(
t,
style: TextStyle(
color: sel ? const Color(0xFF1E1B0B) : Colors.white,
fontWeight: FontWeight.w700,
),
),
),
);
}).toList(),
),
const SizedBox(height: 20),
SizedBox(
width: double.infinity,
child: ElevatedButton(
onPressed: saving
? null
    : () async {
if (name.text.trim().isEmpty) {
showMsg(context, 'Member ka naam likhein',
error: true);
return;
}
setSheet(() => saving = true);
try {
await _store.addMember(Member(
memberId: _store.nextMemberId(),
name: name.text.trim(),
type: type,
email: email.text.trim(),
phone: phone.text.trim(),
));
if (ctx.mounted) Navigator.pop(ctx);
if (mounted) {
showMsg(context,
'${name.text.trim()} add ho gaya');
}
} catch (e) {
setSheet(() => saving = false);
if (mounted) {
showMsg(context, friendlyError(e), error: true);
}
}
},
style: ElevatedButton.styleFrom(
backgroundColor: gold,
foregroundColor: const Color(0xFF1E1B0B),
padding: const EdgeInsets.symmetric(vertical: 15),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14)),
),
child: Text(
saving ? 'Saving…' : 'Add Member',
style: const TextStyle(
fontWeight: FontWeight.w800, fontSize: 15.5),
),
),
),
],
),
),
),
),
);
}

// ───────────── Member details bottom sheet ─────────────
void _showDetails(_Member m) {
final (label, color) = _statusInfo(m.status);

Widget infoRow(IconData icon, String text) {
return Padding(
padding: const EdgeInsets.only(bottom: 12),
child: Row(
children: [
Icon(icon, color: Colors.white70, size: 20),
const SizedBox(width: 12),
Expanded(
child: Text(
text,
style: const TextStyle(color: Colors.white, fontSize: 14.5),
),
),
],
),
);
}

showModalBottomSheet(
context: context,
backgroundColor: const Color(0xFF0F1B33),
shape: const RoundedRectangleBorder(
borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
),
builder: (ctx) => SafeArea(
child: SingleChildScrollView(
padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Container(
width: 44,
height: 4,
decoration: BoxDecoration(
color: Colors.white24,
borderRadius: BorderRadius.circular(4),
),
),
const SizedBox(height: 20),
_Avatar(member: m, size: 72),
const SizedBox(height: 12),
Text(
m.name,
style: const TextStyle(
color: Colors.white,
fontSize: 21,
fontWeight: FontWeight.w800,
),
),
const SizedBox(height: 4),
Text(
'${m.id} · ${m.type}',
style: TextStyle(color: Colors.white.withOpacity(0.7)),
),
const SizedBox(height: 10),
_StatusPill(label: label, color: color),
const SizedBox(height: 22),
infoRow(Icons.mail_outline_rounded, m.email),
infoRow(Icons.phone_outlined, m.phone),
infoRow(Icons.menu_book_rounded, '${m.issued} books currently issued'),
const SizedBox(height: 10),
Row(
children: [
Expanded(
child: OutlinedButton.icon(
onPressed: () async {
Navigator.pop(ctx);
final suspend = m.status != MemberStatus.suspended;
try {
await _store.setSuspended(m.docId, suspend);
if (mounted) {
showMsg(context,
'${m.name} ${suspend ? 'suspend' : 'activate'} ho gaya');
}
} catch (e) {
if (mounted) showMsg(context, friendlyError(e), error: true);
}
},
icon: Icon(
m.status == MemberStatus.suspended
? Icons.check_circle_outline_rounded
    : Icons.block_rounded,
size: 20,
),
label: Text(m.status == MemberStatus.suspended
? 'Activate'
    : 'Suspend'),
style: OutlinedButton.styleFrom(
foregroundColor: Colors.white,
side: const BorderSide(color: Colors.white30),
padding: const EdgeInsets.symmetric(vertical: 14),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14)),
),
),
),
const SizedBox(width: 12),
Expanded(
child: ElevatedButton.icon(
onPressed: () async {
Navigator.pop(ctx);
final ok = await _confirm(
'Delete member?', '${m.name} ko hamesha ke liye hata diya jayega.');
if (!ok) return;
try {
await _store.deleteMember(m.docId);
if (mounted) showMsg(context, '${m.name} delete ho gaya');
} catch (e) {
if (mounted) showMsg(context, friendlyError(e), error: true);
}
},
icon: const Icon(Icons.delete_outline_rounded, size: 20),
label: const Text('Delete'),
style: ElevatedButton.styleFrom(
backgroundColor: const Color(0xFFFCA5A5),
foregroundColor: const Color(0xFF450A0A),
padding: const EdgeInsets.symmetric(vertical: 14),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14)),
),
),
),
],
),
],
),
),
));
}
}

// ───────────── Helpers ─────────────

(String, Color) _statusInfo(MemberStatus s) {
switch (s) {
case MemberStatus.active:
return ('Active', const Color(0xFF6EE7B7));
case MemberStatus.overdue:
return ('Overdue', const Color(0xFFFCD34D));
case MemberStatus.suspended:
return ('Suspended', const Color(0xFFFCA5A5));
}
}

class _Avatar extends StatelessWidget {
final _Member member;
final double size;
const _Avatar({required this.member, this.size = 50});

@override
Widget build(BuildContext context) {
return Container(
width: size,
height: size,
decoration: BoxDecoration(
gradient: LinearGradient(
colors: member.colors,
begin: Alignment.topLeft,
end: Alignment.bottomRight,
),
borderRadius: BorderRadius.circular(size * 0.32),
boxShadow: [
BoxShadow(
color: member.colors.first.withOpacity(0.4),
blurRadius: 12,
offset: const Offset(0, 5),
),
],
),
alignment: Alignment.center,
child: Text(
member.initials,
style: TextStyle(
color: Colors.white,
fontSize: size * 0.36,
fontWeight: FontWeight.w800,
),
),
);
}
}

class _StatusPill extends StatelessWidget {
final String label;
final Color color;
const _StatusPill({required this.label, required this.color});

@override
Widget build(BuildContext context) {
return Container(
padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
decoration: BoxDecoration(
color: color.withOpacity(0.18),
borderRadius: BorderRadius.circular(20),
),
child: Text(
label,
style: TextStyle(
color: color,
fontSize: 12,
fontWeight: FontWeight.w700,
),
),
);
}
}

class _MemberTile extends StatelessWidget {
final _Member member;
final VoidCallback onTap;
const _MemberTile({required this.member, required this.onTap});

@override
Widget build(BuildContext context) {
final (label, color) = _statusInfo(member.status);

return InkWell(
borderRadius: BorderRadius.circular(18),
onTap: onTap,
child: _GlassCard(
padding: const EdgeInsets.all(12),
child: Row(
children: [
_Avatar(member: member),
const SizedBox(width: 12),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
member.name,
maxLines: 1,
overflow: TextOverflow.ellipsis,
style: const TextStyle(
color: Colors.white,
fontSize: 15,
fontWeight: FontWeight.w700,
),
),
const SizedBox(height: 3),
Text(
'${member.id} · ${member.type}',
maxLines: 1,
overflow: TextOverflow.ellipsis,
style: TextStyle(
color: Colors.white.withOpacity(0.65),
fontSize: 12.5,
),
),
const SizedBox(height: 6),
Row(
children: [
Icon(Icons.menu_book_rounded,
size: 14, color: Colors.white.withOpacity(0.6)),
const SizedBox(width: 4),
Text(
'${member.issued} issued',
style: TextStyle(
color: Colors.white.withOpacity(0.7),
fontSize: 12,
),
),
],
),
],
),
),
const SizedBox(width: 8),
// Flexible + FittedBox prevents horizontal overflow on
// small/narrow screens when the status text is long.
Flexible(
child: FittedBox(
fit: BoxFit.scaleDown,
alignment: Alignment.centerRight,
child: _StatusPill(label: label, color: color),
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
