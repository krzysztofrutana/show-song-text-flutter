import 'package:flutter/material.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';

class HelpView extends StatelessWidget {
  const HelpView({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSection(
          context,
          localizations.helpSongsTitle,
          localizations.helpSongsDescription,
          const ImageIcon(
            AssetImage('assets/images/icons/note.png'),
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        _buildSection(
          context,
          localizations.helpPlaylistsTitle,
          localizations.helpPlaylistsDescription,
          const ImageIcon(
            AssetImage('assets/images/icons/playlist.png'),
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        _buildSection(
          context,
          localizations.helpPresentationTitle,
          localizations.helpPresentationDescription,
          const ImageIcon(
            AssetImage('assets/images/icons/presentation.png'),
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        _buildSection(
          context,
          localizations.helpClientTitle,
          localizations.helpClientDescription,
          const Icon(Icons.cast, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String description,
    Widget icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                icon,
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.black12),
            Text(
              description,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
