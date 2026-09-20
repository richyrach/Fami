import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final List<_Announcement> _items = [
    _Announcement(
      title: "Dinner at Grandma's",
      body: "Tonight at 7:30 PM. Everyone is invited.",
      author: 'Masoumeh',
      priority: 'Normal',
      seen: '2/3',
      pinned: true,
    ),
    _Announcement(
      title: 'Family documents',
      body: 'Please check the shared files before the weekend.',
      author: 'Mohammad',
      priority: 'Normal',
      seen: '1/3',
    ),
  ];

  Future<void> _create() async {
    final created = await Navigator.of(context).push<CreatedItem>(
      MaterialPageRoute(
        builder: (_) => const CreateItemScreen(type: 'Announcement'),
      ),
    );
    if (created == null) return;
    setState(() {
      _items.insert(
        0,
        _Announcement(
          title: created.title,
          body: created.details,
          author: 'Mahdiar',
          priority: created.important ? 'Important' : 'Normal',
          seen: '0/3',
          pinned: created.important,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return _Page(
      title: 'Announcements',
      subtitle: 'Important things should not get buried in chat.',
      action: IconButton(
        onPressed: _create,
        icon: const Icon(Icons.add_rounded),
      ),
      children: [
        for (final item in _items) ...[
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (item.pinned) ...[
                      const Icon(Icons.push_pin_outlined, size: 17),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      item.priority,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(item.body, style: const TextStyle(height: 1.35)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      'By ${item.author}',
                      style: _secondaryStyle(context),
                    ),
                    const Spacer(),
                    Text(
                      'Seen ${item.seen}',
                      style: _secondaryStyle(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final List<_FamilyEvent> _events = [
    _FamilyEvent(
      title: 'Dentist — Mom',
      when: 'Today · 16:00',
      place: 'City Dental Clinic',
      people: 'Masoumeh',
    ),
    _FamilyEvent(
      title: "Grandma's house",
      when: 'Today · 19:30',
      place: 'Family visit',
      people: 'Everyone',
    ),
    _FamilyEvent(
      title: "Pendar's birthday",
      when: 'Dec 3 · All day',
      place: 'Family',
      people: 'Everyone',
    ),
  ];

  Future<void> _create() async {
    final created = await Navigator.of(context).push<CreatedItem>(
      MaterialPageRoute(
        builder: (_) => const CreateItemScreen(type: 'Event'),
      ),
    );
    if (created == null) return;
    setState(() {
      _events.insert(
        0,
        _FamilyEvent(
          title: created.title,
          when: created.dateText.isEmpty ? 'Date not set' : created.dateText,
          place: created.details.isEmpty ? 'No location' : created.details,
          people: 'Family',
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return _Page(
      title: 'Events',
      subtitle: 'Shared plans, appointments and family dates.',
      action: IconButton(
        onPressed: _create,
        icon: const Icon(Icons.add_rounded),
      ),
      children: [
        _Panel(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (int i = 0; i < _events.length; i++) ...[
                ListTile(
                  minTileHeight: 74,
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: Text(
                    _events[i].title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${_events[i].when}\n${_events[i].place} · ${_events[i].people}',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
                if (i != _events.length - 1)
                  const Divider(height: 1, indent: 56),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  final List<_Memory> _memories = [
    _Memory(
      title: 'A family day',
      date: 'Sep 14, 2026',
      note: 'Shared by the family',
      icon: Icons.favorite_border_rounded,
    ),
    _Memory(
      title: 'Weekend together',
      date: 'Aug 28, 2026',
      note: '4 items',
      icon: Icons.photo_library_outlined,
    ),
  ];

  Future<void> _create() async {
    final created = await Navigator.of(context).push<CreatedItem>(
      MaterialPageRoute(
        builder: (_) => const CreateItemScreen(type: 'Memory'),
      ),
    );
    if (created == null) return;
    setState(() {
      _memories.insert(
        0,
        _Memory(
          title: created.title,
          date: created.dateText.isEmpty ? 'Today' : created.dateText,
          note: created.details.isEmpty ? 'New memory' : created.details,
          icon: Icons.favorite_border_rounded,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return _Page(
      title: 'Memories',
      subtitle: 'Photos, stories and moments you choose to keep together.',
      action: IconButton(
        onPressed: _create,
        icon: const Icon(Icons.add_rounded),
      ),
      children: [
        _Panel(
          child: Row(
            children: [
              const Icon(Icons.history_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'On this day',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Nothing from previous years yet.',
                      style: _secondaryStyle(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        for (final memory in _memories) ...[
          _Panel(
            child: Row(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: _neutralFill(context),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(memory.icon),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        memory.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(memory.date),
                      const SizedBox(height: 2),
                      Text(
                        memory.note,
                        style: _secondaryStyle(context),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class FilesScreen extends StatelessWidget {
  const FilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _Page(
      title: 'Files',
      subtitle: 'Documents deliberately shared with the family.',
      children: [
        _Panel(
          padding: EdgeInsets.zero,
          child: Column(
            children: const [
              ListTile(
                leading: Icon(Icons.folder_outlined),
                title: Text('Family documents'),
                subtitle: Text('No files yet'),
                trailing: Icon(Icons.chevron_right_rounded),
              ),
              Divider(height: 1, indent: 56),
              ListTile(
                leading: Icon(Icons.receipt_long_outlined),
                title: Text('Receipts'),
                subtitle: Text('No files yet'),
                trailing: Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ListsScreen extends StatefulWidget {
  const ListsScreen({super.key});

  @override
  State<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends State<ListsScreen> {
  final List<_TaskItem> _items = [
    _TaskItem('Buy milk', false),
    _TaskItem('Check Google One renewal', false),
    _TaskItem('Call Grandma', true),
  ];

  Future<void> _add() async {
    final created = await Navigator.of(context).push<CreatedItem>(
      MaterialPageRoute(
        builder: (_) => const CreateItemScreen(type: 'Task'),
      ),
    );
    if (created == null) return;
    setState(() => _items.insert(0, _TaskItem(created.title, false)));
  }

  @override
  Widget build(BuildContext context) {
    return _Page(
      title: 'Lists',
      subtitle: 'Shopping, chores and small family tasks.',
      action: IconButton(
        onPressed: _add,
        icon: const Icon(Icons.add_rounded),
      ),
      children: [
        _Panel(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (int i = 0; i < _items.length; i++) ...[
                CheckboxListTile(
                  title: Text(
                    _items[i].label,
                    style: TextStyle(
                      decoration:
                          _items[i].done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  value: _items[i].done,
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                    setState(() => _items[i].done = value ?? false);
                  },
                ),
                if (i != _items.length - 1)
                  const Divider(height: 1, indent: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class CreateItemScreen extends StatefulWidget {
  const CreateItemScreen({super.key, required this.type});

  final String type;

  @override
  State<CreateItemScreen> createState() => _CreateItemScreenState();
}

class _CreateItemScreenState extends State<CreateItemScreen> {
  final _title = TextEditingController();
  final _details = TextEditingController();
  final _date = TextEditingController();
  bool _important = false;

  @override
  void dispose() {
    _title.dispose();
    _details.dispose();
    _date.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final needsDate = widget.type == 'Event' || widget.type == 'Memory';
    return Scaffold(
      appBar: AppBar(
        title: Text('New ${widget.type}'),
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: _title.text.trim().isEmpty ? null : _save,
            child: const Text('Add'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
        children: [
          _Panel(
            child: Column(
              children: [
                TextField(
                  controller: _title,
                  onChanged: (_) => setState(() {}),
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: '${widget.type} title',
                    border: InputBorder.none,
                  ),
                ),
                const Divider(height: 1),
                TextField(
                  controller: _details,
                  minLines: 2,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Details',
                    border: InputBorder.none,
                  ),
                ),
                if (needsDate) ...[
                  const Divider(height: 1),
                  TextField(
                    controller: _date,
                    decoration: const InputDecoration(
                      labelText: 'Date / time',
                      hintText: 'e.g. Oct 12 · 19:30',
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (widget.type == 'Announcement') ...[
            const SizedBox(height: 14),
            _Panel(
              padding: EdgeInsets.zero,
              child: SwitchListTile.adaptive(
                title: const Text('Important'),
                subtitle: const Text('Keep this visible until acknowledged'),
                value: _important,
                onChanged: (value) => setState(() => _important = value),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _save() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop(
      CreatedItem(
        title: _title.text.trim(),
        details: _details.text.trim(),
        dateText: _date.text.trim(),
        important: _important,
      ),
    );
  }
}

class CreatedItem {
  const CreatedItem({
    required this.title,
    required this.details,
    required this.dateText,
    required this.important,
  });

  final String title;
  final String details;
  final String dateText;
  final bool important;
}

class _Page extends StatelessWidget {
  const _Page({
    required this.title,
    required this.subtitle,
    required this.children,
    this.action,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        actions: action == null ? null : [action!],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        children: [
          Text(subtitle, style: _secondaryStyle(context)),
          const SizedBox(height: 18),
          ...children,
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
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

TextStyle _secondaryStyle(BuildContext context) => TextStyle(
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF98989D)
          : const Color(0xFF6E6E73),
      fontSize: 13,
    );

Color _neutralFill(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFF0F0F2);

class _Announcement {
  _Announcement({
    required this.title,
    required this.body,
    required this.author,
    required this.priority,
    required this.seen,
    this.pinned = false,
  });

  final String title;
  final String body;
  final String author;
  final String priority;
  final String seen;
  final bool pinned;
}

class _FamilyEvent {
  _FamilyEvent({
    required this.title,
    required this.when,
    required this.place,
    required this.people,
  });

  final String title;
  final String when;
  final String place;
  final String people;
}

class _Memory {
  _Memory({
    required this.title,
    required this.date,
    required this.note,
    required this.icon,
  });

  final String title;
  final String date;
  final String note;
  final IconData icon;
}

class _TaskItem {
  _TaskItem(this.label, this.done);

  final String label;
  bool done;
}
