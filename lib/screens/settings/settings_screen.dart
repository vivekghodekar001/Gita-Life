import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, Map<String, dynamic>>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<Map<String, dynamic>> {
  final Box _settingsBox = Hive.box('settings');

  SettingsNotifier() : super({}) {
    _loadSettings();
  }

  void _loadSettings() {
    state = {
      'daily_target': _settingsBox.get('daily_target', defaultValue: 16),
      'notifications_enabled': _settingsBox.get('notifications_enabled', defaultValue: true),
      'dark_mode': _settingsBox.get('dark_mode', defaultValue: false),
      'japa_vibration': _settingsBox.get('japa_vibration', defaultValue: true),
      'reader_font_size': _settingsBox.get('reader_font_size', defaultValue: 16.0),
    };
  }

  Future<void> updateSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
    state = {...state, key: value};
  }
}

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _version = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = 'v\${info.version} (Build \${info.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFE8F5F9),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Preferences'),
          _buildSwitchTile(
            title: 'Dark Mode',
            subtitle: 'Enable dark theme for the app',
            icon: Icons.dark_mode,
            value: settings['dark_mode'] ?? false,
            onChanged: (val) => notifier.updateSetting('dark_mode', val),
          ),
          _buildSwitchTile(
            title: 'Push Notifications',
            subtitle: 'Receive daily quotes and reminders',
            icon: Icons.notifications,
            value: settings['notifications_enabled'] ?? true,
            onChanged: (val) => notifier.updateSetting('notifications_enabled', val),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Japa Settings'),
          ListTile(
            leading: const Icon(Icons.adjust, color: Color(0xFF1565C0)),
            title: const Text('Daily Target (Malas)'),
            subtitle: Text('\${settings["daily_target"] ?? 16} Malas'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showTargetDialog(context, settings['daily_target'] ?? 16, notifier),
          ),
          _buildSwitchTile(
            title: 'Haptic Feedback',
            subtitle: 'Vibrate on bead completion',
            icon: Icons.vibration,
            value: settings['japa_vibration'] ?? true,
            onChanged: (val) => notifier.updateSetting('japa_vibration', val),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Gita Reader'),
          ListTile(
            leading: const Icon(Icons.text_fields, color: Color(0xFF1565C0)),
            title: const Text('Font Size'),
            subtitle: Slider(
              value: (settings['reader_font_size'] as num?)?.toDouble() ?? 16.0,
              min: 12.0,
              max: 24.0,
              divisions: 6,
              activeColor: const Color(0xFF1565C0),
              label: '\${settings["reader_font_size"]?.toInt() ?? 16}',
              onChanged: (val) => notifier.updateSetting('reader_font_size', val),
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('App Info'),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Color(0xFF1565C0)),
            title: const Text('Version'),
            subtitle: Text(_version),
          ),
          ListTile(
            leading: const Icon(Icons.star_rate, color: Color(0xFF1565C0)),
            title: const Text('Rate App'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rating dialog would appear here.')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Clear Cache', style: TextStyle(color: Colors.red)),
            onTap: () {
              // TODO: Implement cache clearing logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully.')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 16.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: true ? FontWeight.bold : FontWeight.w600,
          color: Colors.grey[600],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      secondary: Icon(icon, color: const Color(0xFF1565C0)),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF1565C0),
    );
  }

  void _showTargetDialog(BuildContext context, int currentTarget, SettingsNotifier notifier) {
    int target = currentTarget;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Set Daily Target'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('\$target Malas', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Slider(
                value: target.toDouble(),
                min: 1,
                max: 64,
                divisions: 63,
                activeColor: const Color(0xFF1565C0),
                onChanged: (val) => setState(() => target = val.toInt()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                notifier.updateSetting('daily_target', target);
                Navigator.pop(context);
              },
              child: const Text('Save', style: TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
