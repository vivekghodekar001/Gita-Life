import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  static bool _hasChecked = false;

  /// Call once from the dashboard's initState.
  /// Reads Firestore `app_config/version` and shows a dialog if outdated.
  static Future<void> checkForUpdate(BuildContext context) async {
    if (_hasChecked) return;
    _hasChecked = true;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('version')
          .get();

      if (!doc.exists) return;

      final data = doc.data()!;
      final latestVersion = data['latest_version'] as String? ?? '';
      final apkUrl = data['apk_url'] as String? ?? '';
      final forceUpdate = data['force_update'] as bool? ?? false;
      final releaseNotes = data['release_notes'] as String? ?? '';

      if (latestVersion.isEmpty || apkUrl.isEmpty) return;

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      if (!_isNewerVersion(latestVersion, currentVersion)) return;

      if (!context.mounted) return;

      _showUpdateDialog(
        context,
        latestVersion: latestVersion,
        apkUrl: apkUrl,
        forceUpdate: forceUpdate,
        releaseNotes: releaseNotes,
      );
    } catch (e) {
      debugPrint('Update check failed: $e');
    }
  }

  /// Compares semver strings. Returns true if [latest] > [current].
  static bool _isNewerVersion(String latest, String current) {
    final latestParts = latest.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    final currentParts = current.split('.').map((s) => int.tryParse(s) ?? 0).toList();

    for (int i = 0; i < 3; i++) {
      final l = i < latestParts.length ? latestParts[i] : 0;
      final c = i < currentParts.length ? currentParts[i] : 0;
      if (l > c) return true;
      if (l < c) return false;
    }
    return false;
  }

  static void _showUpdateDialog(
    BuildContext context, {
    required String latestVersion,
    required String apkUrl,
    required bool forceUpdate,
    required String releaseNotes,
  }) {
    showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (ctx) => PopScope(
        canPop: !forceUpdate,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFFF5EDDA),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.system_update_rounded, size: 56, color: Color(0xFF8B4513)),
                const SizedBox(height: 16),
                Text(
                  'Update Available',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF3A2010),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Version $latestVersion is available.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF3A2010).withOpacity(0.7),
                  ),
                ),
                if (releaseNotes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B6914).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      releaseNotes,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF3A2010).withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _launchUpdate(apkUrl),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B4513),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Update Now',
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                if (!forceUpdate) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      'Later',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF8B6914).withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> _launchUpdate(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
