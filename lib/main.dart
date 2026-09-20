import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';\n\nimport 'wallet_tools.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FamiApp());
}

class FamiApp extends StatelessWidget {
  const FamiApp({super.key});

  @override
  Widget build(BuildContext context) {
    const lightScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF007AFF),
      onPrimary: Colors.white,
      secondary: Color(0xFF5856D6),
      onSecondary: Colors.white,
      error: Color(0xFFFF3B30),
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Color(0xFF111113),
    );

    const darkScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF0A84FF),
      onPrimary: Colors.white,
      secondary: Color(0xFF5E5CE6),
      onSecondary: Colors.white,
      error: Color(0xFFFF453A),
      onError: Colors.white,
      surface: Color(0xFF1C1C1E),
      onSurface: Colors.white,
    );

    ThemeData buildTheme(ColorScheme scheme) {
      final isDark = scheme.brightness == Brightness.dark;
      return ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor:
            isDark ? const Color(0xFF000000) : const Color(0xFFF7F7F8),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        dividerColor:
            isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
        textTheme: const TextTheme(
          displaySmall: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.1,
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.7,
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
          titleMedium: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(fontSize: 17),
          bodyMedium: TextStyle(fontSize: 15),
          bodySmall: TextStyle(fontSize: 13),
        ),
      );
    }

    return MaterialApp(
      title: 'Fami',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(lightScheme),
      darkTheme: buildTheme(darkScheme),
      themeMode: ThemeMode.system,
      home: const FamiShell(),
    );
  }
}

class FamiShell extends StatefulWidget {
  const FamiShell({super.key});

  @override
  State<FamiShell> createState() => _FamiShellState();
}

class _FamiShellState extends State<FamiShell> {
  int _index = 0;

  final _pages = const [
    HomeScreen(),
    ChatScreen(),
    FamilyScreen(),
    WalletScreen(),
  ];

