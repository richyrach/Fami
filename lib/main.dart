import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'family_content.dart';
import 'fami_design.dart';
import 'more_tools.dart';
import 'theme_controller.dart';
import 'update_service.dart';
import 'wallet_tools.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FamiApp());
}

class FamiApp extends StatelessWidget {
  const FamiApp({super.key});

  ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: FamiPalette.accent,
      onPrimary: Colors.white,
      secondary: FamiPalette.accent,
      onSecondary: Colors.white,
      error: FamiPalette.red,
      onError: Colors.white,
      surface: dark ? FamiPalette.darkSurface : FamiPalette.lightSurface,
      onSurface: dark ? Colors.white : const Color(0xFF111113),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          dark ? FamiPalette.darkBackground : FamiPalette.lightBackground,
      canvasColor:
          dark ? FamiPalette.darkBackground : FamiPalette.lightBackground,
      dividerColor:
          dark ? FamiPalette.darkSeparator : FamiPalette.lightSeparator,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: dark ? Colors.white : const Color(0xFF111113),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: dark ? Colors.white : const Color(0xFF111113),
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: const TextStyle(fontSize: 17, height: 1.28),
        bodyMedium: const TextStyle(fontSize: 15, height: 1.28),
        bodySmall: TextStyle(
          fontSize: 13,
          color: dark
              ? FamiPalette.darkSecondary
              : FamiPalette.lightSecondary,
        ),
        titleLarge: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        titleMedium: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.15,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: famiThemeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Fami',
          debugShowCheckedModeBanner: false,
          theme: _theme(Brightness.light),
          darkTheme: _theme(Brightness.dark),
          themeMode: mode,
          home: const FamiShell(),
        );
      },
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

  final List<Widget> _pages = const [
    HomeScreen(),
    ChatScreen(),
    FamilyScreen(),
    WalletScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) UpdateManager.maybePrompt(context);
    });
  }

  void _select(int index) {
    HapticFeedback.selectionClick();
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: KeyedSubtree(
              key: ValueKey(_index),
              child: _pages[_index],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              minimum: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: _BottomDock(
                selected: _index,
                onSelect: _select,
                onPlus: () => showFamiComposer(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomDock extends StatelessWidget {
  const _BottomDock({
    required this.selected,
    required this.onSelect,
    required this.onPlus,
  });

  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return FamiGlass(
      radius: 28,
      child: SizedBox(
        height: 66,
        child: Row(
          children: [
            Expanded(
              child: _DockButton(
                icon: CupertinoIcons.house,
                activeIcon: CupertinoIcons.house_fill,
                label: 'Home',
                active: selected == 0,
                onTap: () => onSelect(0),
              ),
            ),
            Expanded(
              child: _DockButton(
                icon: CupertinoIcons.chat_bubble_2,
                activeIcon: CupertinoIcons.chat_bubble_2_fill,
                label: 'Chat',
                active: selected == 1,
                onTap: () => onSelect(1),
              ),
            ),
            SizedBox(
              width: 66,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onPlus();
                  },
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: famiDark(context)
                          ? const Color(0xFF2C2C2E)
                          : Colors.white,
                      border: Border.all(color: famiSeparator(context)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      CupertinoIcons.add,
                      color: FamiPalette.accent,
                      size: 25,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _DockButton(
                icon: CupertinoIcons.person_2,
                activeIcon: CupertinoIcons.person_2_fill,
                label: 'Family',
                active: selected == 2,
                onTap: () => onSelect(2),
              ),
            ),
            Expanded(
              child: _DockButton(
                icon: CupertinoIcons.creditcard,
                activeIcon: CupertinoIcons.creditcard_fill,
                label: 'Wallet',
                active: selected == 3,
                onTap: () => onSelect(3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DockButton extends StatelessWidget {
  const _DockButton({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final inactive = famiSecondary(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            duration: const Duration(milliseconds: 170),
            curve: Curves.easeOutBack,
            scale: active ? 1.05 : 1,
            child: Icon(
              active ? activeIcon : icon,
              size: 22,
              color: active ? FamiPalette.accent : inactive,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: active ? FamiPalette.accent : inactive,
              fontSize: 9.5,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FamiPage(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          FamiHeader(
            eyebrow: 'Saturday, 20 September',
            title: 'Good afternoon, Mahdiar',
            trailing: _RoundAction(
              icon: CupertinoIcons.person_crop_circle,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const MoreScreen()),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _PeopleStrip(),
          const SizedBox(height: 26),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AnnouncementsScreen(),
              ),
            ),
            child: FamiGroup(
              padding: const EdgeInsets.fromLTRB(16, 15, 14, 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    CupertinoIcons.speaker_2,
                    color: FamiPalette.accent,
                    size: 20,
                  ),
                  const SizedBox(width: 13),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dinner at Grandma’s tonight',
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.15,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '7:30 PM · Family announcement',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: FamiPalette.lightSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    CupertinoIcons.chevron_forward,
                    size: 15,
                    color: famiSecondary(context),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 26),
          FamiSectionHeader(
            title: 'Today',
            action: 'See all',
            onAction: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const EventsScreen()),
            ),
          ),
          FamiGroup(
            child: Column(
              children: [
                _AgendaRow(
                  time: '16:00',
                  title: 'Dentist',
                  subtitle: 'Mom · City Dental Clinic',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const EventsScreen(),
                    ),
                  ),
                ),
                const FamiDivider(indent: 78),
                _AgendaRow(
                  time: '19:30',
                  title: 'Grandma’s house',
                  subtitle: 'Everyone',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const EventsScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          const FamiSectionHeader(title: 'Wallet'),
          GestureDetector(
            onTap: () {},
            child: const FamiBankCard(compact: true),
          ),
          const SizedBox(height: 26),
          const FamiSectionHeader(title: 'Coming up'),
          FamiGroup(
            child: Column(
              children: const [
                _PaymentRow(
                  title: 'Google One',
                  detail: 'Sep 23',
                  amount: '\$1.99',
                ),
                FamiDivider(),
                _PaymentRow(
                  title: 'Spotify Premium',
                  detail: 'Sep 29',
                  amount: '\$5.49',
                ),
                FamiDivider(),
                _PaymentRow(
                  title: 'ChatGPT',
                  detail: 'Oct 12',
                  amount: '\$20.00',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PeopleStrip extends StatelessWidget {
  const _PeopleStrip();

  @override
  Widget build(BuildContext context) {
    final people = const [
      ('M', 'You', 'Home'),
      ('M', 'Mom', 'Home'),
      ('M', 'Dad', 'Work'),
      ('P', 'Pendar', 'With Mom'),
    ];

    return Row(
      children: [
        for (int i = 0; i < people.length; i++) ...[
          Expanded(
            child: Column(
              children: [
                FamiAvatar(
                  initial: people[i].$1,
                  size: 50,
                  online: i < 3,
                ),
                const SizedBox(height: 8),
                Text(
                  people[i].$2,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  people[i].$3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: famiSecondary(context),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _AgendaRow extends StatelessWidget {
  const _AgendaRow({
    required this.time,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String time;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 13, 13, 13),
        child: Row(
          children: [
            SizedBox(
              width: 52,
              child: Text(
                time,
                style: const TextStyle(
                  color: FamiPalette.accent,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: famiSecondary(context),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_forward,
              size: 15,
              color: famiSecondary(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.title,
    required this.detail,
    required this.amount,
  });

  final String title;
  final String detail;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
      child: Row(
        children: [
          const Icon(CupertinoIcons.arrow_2_circlepath, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  detail,
                  style: TextStyle(
                    fontSize: 12,
                    color: famiSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FamiPage(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 94),
      child: Column(
        children: [
          Row(
            children: [
              const FamiAvatar(initial: 'F', size: 42, online: true),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Family',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      '4 members',
                      style: TextStyle(
                        fontSize: 12,
                        color: FamiPalette.lightSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _RoundAction(icon: CupertinoIcons.phone, onTap: () {}),
              const SizedBox(width: 6),
              _RoundAction(icon: CupertinoIcons.video_camera, onTap: () {}),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              reverse: false,
              physics: const BouncingScrollPhysics(),
              children: const [
                _DayDivider('Today'),
                _ChatMessage(
                  sender: 'Mom',
                  text: 'Don’t forget the dentist today at 4.',
                ),
                _ChatMessage(sender: 'You', text: 'Got it 👍', mine: true),
                _ChatMessage(
                  sender: 'Dad',
                  text: 'Dinner at Grandma’s tonight? 7:30?',
                ),
                _ChatPoll(),
                _ChatMessage(sender: 'Mom', text: 'I’ll prepare something 🙂'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _ChatInput(onPlus: () => showFamiComposer(context)),
        ],
      ),
    );
  }
}

class _DayDivider extends StatelessWidget {
  const _DayDivider(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          Expanded(child: Container(height: 0.5, color: famiSeparator(context))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              label,
              style: TextStyle(
                color: famiSecondary(context),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Container(height: 0.5, color: famiSeparator(context))),
        ],
      ),
    );
  }
}

class _ChatMessage extends StatelessWidget {
  const _ChatMessage({
    required this.sender,
    required this.text,
    this.mine = false,
  });

  final String sender;
  final String text;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final dark = famiDark(context);
    final bubbleColor = mine
        ? FamiPalette.accent
        : (dark ? const Color(0xFF242426) : const Color(0xFFE9E9ED));

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment:
              mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!mine)
              Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 3),
                child: Text(
                  sender,
                  style: TextStyle(
                    color: famiSecondary(context),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            Container(
              constraints: const BoxConstraints(maxWidth: 286),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(mine ? 18 : 5),
                  bottomRight: Radius.circular(mine ? 5 : 18),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: mine ? Colors.white : null,
                  fontSize: 15.5,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatPoll extends StatelessWidget {
  const _ChatPoll();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: SizedBox(
          width: 286,
          child: FamiGroup(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Should we take the car or taxi?',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                const _PollOption(label: 'Car', percent: 67),
                const SizedBox(height: 7),
                const _PollOption(label: 'Taxi', percent: 33),
                const SizedBox(height: 8),
                Text(
                  '3 votes',
                  style: TextStyle(
                    color: famiSecondary(context),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PollOption extends StatelessWidget {
  const _PollOption({required this.label, required this.percent});

  final String label;
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: FamiPalette.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: percent / 100,
            child: Container(
              decoration: BoxDecoration(
                color: FamiPalette.accent.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  percent.toString() + '%',
                  style: TextStyle(
                    color: famiSecondary(context),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  const _ChatInput({required this.onPlus});

  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return FamiGlass(
      radius: 24,
      child: SizedBox(
        height: 50,
        child: Row(
          children: [
            IconButton(
              onPressed: onPlus,
              icon: const Icon(
                CupertinoIcons.add_circled,
                color: FamiPalette.accent,
                size: 23,
              ),
            ),
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Message',
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                CupertinoIcons.mic,
                color: famiSecondary(context),
                size: 21,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FamiPage(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          FamiHeader(
            eyebrow: '4 people',
            title: 'Our Family',
            trailing: _RoundAction(
              icon: CupertinoIcons.ellipsis,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const MoreScreen()),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FamiGroup(
            child: Column(
              children: const [
                _MemberRow(
                  initial: 'M',
                  name: 'Mahdiar',
                  relationship: 'You',
                  status: 'Home',
                  online: true,
                ),
                FamiDivider(indent: 74),
                _MemberRow(
                  initial: 'M',
                  name: 'Masoumeh',
                  relationship: 'Mom',
                  status: 'Home',
                  online: true,
                ),
                FamiDivider(indent: 74),
                _MemberRow(
                  initial: 'M',
                  name: 'Mohammad',
                  relationship: 'Dad',
                  status: 'Work',
                  online: true,
                ),
                FamiDivider(indent: 74),
                _MemberRow(
                  initial: 'P',
                  name: 'Pendar',
                  relationship: 'Brother · dependent',
                  status: 'With Mom',
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          const FamiSectionHeader(title: 'Shared location'),
          FamiGroup(
            child: Column(
              children: [
                Container(
                  height: 152,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: famiDark(context)
                        ? const Color(0xFF242426)
                        : const Color(0xFFEDEEF1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(painter: _MapGridPainter(context)),
                      ),
                      const Positioned(
                        left: 70,
                        top: 55,
                        child: _MapPerson(initial: 'M'),
                      ),
                      const Positioned(
                        right: 62,
                        bottom: 37,
                        child: _MapPerson(initial: 'M'),
                      ),
                    ],
                  ),
                ),
                const FamiDivider(indent: 14),
                const FamiListRow(
                  icon: CupertinoIcons.location_fill,
                  title: 'Mom',
                  subtitle: 'Home · 2 min ago',
                ),
                const FamiDivider(),
                const FamiListRow(
                  icon: CupertinoIcons.location_fill,
                  title: 'Dad',
                  subtitle: 'Work · 12 min ago',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Everyone controls their own location sharing.',
            style: TextStyle(
              color: famiSecondary(context),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.initial,
    required this.name,
    required this.relationship,
    required this.status,
    this.online = false,
  });

  final String initial;
  final String name;
  final String relationship;
  final String status;
  final bool online;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      child: Row(
        children: [
          FamiAvatar(initial: initial, size: 46, online: online),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  relationship,
                  style: TextStyle(
                    color: famiSecondary(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          FamiPill(
            label: status,
            color: status == 'Home'
                ? FamiPalette.green
                : FamiPalette.accent,
          ),
          const SizedBox(width: 5),
          Icon(
            CupertinoIcons.chevron_forward,
            color: famiSecondary(context),
            size: 15,
          ),
        ],
      ),
    );
  }
}

class _MapPerson extends StatelessWidget {
  const _MapPerson({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 33,
      height: 33,
      decoration: BoxDecoration(
        color: famiSurface(context),
        shape: BoxShape.circle,
        border: Border.all(color: FamiPalette.accent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  _MapGridPainter(this.context);

  final BuildContext context;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = famiSeparator(context)
      ..strokeWidth = 1;
    for (double x = 20; x < size.width; x += 48) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 20; y < size.height; y += 42) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MapGridPainter oldDelegate) => false;
}

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FamiPage(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const FamiHeader(
            eyebrow: 'Personal finance',
            title: 'Wallet',
          ),
          const SizedBox(height: 22),
          const FamiBankCard(),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _WalletQuickAction(
                  icon: CupertinoIcons.arrow_2_circlepath,
                  label: 'Convert',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const CurrencyConverterScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _WalletQuickAction(
                  icon: CupertinoIcons.list_bullet,
                  label: 'Activity',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _WalletQuickAction(
                  icon: CupertinoIcons.creditcard,
                  label: 'Card',
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          const FamiSectionHeader(title: 'Money'),
          FamiGroup(
            child: Column(
              children: [
                FamiListRow(
                  icon: CupertinoIcons.arrow_2_circlepath,
                  title: 'Subscriptions',
                  subtitle: '4 active · \$28.47 / month',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SubscriptionsScreen(),
                    ),
                  ),
                ),
                const FamiDivider(),
                FamiListRow(
                  icon: CupertinoIcons.globe,
                  title: 'Domains',
                  subtitle: '3 to keep · \$55.20 / year',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DomainsScreen(),
                    ),
                  ),
                ),
                const FamiDivider(),
                FamiListRow(
                  icon: CupertinoIcons.chart_bar,
                  title: 'Currency rates',
                  subtitle: 'USD / toman · TGJU',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ExchangeRateScreen(),
                    ),
                  ),
                ),
                const FamiDivider(),
                const FamiListRow(
                  icon: CupertinoIcons.clock,
                  title: 'Payment history',
                  subtitle: 'Manual records for now',
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          const FamiSectionHeader(title: 'Next renewals'),
          FamiGroup(
            child: Column(
              children: const [
                _PaymentRow(
                  title: 'Google One',
                  detail: 'Sep 23 · Active',
                  amount: '\$1.99',
                ),
                FamiDivider(),
                _PaymentRow(
                  title: 'Spotify Premium',
                  detail: 'Sep 29 · Active',
                  amount: '\$5.49',
                ),
                FamiDivider(),
                _PaymentRow(
                  title: 'ChatGPT',
                  detail: 'Oct 12 · Active',
                  amount: '\$20.00',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FamiBankCard extends StatelessWidget {
  const FamiBankCard({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final height = compact ? 164.0 : 190.0;
    return Container(
      height: height,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: famiDark(context)
            ? const Color(0xFF111214)
            : const Color(0xFF151719),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: famiDark(context) ? 0.25 : 0.18),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'Bank Muscat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              Text(
                'VISA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Text(
            '1.865 OMR',
            style: TextStyle(
              color: Colors.white,
              fontSize: 31,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            r'≈ $4.85  ·  ≈ 1.12M toman',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.62),
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Text(
                '•••• 4275',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.68),
                  fontSize: 12.5,
                  letterSpacing: 0.6,
                ),
              ),
              const Spacer(),
              Text(
                'Manual',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.48),
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalletQuickAction extends StatelessWidget {
  const _WalletQuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: FamiGroup(
        radius: 17,
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Column(
          children: [
            Icon(icon, size: 20, color: FamiPalette.accent),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: famiBackground(context),
      appBar: AppBar(
        title: const Text('More'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(CupertinoIcons.back),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          FamiGroup(
            padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
            child: Row(
              children: [
                const FamiAvatar(initial: 'M', size: 54, online: true),
                const SizedBox(width: 13),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mahdiar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'View profile',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: FamiPalette.lightSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_forward,
                  size: 16,
                  color: famiSecondary(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FamiGroup(
            child: Column(
              children: [
                FamiListRow(
                  icon: CupertinoIcons.speaker_2,
                  title: 'Announcements',
                  onTap: () => _push(context, const AnnouncementsScreen()),
                ),
                const FamiDivider(),
                FamiListRow(
                  icon: CupertinoIcons.photo_on_rectangle,
                  title: 'Memories',
                  onTap: () => _push(context, const MemoriesScreen()),
                ),
                const FamiDivider(),
                FamiListRow(
                  icon: CupertinoIcons.calendar,
                  title: 'Calendar',
                  onTap: () => _push(context, const EventsScreen()),
                ),
                const FamiDivider(),
                FamiListRow(
                  icon: CupertinoIcons.folder,
                  title: 'Files',
                  onTap: () => _push(context, const FilesScreen()),
                ),
                const FamiDivider(),
                FamiListRow(
                  icon: CupertinoIcons.check_mark_circled,
                  title: 'Lists',
                  onTap: () => _push(context, const ListsScreen()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FamiGroup(
            child: Column(
              children: [
                FamiListRow(
                  icon: CupertinoIcons.bell,
                  title: 'Notifications',
                  onTap: () => _push(context, const NotificationsScreen()),
                ),
                const FamiDivider(),
                FamiListRow(
                  icon: CupertinoIcons.lock,
                  title: 'Privacy',
                  onTap: () => _push(context, const PrivacyScreen()),
                ),
                const FamiDivider(),
                FamiListRow(
                  icon: CupertinoIcons.circle_lefthalf_fill,
                  title: 'Appearance',
                  onTap: () => _push(context, const AppearanceScreen()),
                ),
                const FamiDivider(),
                FamiListRow(
                  icon: CupertinoIcons.arrow_down_circle,
                  title: 'App Update',
                  onTap: () => _push(context, const UpdateCenterScreen()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: famiSurface(context),
          border: Border.all(color: famiSeparator(context)),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 20),
      ),
    );
  }
}

class _ComposerRow extends StatelessWidget {
  const _ComposerRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        child: Row(
          children: [
            Container(
              width: 31,
              height: 31,
              decoration: BoxDecoration(
                color: famiDark(context)
                    ? const Color(0xFF2C2C2E)
                    : const Color(0xFFF0F0F2),
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                ),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_forward,
              size: 15,
              color: famiSecondary(context),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showFamiComposer(BuildContext context) async {
  final rootContext = context;
  await showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Container(
        decoration: BoxDecoration(
          color: famiBackground(sheetContext),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(14, 9, 14, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: famiSeparator(sheetContext),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Create New',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 16),
            FamiGroup(
              child: Column(
                children: [
                  _ComposerRow(
                    icon: CupertinoIcons.photo,
                    label: 'Photo or memory',
                    onTap: () => _composerOpen(
                      sheetContext,
                      rootContext,
                      const MemoriesScreen(),
                    ),
                  ),
                  const FamiDivider(),
                  _ComposerRow(
                    icon: CupertinoIcons.mic,
                    label: 'Voice message',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(rootContext).showSnackBar(
                        const SnackBar(
                          content: Text('Voice recording comes in the media pass.'),
                        ),
                      );
                    },
                  ),
                  const FamiDivider(),
                  _ComposerRow(
                    icon: CupertinoIcons.chart_bar,
                    label: 'Poll',
                    onTap: () => _composerOpen(
                      sheetContext,
                      rootContext,
                      const CreateItemScreen(type: 'Poll'),
                    ),
                  ),
                  const FamiDivider(),
                  _ComposerRow(
                    icon: CupertinoIcons.calendar,
                    label: 'Event',
                    onTap: () => _composerOpen(
                      sheetContext,
                      rootContext,
                      const CreateItemScreen(type: 'Event'),
                    ),
                  ),
                  const FamiDivider(),
                  _ComposerRow(
                    icon: CupertinoIcons.speaker_2,
                    label: 'Announcement',
                    onTap: () => _composerOpen(
                      sheetContext,
                      rootContext,
                      const CreateItemScreen(type: 'Announcement'),
                    ),
                  ),
                  const FamiDivider(),
                  _ComposerRow(
                    icon: CupertinoIcons.check_mark_circled,
                    label: 'Task',
                    onTap: () => _composerOpen(
                      sheetContext,
                      rootContext,
                      const CreateItemScreen(type: 'Task'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _composerOpen(
  BuildContext sheetContext,
  BuildContext rootContext,
  Widget page,
) async {
  HapticFeedback.lightImpact();
  Navigator.pop(sheetContext);
  await Future<void>.delayed(const Duration(milliseconds: 60));
  if (!rootContext.mounted) return;
  await Navigator.of(rootContext).push(
    MaterialPageRoute<void>(builder: (_) => page),
  );
}
