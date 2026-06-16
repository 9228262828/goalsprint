import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const GoalSprintApp());
}

enum GoalItemType { task, habit }

enum GoalPriority { low, medium, high }

extension GoalItemTypeLabel on GoalItemType {
  String get label {
    switch (this) {
      case GoalItemType.task:
        return 'Task';
      case GoalItemType.habit:
        return 'Habit';
    }
  }

  IconData get icon {
    switch (this) {
      case GoalItemType.task:
        return Icons.check_circle_rounded;
      case GoalItemType.habit:
        return Icons.auto_awesome_rounded;
    }
  }
}

extension GoalPriorityLabel on GoalPriority {
  String get label {
    switch (this) {
      case GoalPriority.low:
        return 'Low';
      case GoalPriority.medium:
        return 'Medium';
      case GoalPriority.high:
        return 'High';
    }
  }

  String get subtitle => '$label priority';
}

class GoalItem {
  GoalItem({
    required this.title,
    required this.priority,
    required this.type,
    this.done = false,
    this.streak,
  });

  final String title;
  final GoalPriority priority;
  final GoalItemType type;
  final String? streak;
  bool done;

  factory GoalItem.fromJson(
    Map<String, dynamic> json, {
    required GoalItemType fallbackType,
  }) {
    return GoalItem(
      title: json['title'] as String? ?? '',
      priority: _goalPriorityFromName(json['priority'] as String?),
      type: _goalItemTypeFromName(json['type'] as String?, fallbackType),
      done: json['done'] == true,
      streak: json['streak'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'priority': priority.name,
      'type': type.name,
      'done': done,
      'streak': streak,
    };
  }
}

GoalItemType _goalItemTypeFromName(String? name, GoalItemType fallback) {
  for (final type in GoalItemType.values) {
    if (type.name == name) {
      return type;
    }
  }

  return fallback;
}

GoalPriority _goalPriorityFromName(String? name) {
  for (final priority in GoalPriority.values) {
    if (priority.name == name) {
      return priority;
    }
  }

  return GoalPriority.medium;
}

class GoalSprintApp extends StatefulWidget {
  const GoalSprintApp({super.key});

  @override
  State<GoalSprintApp> createState() => _GoalSprintAppState();
}

class _GoalSprintAppState extends State<GoalSprintApp> {
  bool _darkMode = false;

  void _setDarkMode(bool value) {
    setState(() {
      _darkMode = value;
    });
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorSchemeSeed: const Color(0xFF2563EB),
      scaffoldBackgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      cardColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark
            ? const Color(0xFF0F172A)
            : const Color(0xFFF8FAFC),
        foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
        elevation: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoalSprint',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      home: SplashScreen(onDarkModeChanged: _setDarkMode),
    );
  }
}

class SplashScreen extends StatelessWidget {
  final ValueChanged<bool> onDarkModeChanged;