  void _select(int index) {
    HapticFeedback.selectionClick();
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _index, children: _pages),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              minimum: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: FamiDock(
                selectedIndex: _index,
                onSelect: _select,
                onCompose: () => showComposer(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FamiDock extends StatelessWidget {
  const FamiDock({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    required this.onCompose,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onCompose;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: dark
                ? const Color(0xE618181A)
                : const Color(0xE6FFFFFF),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: dark
                  ? const Color(0xFF333336)
                  : const Color(0xFFE9E9EC),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.32 : 0.10),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              DockItem(
                icon: Icons.home_rounded,
                label: 'Home',
                active: selectedIndex == 0,
                onTap: () => onSelect(0),
              ),
              DockItem(
                icon: Icons.chat_bubble_rounded,
                label: 'Chat',
                active: selectedIndex == 1,
                onTap: () => onSelect(1),
              ),
              Semantics(
                button: true,
                label: 'Create new',
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onCompose();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dark
                          ? const Color(0xFF2C2C2E)
                          : const Color(0xFFF1F1F3),
                      border: Border.all(
                        color: dark
                            ? const Color(0xFF48484A)
                            : const Color(0xFFD8D8DC),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(Icons.add_rounded, color: accent, size: 30),
                  ),
                ),
              ),
              DockItem(
                icon: Icons.group_rounded,
                label: 'Family',
                active: selectedIndex == 2,
                onTap: () => onSelect(2),
              ),
              DockItem(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Wallet',
                active: selectedIndex == 3,
                onTap: () => onSelect(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DockItem extends StatelessWidget {
  const DockItem({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final muted = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF8E8E93)
        : const Color(0xFF6E6E73);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 52,
        height: 58,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 180),
              scale: active ? 1.08 : 1,
              child: Icon(icon, size: 23, color: active ? accent : muted),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color: active ? accent : muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showComposer(BuildContext context) async {
  final dark = Theme.of(context).brightness == Brightness.dark;
  await showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor:
        dark ? const Color(0xFF1C1C1E) : const Color(0xFFF9F9FA),
    builder: (context) {
      const actions = [
        ComposerAction(Icons.photo_rounded, 'Photo'),
        ComposerAction(Icons.mic_rounded, 'Voice message'),
        ComposerAction(Icons.poll_rounded, 'Poll'),
        ComposerAction(Icons.calendar_month_rounded, 'Event'),
        ComposerAction(Icons.campaign_rounded, 'Announcement'),
        ComposerAction(Icons.note_alt_rounded, 'Note'),
        ComposerAction(Icons.attach_money_rounded, 'Expense'),
        ComposerAction(Icons.check_circle_outline_rounded, 'Task'),
      ];

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Create New',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Surface(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (int i = 0; i < actions.length; i++) ...[
                    ListTile(
                      minTileHeight: 52,
                      leading: Icon(actions[i].icon, size: 22),
                      title: Text(actions[i].label),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                      ),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                    ),
                    if (i != actions.length - 1)
                      const Divider(height: 1, indent: 54),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

class ComposerAction {
  const ComposerAction(this.icon, this.label);
  final IconData icon;
  final String label;
}

class ScreenFrame extends StatelessWidget {
  const ScreenFrame({
    super.key,
    required this.child,
    this.horizontalPadding = 18,
  });

  final Widget child;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(horizontalPadding, 10, horizontalPadding, 96),
        child: child,
      ),
    );
  }
}

class Surface extends StatelessWidget {
  const Surface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 22,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: dark ? const Color(0xFF2C2C2E) : const Color(0xFFE8E8EB),
        ),
        boxShadow: dark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: child,
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.action});

  final String title;
  final String? action;

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF98989D)
        : const Color(0xFF6E6E73);

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        if (action != null)
          Text(
            action!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          )
        else
          Text('', style: TextStyle(color: secondary)),
      ],
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF98989D)
        : const Color(0xFF6E6E73);

    return ScreenFrame(
      child: ListView(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Good afternoon,', style: TextStyle(color: secondary)),
                    const SizedBox(height: 2),
                    Text(
                      'Mahdiar',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Saturday, 20 September',
                      style: TextStyle(color: secondary, fontSize: 14),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const MoreScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.person_outline_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1C1C1E)
                      : Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const FamilyStrip(),
          const SizedBox(height: 20),
          Surface(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.campaign_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 13),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Family Announcement',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Dinner at Grandma's tonight",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text('7:30 PM · Seen by 2/3'),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionTitle('Today', action: 'See All'),
          const SizedBox(height: 10),
          Surface(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: const Column(
              children: [
                EventRow(
                  time: '16:00',
                  title: 'Dentist — Mom',
                  subtitle: 'City Dental Clinic',
                ),
                Divider(height: 1, indent: 70),
                EventRow(
                  time: '19:30',
                  title: "Grandma's house",
                  subtitle: 'Everyone',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const MiniBankCard(),
          const SizedBox(height: 22),
          const SectionTitle('Upcoming'),
          const SizedBox(height: 10),
          Surface(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: const Column(
              children: [
                FinanceRow(
                  title: 'Google One',
                  subtitle: 'Sep 23',
                  trailing: r'$1.99',
                ),
                Divider(height: 1, indent: 52),
                FinanceRow(
                  title: 'Spotify Premium',
                  subtitle: 'Sep 29',
                  trailing: r'$5.49',
                ),
                Divider(height: 1, indent: 52),
                FinanceRow(
                  title: 'ChatGPT',
                  subtitle: 'Oct 12',
                  trailing: r'$20.00',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FamilyStrip extends StatelessWidget {
  const FamilyStrip({super.key});

  @override
  Widget build(BuildContext context) {
    const people = [
      ('M', 'You', 'Home'),
      ('M', 'Mom', 'Home'),
      ('M', 'Dad', 'Work'),
      ('P', 'Pendar', 'With Mom'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: people
          .map(
            (person) => SizedBox(
              width: 72,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF2C2C2E)
                            : const Color(0xFFE9E9EC),
                    child: Text(
                      person.$1,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    person.$2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    person.$3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF98989D)
                          : const Color(0xFF6E6E73),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class EventRow extends StatelessWidget {
  const EventRow({
    super.key,
    required this.time,
    required this.title,
    required this.subtitle,
  });

  final String time;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: 62,
      leading: SizedBox(
        width: 42,
        child: Text(
          time,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}

class MiniBankCard extends StatelessWidget {
  const MiniBankCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      constraints: const BoxConstraints(minHeight: 174),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B2A4A), Color(0xFF174D74), Color(0xFF7A6B58)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Bank Muscat',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Spacer(),
              Text(
                'VISA',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          Spacer(),
          Text(
            '1.865 OMR',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
            ),
          ),
          SizedBox(height: 6),
          Text(
            '≈ $4.85  ·  ≈ 1.12M toman',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Text(
                '•••• 4275',
                style: TextStyle(color: Colors.white70),
              ),
              Spacer(),
              Text(
                'Manual balance',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FinanceRow extends StatelessWidget {
  const FinanceRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: 56,
      leading: const Icon(Icons.autorenew_rounded),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: Text(
        trailing,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(child: Text('F')),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Family', style: Theme.of(context).textTheme.titleLarge),
                    const Text('4 members'),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.call_outlined),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.videocam_outlined),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 12),
              children: const [
                MessageBubble(
                  sender: 'Mom',
                  text: "Don't forget the dentist today at 4!",
                ),
                MessageBubble(
                  sender: 'You',
                  text: 'Got it 👍',
                  mine: true,
                ),
                MessageBubble(
                  sender: 'Dad',
                  text: "Dinner at Grandma's tonight? 7:30?",
                ),
                PollBubble(),
                MessageBubble(
                  sender: 'Mom',
                  text: "I'll prepare something 🙂",
                ),
              ],
            ),
          ),
          ChatComposer(onPlus: () => showComposer(context)),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.sender,
    required this.text,
    this.mine = false,
  });

  final String sender;
  final String text;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bubble = mine
        ? Theme.of(context).colorScheme.primary
        : dark
            ? const Color(0xFF262628)
            : const Color(0xFFE9E9EC);

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment:
              mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                sender,
                style: TextStyle(
                  fontSize: 11,
                  color: dark
                      ? const Color(0xFF98989D)
                      : const Color(0xFF6E6E73),
                ),
              ),
            ),
            const SizedBox(height: 3),
            Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bubble,
                borderRadius: BorderRadius.circular(19),
              ),
              child: Text(
                text,
                style: TextStyle(color: mine ? Colors.white : null),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PollBubble extends StatelessWidget {
  const PollBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Surface(
          padding: const EdgeInsets.all(14),
          child: SizedBox(
            width: 260,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Should we take the car or taxi?',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                _PollOption(label: 'Car', value: 0.67),
                const SizedBox(height: 7),
                _PollOption(label: 'Taxi', value: 0.33),
                const SizedBox(height: 8),
                const Text('3 votes', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PollOption extends StatelessWidget {
  const _PollOption({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Stack(
      children: [
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        FractionallySizedBox(
          widthFactor: value,
          child: Container(
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        SizedBox(
          height: 36,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11),
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ],
    );
  }
}

class ChatComposer extends StatelessWidget {
  const ChatComposer({super.key, required this.onPlus});

  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        IconButton(
          onPressed: onPlus,
          icon: const Icon(Icons.add_circle_outline_rounded),
        ),
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF1C1C1E) : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: dark ? const Color(0xFF343437) : const Color(0xFFD8D8DC),
              ),
            ),
            child: const TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Message',
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.mic_none_rounded),
        ),
      ],
    );
  }
}

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const members = [
      FamilyMember('M', 'Mahdiar', 'You', 'Home'),
      FamilyMember('M', 'Masoumeh', 'Mom', 'Home'),
      FamilyMember('M', 'Mohammad', 'Dad', 'Work'),
      FamilyMember('P', 'Pendar', 'Brother · dependent', 'With Mom'),
    ];

    return ScreenFrame(
      child: ListView(
        children: [
          Text('Our Family', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 4),
          Text(
            'Always connected',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF98989D)
                  : const Color(0xFF6E6E73),
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            itemCount: members.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.92,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) =>
                FamilyMemberCard(member: members[index]),
          ),
          const SizedBox(height: 24),
          const SectionTitle('Shared Location'),
          const SizedBox(height: 10),
          Surface(
            padding: const EdgeInsets.all(0),
            child: Column(
              children: [
                Container(
                  height: 170,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF202124)
                        : const Color(0xFFEDEEF0),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.location_on_rounded,
                      size: 42,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const ListTile(
                  leading: CircleAvatar(child: Text('M')),
                  title: Text('Mom'),
                  subtitle: Text('Home · 2 min ago'),
                  trailing: Icon(Icons.chevron_right_rounded),
                ),
                const Divider(height: 1, indent: 70),
                const ListTile(
                  leading: CircleAvatar(child: Text('M')),
                  title: Text('Dad'),
                  subtitle: Text('Work · 12 min ago'),
                  trailing: Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FamilyMember {
  const FamilyMember(this.initial, this.name, this.relationship, this.status);

  final String initial;
  final String name;
  final String relationship;
  final String status;
}

class FamilyMemberCard extends StatelessWidget {
  const FamilyMemberCard({super.key, required this.member});

  final FamilyMember member;

  @override
  Widget build(BuildContext context) {
    return Surface(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            child: Text(
              member.initial,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
            ),
          ),
          const Spacer(),
          Text(
            member.name,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(member.relationship),
          const SizedBox(height: 9),
          Row(
            children: [
              Icon(
                Icons.circle,
                size: 8,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  member.status,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      child: ListView(
        children: [
          Text('Wallet', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 4),
          Text(
            'Cards, subscriptions, domains and rates',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF98989D)
                  : const Color(0xFF6E6E73),
            ),
          ),
          const SizedBox(height: 20),
          const MiniBankCard(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SmallAction(
                  icon: Icons.currency_exchange_rounded,
                  label: 'Convert',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const CurrencyConverterScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SmallAction(
                  icon: Icons.receipt_long_rounded,
                  label: 'Transactions',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SmallAction(
                  icon: Icons.credit_card_rounded,
                  label: 'Card details',
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionTitle('Money'),
          const SizedBox(height: 10),
          Surface(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                WalletNavRow(
                  icon: Icons.autorenew_rounded,
                  title: 'Subscriptions',
                  subtitle: r'4 active · $28.47 / month',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SubscriptionsScreen(),
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                WalletNavRow(
                  icon: Icons.language_rounded,
                  title: 'Domains',
                  subtitle: r'3 to keep · $55.20 / year',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DomainsScreen(),
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                WalletNavRow(
                  icon: Icons.show_chart_rounded,
                  title: 'Currency rates',
                  subtitle: 'USD / toman · TGJU',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ExchangeRateScreen(),
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                const WalletNavRow(
                  icon: Icons.history_rounded,
                  title: 'Payment history',
                  subtitle: 'Manual records for now',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionTitle('Subscriptions', action: 'Manage'),
          const SizedBox(height: 10),
          Surface(
            padding: EdgeInsets.zero,
            child: const Column(
              children: [
                FinanceRow(
                  title: 'ChatGPT',
                  subtitle: 'Oct 12 · Active',
                  trailing: r'$20.00',
                ),
                Divider(height: 1, indent: 52),
                FinanceRow(
                  title: 'iCloud',
                  subtitle: 'Oct 12 · Active',
                  trailing: r'$0.99',
                ),
                Divider(height: 1, indent: 52),
                FinanceRow(
                  title: 'Spotify Premium',
                  subtitle: 'Sep 29 · Active',
                  trailing: r'$5.49',
                ),
                Divider(height: 1, indent: 52),
                FinanceRow(
                  title: 'Google One',
                  subtitle: 'Sep 23 · Active',
                  trailing: r'$1.99',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionTitle('Domains', action: 'Manage'),
          const SizedBox(height: 10),
          Surface(
            padding: EdgeInsets.zero,
            child: const Column(
              children: [
                DomainRow(
                  domain: 'safeworldstudios.com',
                  date: 'Aug 19, 2027',
                  keep: true,
                ),
                Divider(height: 1, indent: 20),
                DomainRow(
                  domain: 'sevoria.co',
                  date: 'Jun 25, 2027',
                  keep: true,
                ),
                Divider(height: 1, indent: 20),
                DomainRow(
                  domain: 'staffrater.xyz',
                  date: 'Sep 19, 2027',
                  keep: true,
                ),
                Divider(height: 1, indent: 20),
                DomainRow(
                  domain: 'miryn.space',
                  date: 'Oct 15, 2026',
                  keep: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SmallAction extends StatelessWidget {
  const SmallAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Surface(
      padding: EdgeInsets.zero,
      radius: 18,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 78,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WalletNavRow extends StatelessWidget {
  const WalletNavRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: 62,
      onTap: onTap,
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}

class DomainRow extends StatelessWidget {
  const DomainRow({
    super.key,
    required this.domain,
    required this.date,
    required this.keep,
  });

  final String domain;
  final String date;
  final bool keep;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: 60,
      title: Text(domain, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(keep ? 'Keep · renews $date' : 'Let expire · $date'),
      trailing: Icon(
        keep ? Icons.check_circle_rounded : Icons.schedule_rounded,
        color: keep ? Theme.of(context).colorScheme.primary : null,
      ),
    );
  }
}

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF98989D)
        : const Color(0xFF6E6E73);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('More'),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
          children: [
            Surface(
              child: Row(
                children: [
                  const CircleAvatar(radius: 30, child: Text('M')),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mahdiar',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                        Text('@mahdiar', style: TextStyle(color: secondary)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Surface(
              padding: EdgeInsets.zero,
              child: const Column(
                children: [
                  MoreRow(Icons.photo_library_outlined, 'Memories'),
                  Divider(height: 1, indent: 56),
                  MoreRow(Icons.calendar_month_outlined, 'Calendar'),
                  Divider(height: 1, indent: 56),
                  MoreRow(Icons.folder_outlined, 'Files'),
                  Divider(height: 1, indent: 56),
                  MoreRow(Icons.checklist_rounded, 'Lists'),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Surface(
              padding: EdgeInsets.zero,
              child: const Column(
                children: [
                  MoreRow(Icons.settings_outlined, 'Settings'),
                  Divider(height: 1, indent: 56),
                  MoreRow(Icons.notifications_none_rounded, 'Notifications'),
                  Divider(height: 1, indent: 56),
                  MoreRow(Icons.lock_outline_rounded, 'Privacy'),
                  Divider(height: 1, indent: 56),
                  MoreRow(Icons.contrast_rounded, 'Appearance'),
                  Divider(height: 1, indent: 56),
                  MoreRow(Icons.help_outline_rounded, 'Help & Support'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MoreRow extends StatelessWidget {
  const MoreRow(this.icon, this.title, {super.key});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: 58,
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}
