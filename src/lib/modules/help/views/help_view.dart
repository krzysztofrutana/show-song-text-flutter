import 'package:flutter/material.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';

class HelpView extends StatelessWidget {
  const HelpView({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme.onSurface;
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSection(
          context,
          localizations.helpSongsTitle,
          localizations.helpSongsDescription,
          ImageIcon(
            const AssetImage('assets/images/icons/note.png'),
            color: color,
          ),
        ),
        const SizedBox(height: 16),
        _buildSection(
          context,
          localizations.helpPlaylistsTitle,
          localizations.helpPlaylistsDescription,
          ImageIcon(
            const AssetImage('assets/images/icons/playlist.png'),
            color: color,
          ),
        ),
        const SizedBox(height: 16),
        _buildSection(
          context,
          localizations.helpPresentationTitle,
          localizations.helpPresentationDescription,
          ImageIcon(
            const AssetImage('assets/images/icons/presentation.png'),
            color: color,
          ),
        ),
        const SizedBox(height: 16),
        _buildSection(
          context,
          localizations.helpClientTitle,
          localizations.helpClientDescription,
          Icon(Icons.cast, color: color),
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
    final color = Theme.of(context).colorScheme.onSurface;
    final dividerColor = Theme.of(context).dividerColor;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: dividerColor),
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
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            Divider(color: dividerColor),
            Text(description, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
