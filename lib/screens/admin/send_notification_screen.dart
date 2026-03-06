import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/notification_service.dart';
import '../../providers/auth_provider.dart';
import '../../app/sacred_theme.dart';
import '../../widgets/sacred_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final notificationServiceProvider = Provider((ref) => NotificationService());

class SendNotificationScreen extends ConsumerStatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  ConsumerState<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends ConsumerState<SendNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isSending = false;

  Future<void> _sendNotification() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSending = true);
      try {
        final adminProfile = ref.read(userProfileProvider).value;
        if (adminProfile == null) throw Exception("Unauthorized");

        await ref.read(notificationServiceProvider).sendToAll(
          _titleController.text.trim(),
          _bodyController.text.trim(),
          adminProfile.uid,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Notification scheduled!'), backgroundColor: SacredColors.surface));
          _titleController.clear();
          _bodyController.clear();
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: SacredColors.surface));
      }
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyStream = ref.watch(notificationServiceProvider).getNotificationHistory();

    return Scaffold(
      backgroundColor: SacredColors.ink,
      body: SacredBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Top Bar ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back_ios_new, size: 16, color: SacredColors.parchment.withOpacity(0.4)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Text('Broadcast Notification', style: SacredTextStyles.sectionLabel())),
                  ],
                ),
              ),
              // ── Form + History ──
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _titleController,
                              style: GoogleFonts.jost(fontSize: 14, fontWeight: FontWeight.w300, color: SacredColors.parchmentLight.withOpacity(0.7)),
                              decoration: _sacredInput('Title', Icons.title),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _bodyController,
                              maxLines: 3,
                              style: GoogleFonts.jost(fontSize: 14, fontWeight: FontWeight.w300, color: SacredColors.parchmentLight.withOpacity(0.7)),
                              decoration: _sacredInput('Message Body', Icons.message_outlined),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 18),
                            GestureDetector(
                              onTap: _isSending ? null : _sendNotification,
                              child: Container(
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: SacredColors.parchment.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: SacredColors.parchment.withOpacity(0.15)),
                                ),
                                child: _isSending
                                    ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: SacredColors.parchment.withOpacity(0.4), strokeWidth: 1.5))
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.send, size: 15, color: SacredColors.parchment.withOpacity(0.4)),
                                          const SizedBox(width: 8),
                                          Text('SEND TO ALL STUDENTS', style: GoogleFonts.jost(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 1.2, color: SacredColors.parchmentLight.withOpacity(0.6))),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SacredDivider(),
                      const SizedBox(height: 10),
                      Text('NOTIFICATION HISTORY', style: GoogleFonts.jost(fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 1.5, color: SacredColors.parchment.withOpacity(0.3))),
                      const SizedBox(height: 10),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: historyStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator(color: SacredColors.parchment.withOpacity(0.2), strokeWidth: 1.5));
                            }
                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return Center(child: Text('No history yet.', style: GoogleFonts.jost(fontSize: 12, fontWeight: FontWeight.w300, color: SacredColors.parchment.withOpacity(0.25))));
                            }

                            return ListView.builder(
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (_, i) {
                                final data = snapshot.data!.docs[i].data() as Map<String, dynamic>;
                                final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: SacredDecorations.glassCard(),
                                  child: Row(
                                    children: [
                                      Icon(Icons.notifications_none, size: 16, color: SacredColors.parchment.withOpacity(0.25)),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(data['title'] ?? '', style: GoogleFonts.cormorantGaramond(fontSize: 14, fontWeight: FontWeight.w600, color: SacredColors.parchmentLight.withOpacity(0.65))),
                                            const SizedBox(height: 2),
                                            Text(data['body'] ?? '', style: GoogleFonts.jost(fontSize: 11, fontWeight: FontWeight.w300, color: SacredColors.parchment.withOpacity(0.35)), maxLines: 2, overflow: TextOverflow.ellipsis),
                                          ],
                                        ),
                                      ),
                                      if (createdAt != null)
                                        Text(DateFormat.yMMMd().format(createdAt), style: GoogleFonts.jost(fontSize: 9, fontWeight: FontWeight.w300, color: SacredColors.parchment.withOpacity(0.2))),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _sacredInput(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.jost(fontSize: 12, color: SacredColors.parchment.withOpacity(0.35)),
      prefixIcon: Icon(icon, color: SacredColors.parchment.withOpacity(0.3), size: 18),
      filled: true,
      fillColor: SacredColors.parchment.withOpacity(0.04),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: SacredColors.parchment.withOpacity(0.08))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: SacredColors.parchment.withOpacity(0.08))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: SacredColors.parchment.withOpacity(0.2))),
    );
  }
}
