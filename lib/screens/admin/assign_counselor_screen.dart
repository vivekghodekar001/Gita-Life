import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/sacred_theme.dart';

const _gold = Color(0xFFD4A017);
const _navy = Color(0xFF1A1A2E);
const _cream = Color(0xFFFFF8F0);

// Provider: list of all devotees eligible for counselor promotion
final _devoteesForPromotionProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'devotee')
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => {'uid': d.id, ...d.data()})
          .toList()
        ..sort((a, b) =>
            (a['name'] as String? ?? a['fullName'] as String? ?? '')
                .compareTo(b['name'] as String? ??
                    b['fullName'] as String? ??
                    '')));
});

// ─────────────────────────────────────────────────────────────────────────────
//  AssignCounselorScreen
// ─────────────────────────────────────────────────────────────────────────────

class AssignCounselorScreen extends ConsumerStatefulWidget {
  const AssignCounselorScreen({super.key});

  @override
  ConsumerState<AssignCounselorScreen> createState() =>
      _AssignCounselorScreenState();
}

class _AssignCounselorScreenState
    extends ConsumerState<AssignCounselorScreen> {
  String? _selectedUid;
  bool _saving = false;

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first.isNotEmpty ? parts.first[0] : ''}${parts.last.isNotEmpty ? parts.last[0] : ''}'
          .toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Future<void> _assign() async {
    if (_selectedUid == null) return;
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_selectedUid)
          .update({'role': 'counselor'});
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Counselor role assigned successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final devoteesAsync = ref.watch(_devoteesForPromotionProvider);

    return Scaffold(
      backgroundColor: SacredColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0x80F0E4C3),
                        border: Border.all(
                            color: const Color(0x59B48C28), width: 1),
                      ),
                      child: Icon(Icons.chevron_left_rounded,
                          size: 20, color: SacredColors.parchment.withOpacity(0.7)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Assign Counselor Role',
                            style: GoogleFonts.cinzel(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: SacredColors.parchment.withOpacity(0.8))),
                        Text(
                          'Select a devotee to promote.\nRole changes from Devotee → Counselor.',
                          style: GoogleFonts.jost(
                              fontSize: 11,
                              color: SacredColors.parchment.withOpacity(0.45)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Devotee List ──
            Expanded(
              child: devoteesAsync.when(
                loading: () => Center(
                    child: CircularProgressIndicator(
                        color: SacredColors.parchment.withOpacity(0.4))),
                error: (e, _) => Center(
                  child: Text('Error loading devotees',
                      style: GoogleFonts.jost(
                          fontSize: 13,
                          color: SacredColors.parchment.withOpacity(0.4))),
                ),
                data: (devotees) {
                  if (devotees.isEmpty) {
                    return Center(
                      child: Text('No devotees found',
                          style: GoogleFonts.jost(
                              fontSize: 14,
                              color: SacredColors.parchment.withOpacity(0.4))),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: devotees.length,
                    itemBuilder: (context, i) {
                      final d = devotees[i];
                      final uid = d['uid'] as String;
                      final name = d['name'] as String? ??
                          d['fullName'] as String? ??
                          'Unknown';
                      final year = d['year'] as String? ?? '';
                      final counselorUid = d['counselorUid'] as String? ?? '';
                      final isSelected = uid == _selectedUid;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedUid = uid),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _gold.withOpacity(0.15)
                                : const Color(0x1AF0E8D0),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? _gold.withOpacity(0.6)
                                  : const Color(0x26B48C28),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Avatar
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF1D9E75)
                                      .withOpacity(0.2),
                                  border: Border.all(
                                      color: const Color(0xFF1D9E75)
                                          .withOpacity(0.5)),
                                ),
                                child: Center(
                                  child: Text(_initials(name),
                                      style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF1D9E75))),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(name,
                                        style: GoogleFonts.jost(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: SacredColors.parchment
                                                .withOpacity(0.85))),
                                    Text(
                                      [
                                        if (year.isNotEmpty) year,
                                        if (counselorUid.isNotEmpty)
                                          'Counselor assigned'
                                        else
                                          'No counselor'
                                      ].join(' · '),
                                      style: GoogleFonts.jost(
                                          fontSize: 11,
                                          color: SacredColors.parchment
                                              .withOpacity(0.4)),
                                    ),
                                  ],
                                ),
                              ),
                              Radio<String>(
                                value: uid,
                                groupValue: _selectedUid,
                                onChanged: (v) =>
                                    setState(() => _selectedUid = v),
                                activeColor: _gold,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // ── Bottom Buttons ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0x1AF0E8D0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0x40B48C28)),
                        ),
                        child: Center(
                          child: Text('Cancel',
                              style: GoogleFonts.jost(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: SacredColors.parchment
                                      .withOpacity(0.6))),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _selectedUid != null && !_saving
                          ? _assign
                          : null,
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: _selectedUid != null
                              ? _gold
                              : _gold.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: _saving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white))
                              : Text('Assign as Counselor',
                                  style: GoogleFonts.jost(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
