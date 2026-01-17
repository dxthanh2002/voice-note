import 'package:flutter/material.dart';

import '../../navigation/app_routes.dart';
import '../../theme/colors.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  // Switch states
  bool _autoVoiceDetection = true;
  bool _noiseFilter = true;
  bool _autoSummarize = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Text(
                  'Settings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 8),
              // Recording section
              _buildSection(
                context,
                title: 'RECORDING',
                items: [
                  _SettingsItem(
                    icon: Icons.graphic_eq,
                    title: 'Audio Quality',
                    subtitle: 'High',
                    onTap: () {},
                    trailing: const Icon(Icons.expand_more, color: AppColors.textMuted),
                  ),
                  _SettingsItem(
                    icon: Icons.record_voice_over,
                    title: 'Auto Voice Detection',
                    subtitle: 'Auto pause when silent',
                    trailing: Switch(
                      value: _autoVoiceDetection,
                      onChanged: (value) {
                        setState(() => _autoVoiceDetection = value);
                      },
                    ),
                  ),
                  _SettingsItem(
                    icon: Icons.noise_control_off,
                    title: 'Noise Filter',
                    subtitle: 'Reduce background noise',
                    trailing: Switch(
                      value: _noiseFilter,
                      onChanged: (value) {
                        setState(() => _noiseFilter = value);
                      },
                    ),
                  ),
                ],
              ),
              // Summary section
              _buildSection(
                context,
                title: 'SUMMARY',
                items: [
                  _SettingsItem(
                    icon: Icons.translate,
                    title: 'Summary Language',
                    subtitle: 'English',
                    onTap: () {},
                    trailing: const Icon(Icons.expand_more, color: AppColors.textMuted),
                  ),
                  _SettingsItem(
                    icon: Icons.auto_awesome,
                    title: 'Auto Summarize',
                    subtitle: 'After recording stops',
                    trailing: Switch(
                      value: _autoSummarize,
                      onChanged: (value) {
                        setState(() => _autoSummarize = value);
                      },
                    ),
                  ),
                ],
              ),
              // General section
              _buildSection(
                context,
                title: 'GENERAL',
                items: [
                  _SettingsItem(
                    icon: Icons.workspace_premium,
                    title: 'Upgrade to Pro',
                    subtitle: 'Unlimited recording & summary',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.upgrade);
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.account_circle,
                    title: 'Account Management',
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.dark_mode,
                    title: 'Appearance',
                    subtitle: 'System default',
                    onTap: () {},
                    trailing: const Icon(Icons.expand_more, color: AppColors.textMuted),
                  ),
                ],
              ),
              // Other section
              _buildSection(
                context,
                title: 'OTHER',
                items: [
                  _SettingsItem(
                    icon: Icons.help,
                    title: 'Help & Feedback',
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.info,
                    title: 'About',
                    onTap: () {},
                  ),
                ],
              ),
              // Logout button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error.withValues(alpha: 0.1),
                      foregroundColor: AppColors.error,
                      elevation: 0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<_SettingsItem> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  _buildItem(items[i], i == 0, i == items.length - 1),
                  if (i < items.length - 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(height: 1),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(_SettingsItem item, bool isFirst, bool isLast) {
    final borderRadius = BorderRadius.vertical(
      top: isFirst ? const Radius.circular(12) : Radius.zero,
      bottom: isLast ? const Radius.circular(12) : Radius.zero,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: borderRadius,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.icon, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (item.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              item.trailing ??
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textMuted,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsItem {
  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
}
