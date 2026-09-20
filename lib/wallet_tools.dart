import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  static const double usdPerOmr = 2.6008;
  static const double tomanPerUsd = 231015;

  final TextEditingController _omrController =
      TextEditingController(text: '1.865');

  double get omr => double.tryParse(_omrController.text) ?? 0;
  double get usd => omr * usdPerOmr;
  double get toman => usd * tomanPerUsd;

  @override
  void dispose() {
    _omrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final secondary =
        dark ? const Color(0xFF98989D) : const Color(0xFF6E6E73);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
        children: [
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Omani rial', style: TextStyle(color: secondary)),
                const SizedBox(height: 8),
                TextField(
                  controller: _omrController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    suffixText: 'OMR',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _ConversionLine(
            label: 'US dollars',
            value: '\$${usd.toStringAsFixed(2)}',
            note: '1 OMR = \$2.6008',
          ),
          const SizedBox(height: 10),
          _ConversionLine(
            label: 'Iranian toman',
            value: _formatNumber(toman.round()),
            note: 'Using 231,015 toman / USD',
          ),
          const SizedBox(height: 22),
          Text(
            'Rate source',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _Panel(
            child: Row(
              children: [
                const Icon(Icons.show_chart_rounded),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TGJU USD / toman',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Static prototype rate — live sync comes next.',
                        style: TextStyle(color: secondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'The OMR/USD rate is treated as a fixed conversion reference in this prototype. '
            'The Iranian market rate will be fetched from TGJU once networking is connected.',
            style: TextStyle(color: secondary, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class ExchangeRateScreen extends StatelessWidget {
  const ExchangeRateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final secondary =
        dark ? const Color(0xFF98989D) : const Color(0xFF6E6E73);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Rates'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
        children: [
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('US Dollar', style: TextStyle(color: secondary)),
                const SizedBox(height: 6),
                const Text(
                  '231,015 toman',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('TGJU · prototype snapshot'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _RateRow(
            title: '1 OMR',
            value: '\$2.6008',
            subtitle: 'USD reference conversion',
          ),
          const SizedBox(height: 10),
          const _RateRow(
            title: '1 OMR',
            value: '≈ 600,823 toman',
            subtitle: 'Derived from USD rate',
          ),
          const SizedBox(height: 22),
          Text(
            'Live history, daily high/low, refresh time, and TGJU network fetching are planned for the next networking pass.',
            style: TextStyle(color: secondary, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class SubscriptionItem {
  SubscriptionItem(
    this.name,
    this.price,
    this.date, {
    required this.active,
  });

  final String name;
  double price;
  String date;
  bool active;
}

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  final List<SubscriptionItem> items = [
    SubscriptionItem('ChatGPT', 20, 'Oct 12', active: true),
    SubscriptionItem('Claude', 20, 'No renewal', active: false),
    SubscriptionItem('iCloud', 0.99, 'Oct 12', active: true),
    SubscriptionItem('Roblox Plus', 0, 'No renewal', active: false),
    SubscriptionItem('Spotify Premium', 5.49, 'Sep 29', active: true),
    SubscriptionItem('Google One', 1.99, 'Sep 23', active: true),
  ];

  double get monthlyTotal =>
      items.where((item) => item.active).fold(0, (sum, item) => sum + item.price);

  Future<void> _edit(SubscriptionItem item) async {
    final price = TextEditingController(
      text: item.price == 0 ? '' : item.price.toStringAsFixed(2),
    );
    final date = TextEditingController(text: item.date);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          0,
          18,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 18),
            TextField(
              controller: price,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Monthly price (USD)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: date,
              decoration: const InputDecoration(labelText: 'Renewal date'),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () {
                setState(() {
                  item.price = double.tryParse(price.text) ?? item.price;
                  item.date =
                      date.text.trim().isEmpty ? item.date : date.text.trim();
                });
                Navigator.pop(context);
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscriptions'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        children: [
          _Panel(
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Active monthly total',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  '\$${monthlyTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Panel(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  ListTile(
                    onTap: () => _edit(items[i]),
                    title: Text(
                      items[i].name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      items[i].active
                          ? '\$${items[i].price.toStringAsFixed(2)} · ${items[i].date}'
                          : 'Inactive',
                    ),
                    trailing: Switch.adaptive(
                      value: items[i].active,
                      onChanged: (value) =>
                          setState(() => items[i].active = value),
                    ),
                  ),
                  if (i != items.length - 1)
                    const Divider(height: 1, indent: 16),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Prototype behavior: changes stay in memory until the app closes. Persistent family data comes with the backend/local-storage pass.',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF98989D)
                  : const Color(0xFF6E6E73),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class DomainItem {
  DomainItem(
    this.domain,
    this.price,
    this.renewal, {
    required this.keep,
  });

  final String domain;
  double price;
  String renewal;
  bool keep;
}

class DomainsScreen extends StatefulWidget {
  const DomainsScreen({super.key});

  @override
  State<DomainsScreen> createState() => _DomainsScreenState();
}

class _DomainsScreenState extends State<DomainsScreen> {
  final List<DomainItem> domains = [
    DomainItem('drmbaghban.com', 10.18, 'Jun 12, 2027', keep: false),
    DomainItem('memeline.org', 11.59, 'Jan 18, 2027', keep: false),
    DomainItem('miryn.space', 13.88, 'Oct 15, 2026', keep: false),
    DomainItem('mosaicpe.org', 11.59, 'Aug 22, 2027', keep: false),
    DomainItem('omanimpact.xyz', 13.97, 'Feb 22, 2027', keep: false),
    DomainItem('qtimmer.com', 10.18, 'Nov 11, 2026', keep: false),
    DomainItem('safeworldstudios.com', 10.18, 'Aug 19, 2027', keep: true),
    DomainItem('sevoria.co', 31.05, 'Jun 25, 2027', keep: true),
    DomainItem('sough.site', 15.28, 'Oct 11, 2026', keep: false),
    DomainItem('staffrater.xyz', 13.97, 'Sep 19, 2027', keep: true),
    DomainItem('whertowatch.click', 10.55, 'Dec 3, 2026', keep: false),
    DomainItem('quiet.buzz', 26.80, 'Jan 11, 2027', keep: false),
  ];

  double get keepTotal =>
      domains.where((d) => d.keep).fold(0, (sum, item) => sum + item.price);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Domains'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        children: [
          _Panel(
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Planned renewals',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  '\$${keepTotal.toStringAsFixed(2)} / year',
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Panel(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (int i = 0; i < domains.length; i++) ...[
                  ListTile(
                    title: Text(
                      domains[i].domain,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '\$${domains[i].price.toStringAsFixed(2)} · ${domains[i].renewal}',
                    ),
                    trailing: FilterChip(
                      selected: domains[i].keep,
                      label: Text(domains[i].keep ? 'Keep' : 'Expire'),
                      onSelected: (value) {
                        HapticFeedback.selectionClick();
                        setState(() => domains[i].keep = value);
                      },
                    ),
                  ),
                  if (i != domains.length - 1)
                    const Divider(height: 1, indent: 16),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversionLine extends StatelessWidget {
  const _ConversionLine({
    required this.label,
    required this.value,
    required this.note,
  });

  final String label;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label),
                const SizedBox(height: 3),
                Text(
                  note,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF98989D)
                        : const Color(0xFF6E6E73),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _RateRow extends StatelessWidget {
  const _RateRow({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle, style: const TextStyle(fontSize: 12.5)),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(22),
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

String _formatNumber(int value) {
  final text = value.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < text.length; i++) {
    if (i > 0 && (text.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(text[i]);
  }
  return buffer.toString();
}
