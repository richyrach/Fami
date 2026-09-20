import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FamiPalette {
  static const lightBackground = Color(0xFFF5F5F7);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSecondary = Color(0xFF6E6E73);
  static const lightSeparator = Color(0x1A3C3C43);

  static const darkBackground = Color(0xFF000000);
  static const darkSurface = Color(0xFF1C1C1E);
  static const darkRaised = Color(0xFF242426);
  static const darkSecondary = Color(0xFF98989D);
  static const darkSeparator = Color(0x33545458);

  static const accent = Color(0xFF0A84FF);
  static const green = Color(0xFF30D158);
  static const red = Color(0xFFFF453A);
}

bool famiDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color famiBackground(BuildContext context) =>
    famiDark(context) ? FamiPalette.darkBackground : FamiPalette.lightBackground;

Color famiSurface(BuildContext context) =>
    famiDark(context) ? FamiPalette.darkSurface : FamiPalette.lightSurface;

Color famiSecondary(BuildContext context) =>
    famiDark(context) ? FamiPalette.darkSecondary : FamiPalette.lightSecondary;

Color famiSeparator(BuildContext context) =>
    famiDark(context) ? FamiPalette.darkSeparator : FamiPalette.lightSeparator;

class FamiPage extends StatelessWidget {
  const FamiPage({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(18, 8, 18, 104),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

class FamiGroup extends StatelessWidget {
  const FamiGroup({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.radius = 20,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: famiSurface(context),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: famiSeparator(context)),
        boxShadow: famiDark(context)
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.035),
                  blurRadius: 24,
                  offset: const Offset(0, 7),
                ),
              ],
      ),
      child: child,
    );
  }
}

class FamiGlass extends StatelessWidget {
  const FamiGlass({
    super.key,
    required this.child,
    this.radius = 26,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double radius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final dark = famiDark(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: dark
                ? const Color(0xD918181A)
                : const Color(0xDDF9F9FB),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: dark
                  ? const Color(0x6648484A)
                  : const Color(0xA8FFFFFF),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.30 : 0.09),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class FamiHeader extends StatelessWidget {
  const FamiHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.trailing,
  });

  final String title;
  final String? eyebrow;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null) ...[
                Text(
                  eyebrow!,
                  style: TextStyle(
                    color: famiSecondary(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 3),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 34,
                  height: 1.05,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.2,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class FamiSectionHeader extends StatelessWidget {
  const FamiSectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: const TextStyle(
                  color: FamiPalette.accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class FamiListRow extends StatelessWidget {
  const FamiListRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showChevron = true,
    this.iconBackground,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;
  final Color? iconBackground;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          Container(
            width: 31,
            height: 31,
            decoration: BoxDecoration(
              color: iconBackground ??
                  (famiDark(context)
                      ? const Color(0xFF2C2C2E)
                      : const Color(0xFFF0F0F2)),
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.1,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: famiSecondary(context),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
          if (trailing == null && showChevron)
            Icon(
              CupertinoIcons.chevron_forward,
              size: 16,
              color: famiSecondary(context),
            ),
        ],
      ),
    );

    if (onTap == null) return content;
    return InkWell(onTap: onTap, child: content);
  }
}

class FamiDivider extends StatelessWidget {
  const FamiDivider({super.key, this.indent = 57});

  final double indent;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      margin: EdgeInsets.only(left: indent),
      color: famiSeparator(context),
    );
  }
}

class FamiAvatar extends StatelessWidget {
  const FamiAvatar({
    super.key,
    required this.initial,
    this.size = 48,
    this.online = false,
  });

  final String initial;
  final double size;
  final bool online;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: famiDark(context)
                  ? const Color(0xFF2C2C2E)
                  : const Color(0xFFE9E9ED),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: TextStyle(
                fontSize: size * 0.36,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (online)
            Positioned(
              right: -1,
              bottom: 1,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: FamiPalette.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: famiSurface(context),
                    width: 2.2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class FamiPill extends StatelessWidget {
  const FamiPill({
    super.key,
    required this.label,
    this.icon,
    this.color,
  });

  final String label;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? FamiPalette.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: tint),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: tint,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
