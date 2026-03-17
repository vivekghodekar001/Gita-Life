import 'package:flutter/material.dart';
import '../../app/sacred_theme.dart';
import '../../widgets/sacred_widgets.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SacredColors.ink,
      body: SacredBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF8B6914).withOpacity(0.08),
                          border: Border.all(color: const Color(0xFF8B6914).withOpacity(0.2)),
                        ),
                        child: Icon(Icons.arrow_back_ios_new, size: 12, color: SacredColors.parchment.withOpacity(0.6)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('BOOKMARKS', style: SacredTextStyles.sectionLabel(fontSize: 10).copyWith(color: SacredColors.parchment.withOpacity(0.6), letterSpacing: 4)),
                  ],
                ),
              ),
              const Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'Bookmarks are coming soon.\nBrowse chapters to read verses.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Color(0xFF8B6914)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