  const SplashScreen({super.key, required this.onDarkModeChanged});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 118,
                height: 118,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF22C55E)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.25),
                      blurRadius: 35,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.track_changes_rounded,
                  color: Colors.white,
                  size: 62,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'GoalSprint',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Small steps. Big goals.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            HomeScreen(onDarkModeChanged: onDarkModeChanged),
                      ),
                    );
                  },
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final ValueChanged<bool> onDarkModeChanged;

  const HomeScreen({super.key, required this.onDarkModeChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _tasksStorageKey = 'goalsprint_tasks';
  static const String _habitsStorageKey = 'goalsprint_habits';

  List<GoalItem> _tasks = [
    GoalItem(
      title: 'Plan today’s sprint',
      priority: GoalPriority.high,
      type: GoalItemType.task,
      done: true,
    ),
    GoalItem(
      title: 'Complete Flutter UI',
      priority: GoalPriority.medium,
      type: GoalItemType.task,
    ),
    GoalItem(
      title: 'Review daily habits',
      priority: GoalPriority.low,
      type: GoalItemType.task,
    ),
  ];

  List<GoalItem> _habits = [
    GoalItem(
      title: 'Drink water',
      priority: GoalPriority.low,
      type: GoalItemType.habit,
      streak: '5 days',
    ),
    GoalItem(
      title: 'Read 10 minutes',
      priority: GoalPriority.medium,
      type: GoalItemType.habit,
      streak: '3 days',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final preferences = await SharedPreferences.getInstance();
    final savedTasks = preferences.getString(_tasksStorageKey);
    final savedHabits = preferences.getString(_habitsStorageKey);

    if (!mounted) {
      return;
    }

    setState(() {
      if (savedTasks != null) {
        _tasks = _decodeItems(savedTasks, GoalItemType.task);
      }

      if (savedHabits != null) {
        _habits = _decodeItems(savedHabits, GoalItemType.habit);
      }
    });
  }

  List<GoalItem> _decodeItems(String encodedItems, GoalItemType type) {
    try {
      final decodedItems = jsonDecode(encodedItems);

      if (decodedItems is! List) {
        return [];
      }

      final items = <GoalItem>[];

      for (final decodedItem in decodedItems) {
        if (decodedItem is! Map) {
          continue;
        }

        final item = GoalItem.fromJson(
          Map<String, dynamic>.from(decodedItem),
          fallbackType: type,
        );

        if (item.type == type && item.title.trim().isNotEmpty) {
          items.add(item);
        }
      }

      return items;
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveItems() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      _tasksStorageKey,
      jsonEncode(_tasks.map((task) => task.toJson()).toList()),
    );
    await preferences.setString(
      _habitsStorageKey,
      jsonEncode(_habits.map((habit) => habit.toJson()).toList()),
    );
  }

  Future<void> _openAddItemScreen() async {
    final item = await Navigator.push<GoalItem>(
      context,
      MaterialPageRoute(builder: (_) => const AddItemScreen()),
    );

    if (!mounted || item == null) {
      return;
    }

    setState(() {
      if (item.type == GoalItemType.task) {
        _tasks.add(item);
      } else {
        _habits.add(item);
      }
    });
    unawaited(_saveItems());
  }

  void _openSettingsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          darkMode: Theme.of(context).brightness == Brightness.dark,
          onDarkModeChanged: widget.onDarkModeChanged,
        ),
      ),
    );
  }

  void _toggleTask(GoalItem task) {
    setState(() {
      task.done = !task.done;
    });
    unawaited(_saveItems());
  }

  void _deleteTask(GoalItem task) {
    setState(() {
      _tasks.remove(task);
    });
    unawaited(_saveItems());
    _showDeletedMessage(task.title);
  }

  void _deleteHabit(GoalItem habit) {
    setState(() {
      _habits.remove(habit);
    });
    unawaited(_saveItems());
    _showDeletedMessage(habit.title);
  }

  void _showDeletedMessage(String title) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title deleted'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedTasks = _tasks.where((task) => task.done).length;
    final progress = _tasks.isEmpty ? 0.0 : completedTasks / _tasks.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Today’s Sprint',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: _openSettingsScreen,
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddItemScreen,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF22C55E)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$completedTasks of ${_tasks.length} tasks completed',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const SectionTitle(title: 'Tasks'),
          const SizedBox(height: 12),
          if (_tasks.isEmpty)
            const EmptyStateText(
              message: 'No tasks yet. Tap Add to create one.',
            )
          else
            ..._tasks.map(
              (task) => Dismissible(
                key: ObjectKey(task),
                background: const DeleteBackground(),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => _deleteTask(task),
                child: TaskTile(
                  title: task.title,
                  subtitle: task.priority.subtitle,
                  done: task.done,
                  onToggle: () => _toggleTask(task),
                  onLongPress: () => _deleteTask(task),
                ),
              ),
            ),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Habits'),
          const SizedBox(height: 12),
          if (_habits.isEmpty)
            const EmptyStateText(
              message: 'No habits yet. Tap Add to create one.',
            )
          else
            ..._habits.map(
              (habit) => Dismissible(
                key: ObjectKey(habit),
                background: const DeleteBackground(),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => _deleteHabit(habit),
                child: HabitTile(
                  title: habit.title,
                  subtitle: habit.streak == null
                      ? habit.priority.subtitle
                      : '${habit.streak} - ${habit.priority.subtitle}',
                  icon: habit.type.icon,
                  onLongPress: () => _deleteHabit(habit),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final TextEditingController _titleController = TextEditingController();
  GoalItemType _type = GoalItemType.task;
  GoalPriority _priority = GoalPriority.medium;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _saveItem() {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      GoalItem(title: title, priority: _priority, type: _type),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Item',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'What are you adding?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                SegmentedButton<GoalItemType>(
                  segments: GoalItemType.values
                      .map(
                        (type) => ButtonSegment<GoalItemType>(
                          value: type,
                          icon: Icon(type.icon),
                          label: Text(type.label),
                        ),
                      )
                      .toList(),
                  selected: {_type},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _type = selection.first;
                    });
                  },
                ),
                const SizedBox(height: 22),
                TextField(
                  controller: _titleController,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _saveItem(),
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter a task or habit',
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                DropdownButtonFormField<GoalPriority>(
                  initialValue: _priority,
                  decoration: InputDecoration(
                    labelText: 'Priority',
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: GoalPriority.values
                      .map(
                        (priority) => DropdownMenuItem<GoalPriority>(
                          value: priority,
                          child: Text(priority.label),
                        ),
                      )
                      .toList(),
                  onChanged: (priority) {
                    if (priority == null) {
                      return;
                    }

                    setState(() {
                      _priority = priority;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 56,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: _saveItem,
              child: const Text(
                'Save',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;

  const SettingsScreen({
    super.key,
    required this.darkMode,
    required this.onDarkModeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _darkMode;

  @override
  void initState() {
    super.initState();
    _darkMode = widget.darkMode;
  }

  void _openPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
    );
  }

  void _openTermsConditions() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TermsConditionsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: SwitchListTile(
              value: _darkMode,
              onChanged: (value) {
                setState(() {
                  _darkMode = value;
                });
                widget.onDarkModeChanged(value);
              },
              secondary: const Icon(Icons.dark_mode_rounded),
              title: const Text(
                'Dark mode',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: const Text('Switch the app to a darker theme.'),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip_rounded),
                  title: const Text(
                    'Privacy Policy',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _openPrivacyPolicy,
                ),
                Divider(
                  height: 1,
                  indent: 56,
                  color: Theme.of(context).dividerColor,
                ),
                ListTile(
                  leading: const Icon(Icons.description_rounded),
                  title: const Text(
                    'Terms & Conditions',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _openTermsConditions,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GoalSprint',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Version: 1.0.0',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 18),
                Text(
                  'About',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 8),
                Text(
                  'GoalSprint helps you plan simple daily sprints, finish tasks, '
                  'and build habits with a lightweight local workflow.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GoalSprint Privacy Policy',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'GoalSprint stores your tasks, habits, and settings locally '
                  'on your device.',
                ),
                SizedBox(height: 12),
                Text('GoalSprint does not use accounts, login, or a backend.'),
                SizedBox(height: 12),
                Text('GoalSprint does not share your data with third parties.'),
                SizedBox(height: 12),
                Text('GoalSprint does not show ads for now.'),
                SizedBox(height: 12),
                Text('GoalSprint does not request sensitive permissions.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GoalSprint Terms & Conditions',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'GoalSprint is a simple local productivity app for tracking '
                  'tasks and habits.',
                ),
                SizedBox(height: 12),
                Text(
                  'Your data is stored locally on your device. GoalSprint does '
                  'not provide an account, login, or backend sync.',
                ),
                SizedBox(height: 12),
                Text(
                  'GoalSprint does not share data with third parties and does '
                  'not show ads for now.',
                ),
                SizedBox(height: 12),
                Text('GoalSprint does not request sensitive permissions.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DeleteBackground extends StatelessWidget {
  const DeleteBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: Colors.red.shade500,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Icon(Icons.delete_rounded, color: Colors.white),
    );
  }
}

class EmptyStateText extends StatelessWidget {
  final String message;

  const EmptyStateText({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
      ),
    );
  }
}

class TaskTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool done;
  final VoidCallback onToggle;
  final VoidCallback onLongPress;

  const TaskTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.done,
    required this.onToggle,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Icon(
              done
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: done ? const Color(0xFF22C55E) : Colors.grey,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HabitTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onLongPress;

  const HabitTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.1),
              child: Icon(icon, color: const Color(0xFF2563EB)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
