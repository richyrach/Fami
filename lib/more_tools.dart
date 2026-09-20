import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme_controller.dart';

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
        backgroundColor: Colors.transparent,
      ),
      body: ValueListenableBuilder<ThemeMode>(
        valueListenable: famiThemeMode,
        builder: (context, mode, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
            children: [
              _SettingsGroup(
                children: [
                  _ThemeRow(
                    label: 'System',
                    value: ThemeMode.system,
                    current: mode,
                  ),
                  const Divider(height: 1, indent: 16),
                  _ThemeRow(
                    label: 'Light',
                    value: ThemeMode.light,
                    current: mode,
                  ),
                  const Divider(height: 1, indent: 16),
                  _ThemeRow(
                    label: 'Dark',
                    value: ThemeMode.dark,
                    current: mode,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const _InfoText(
                'Fami uses restrained neutral surfaces in both themes. '
                'Accent color is reserved for selection, actions, and status — not every card.',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ThemeRow extends StatelessWidget {
  const _ThemeRow({
    required this.label,
    required this.value,
    required this.current,
  });

  final String label;
  final ThemeMode value;
  final ThemeMode current;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: current == value
          ? Icon(
              Icons.check_rounded,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: () {
        HapticFeedback.selectionClick();
        famiThemeMode.value = value;
      },
    );
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool chat = true;
  bool announcements = true;
  bool payments = true;
  bool events = true;
  bool location = false;
  bool memories = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        children: [
          _SettingsGroup(
            children: [
              _ToggleRow(
                title: 'Chat',
                subtitle: 'New family messages',
                value: chat,
                onChanged: (v) => setState(() => chat = v),
              ),
              const Divider(height: 1, indent: 16),
              _ToggleRow(
                title: 'Announcements',
                subtitle: 'Family notices and priority posts',
                value: announcements,
                onChanged: (v) => setState(() => announcements = v),
              ),
              const Divider(height: 1, indent: 16),
              _ToggleRow(
                title: 'Payments',
                subtitle: 'Renewals and payment reminders',
                value: payments,
                onChanged: (v) => setState(() => payments = v),
              ),
              const Divider(height: 1, indent: 16),
              _ToggleRow(
                title: 'Events',
                subtitle: 'Upcoming plans and calendar alerts',
                value: events,
                onChanged: (v) => setState(() => events = v),
              ),
              const Divider(height: 1, indent: 16),
              _ToggleRow(
                title: 'Location',
                subtitle: 'Optional arrival and departure alerts',
                value: location,
                onChanged: (v) => setState(() => location = v),
              ),
              const Divider(height: 1, indent: 16),
              _ToggleRow(
                title: 'Memories',
                subtitle: 'On-this-day and shared memory alerts',
                value: memories,
                onChanged: (v) => setState(() => memories = v),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _InfoText(
            'These are local prototype controls. Device push permissions and per-family-member notification rules will be connected later.',
          ),
        ],
      ),
    );
  }
}

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  String location = 'Place only';
  bool readReceipts = true;
  bool onlineStatus = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        children: [
          Text(
            'Location sharing',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _SettingsGroup(
            children: [
              for (final option in [
                'Precise',
                'Approximate',
                'Place only',
                'Off',
              ]) ...[
                ListTile(
                  title: Text(option),
                  trailing: location == option
                      ? Icon(
                          Icons.check_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => location = option);
                  },
                ),
                if (option != 'Off')
                  const Divider(height: 1, indent: 16),
              ],
            ],
          ),
          const SizedBox(height: 18),
          _SettingsGroup(
            children: [
              _ToggleRow(
                title: 'Read receipts',
                subtitle: 'Let family know when you saw a message',
                value: readReceipts,
                onChanged: (v) => setState(() => readReceipts = v),
              ),
              const Divider(height: 1, indent: 16),
              _ToggleRow(
                title: 'Online status',
                subtitle: 'Show when you are currently using Fami',
                value: onlineStatus,
                onChanged: (v) => setState(() => onlineStatus = v),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _InfoText(
            'Location sharing must always be controlled by the person being located. '
            'No family admin should be able to silently turn another member’s location on.',
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: dark ? const Color(0xFF2C2C2E) : const Color(0xFFE8E8EB),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _InfoText extends StatelessWidget {
  const _InfoText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF98989D)
            : const Color(0xFF6E6E73),
        fontSize: 13,
        height: 1.4,
      ),
    );
  }
}
