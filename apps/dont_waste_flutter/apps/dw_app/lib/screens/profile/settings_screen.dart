import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dw_ui/dw_ui.dart';

/// Settings screen
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _darkMode = false;
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  String _distanceUnit = 'km';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Appearance section
          _SectionHeader(title: 'Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme'),
            value: _darkMode,
            onChanged: (value) {
              setState(() => _darkMode = value);
              // TODO: Apply theme
            },
          ),

          // Notifications section
          _SectionHeader(title: 'Notifications'),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive push notifications'),
            value: _pushNotifications,
            onChanged: (value) {
              setState(() => _pushNotifications = value);
            },
          ),
          SwitchListTile(
            title: const Text('Email Notifications'),
            subtitle: const Text('Receive email updates'),
            value: _emailNotifications,
            onChanged: (value) {
              setState(() => _emailNotifications = value);
            },
          ),

          // Units section
          _SectionHeader(title: 'Units'),
          ListTile(
            title: const Text('Distance Unit'),
            subtitle: Text(_distanceUnit == 'km' ? 'Kilometers' : 'Miles'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => SimpleDialog(
                  title: const Text('Distance Unit'),
                  children: [
                    RadioListTile(
                      title: const Text('Kilometers'),
                      value: 'km',
                      groupValue: _distanceUnit,
                      onChanged: (value) {
                        setState(() => _distanceUnit = value!);
                        Navigator.pop(context);
                      },
                    ),
                    RadioListTile(
                      title: const Text('Miles'),
                      value: 'mi',
                      groupValue: _distanceUnit,
                      onChanged: (value) {
                        setState(() => _distanceUnit = value!);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          ),

          // Privacy section
          _SectionHeader(title: 'Privacy'),
          ListTile(
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Open privacy policy
            },
          ),
          ListTile(
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Open terms
            },
          ),

          // Data section
          _SectionHeader(title: 'Data'),
          ListTile(
            title: const Text('Clear Cache'),
            subtitle: const Text('Free up storage space'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Clear cache
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
            },
          ),
          ListTile(
            title: Text(
              'Delete Account',
              style: TextStyle(color: DwColors.error),
            ),
            subtitle: const Text('Permanently delete your account'),
            trailing: Icon(Icons.chevron_right, color: DwColors.error),
            onTap: () {
              // TODO: Delete account flow
            },
          ),

          // App info
          _SectionHeader(title: 'About'),
          ListTile(
            title: const Text('Version'),
            subtitle: const Text('1.0.0 (1)'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DwSpacing.md,
        DwSpacing.lg,
        DwSpacing.md,
        DwSpacing.sm,
      ),
      child: Text(
        title,
        style: DwTextStyles.titleSmall.copyWith(
          color: DwColors.primary,
        ),
      ),
    );
  }
}
