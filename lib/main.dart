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
        children: const [
          LegalHeaderCard(
            title: 'GoalSprint Privacy Policy',
            subtitle:
                'This Privacy Policy explains how GoalSprint handles your information when you use the app.',
          ),
          LegalSectionCard(
            title: 'Introduction',
            body:
                'GoalSprint is designed as a simple productivity app for planning daily tasks and tracking habits. Your privacy matters, so the app is intentionally built around local storage and does not require online services to function.',
          ),
          LegalSectionCard(
            title: 'Information We Collect',
            body:
                'GoalSprint does not collect personal information such as your name, email address, phone number, location, contacts, photos, or payment details. The app only stores the task, habit, priority, completion, and app setting information that you choose to enter.',
          ),
          LegalSectionCard(
            title: 'Local Storage Only',
            body:
                'Tasks, habits, priorities, completion states, and settings are stored locally on your device using device storage. This information stays on your device unless you choose to remove the app data, uninstall the app, or use device-level backup features provided by your operating system.',
          ),
          LegalSectionCard(
            title: 'Tasks and Habits Data',
            body:
                'The titles and details you enter for tasks and habits are used only to display and manage your productivity list inside GoalSprint. You should avoid entering sensitive personal, medical, financial, legal, or confidential information into task or habit titles.',
          ),
          LegalSectionCard(
            title: 'No Account or Login',
            body:
                'GoalSprint does not provide user accounts, registration, authentication, or login. Because there is no account system, GoalSprint does not store account credentials or profile information.',
          ),
          LegalSectionCard(
            title: 'No Backend or Server',
            body:
                'GoalSprint does not send your tasks, habits, or settings to a backend server. The app does not currently provide cloud sync, remote storage, analytics dashboards, or server-side processing of your productivity data.',
          ),
          LegalSectionCard(
            title: 'No Third-Party Sharing',
            body:
                'GoalSprint does not sell, rent, trade, transfer, or share your tasks, habits, settings, or other app data with third parties. Since the app stores data locally, GoalSprint does not have access to your task or habit content.',
          ),
          LegalSectionCard(
            title: 'No Ads Currently',
            body:
                'GoalSprint does not currently display advertisements. The app does not currently use advertising SDKs or share information with advertising networks.',
          ),
          LegalSectionCard(
            title: 'No Sensitive Permissions',
            body:
                'GoalSprint does not request sensitive permissions such as location, camera, microphone, contacts, calendar, SMS, call logs, or health data permissions. If future features require permissions, they will be requested only when needed and explained in the app.',
          ),
          LegalSectionCard(
            title: 'Children’s Privacy',
            body:
                'GoalSprint is not intended to knowingly collect personal information from children. The app does not include account creation or backend collection. If a parent or guardian believes a child has entered inappropriate personal information into local task or habit data, they can delete that data directly from the device.',
          ),
          LegalSectionCard(
            title: 'Data Deletion',
            body:
                'You can delete individual tasks and habits inside the app. You can also remove locally stored GoalSprint data by clearing the app data through your device settings or uninstalling the app. Because GoalSprint does not maintain a backend account, there is no remote server data to request or delete.',
          ),
          LegalSectionCard(
            title: 'Security',
            body:
                'GoalSprint keeps data locally on your device and relies on your device’s normal security protections. You are responsible for protecting access to your device with available security features such as screen lock, passcode, biometric unlock, or device encryption.',
          ),
          LegalSectionCard(
            title: 'Changes to This Policy',
            body:
                'GoalSprint may update this Privacy Policy if the app changes, new features are added, or legal requirements change. Any updated policy should be reviewed in the app or on the app listing when made available.',
          ),
          LegalSectionCard(
            title: 'Contact',
            body:
                'If you have questions about this Privacy Policy, contact us at: contact@goalsprint.com',
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
        children: const [
          LegalHeaderCard(
            title: 'GoalSprint Terms & Conditions',
            subtitle:
                'These Terms explain the basic rules for using GoalSprint and your responsibility for local app data.',
          ),
          LegalSectionCard(
            title: 'Acceptance of Terms',
            body:
                'By downloading, installing, or using GoalSprint, you agree to these Terms & Conditions. If you do not agree with these Terms, do not use the app.',
          ),
          LegalSectionCard(
            title: 'App Purpose',
            body:
                'GoalSprint is provided as a simple productivity tool for creating tasks, tracking habits, setting priorities, and reviewing daily progress. The app is intended for general personal organization and should not be used as a substitute for professional advice or critical recordkeeping.',
          ),
          LegalSectionCard(
            title: 'User Responsibilities',
            body:
                'You are responsible for the information you enter into GoalSprint and for how you use the app. You agree not to use GoalSprint for unlawful, harmful, abusive, or misleading purposes, and you should avoid entering sensitive or confidential information into task or habit titles.',
          ),
          LegalSectionCard(
            title: 'Local Data Responsibility',
            body:
                'GoalSprint stores tasks, habits, priorities, completion states, and settings locally on your device. You are responsible for maintaining access to your device, protecting your device, and backing up any information you consider important using tools provided by your device or operating system.',
          ),
          LegalSectionCard(
            title: 'No Account, Login, or Backend',
            body:
                'GoalSprint does not currently provide accounts, login, cloud sync, or backend storage. If the app is deleted, app data is cleared, or your device is lost or reset, your locally stored GoalSprint data may be permanently lost.',
          ),
          LegalSectionCard(
            title: 'No Guarantee',
            body:
                'GoalSprint is provided on an as-is and as-available basis. We do not guarantee that the app will be uninterrupted, error-free, compatible with every device, or suitable for every purpose. Productivity results depend on how you use the app.',
          ),
          LegalSectionCard(
            title: 'Limitation of Liability',
            body:
                'To the maximum extent permitted by law, GoalSprint and its developers are not liable for indirect, incidental, special, consequential, or punitive damages, including loss of data, loss of productivity, device issues, or reliance on information stored in the app.',
          ),
          LegalSectionCard(
            title: 'Changes to the App',
            body:
                'GoalSprint may change, improve, suspend, or remove features at any time. Future versions may add new functionality, and any material changes may be reflected in updated app information, Privacy Policy, or Terms & Conditions.',
          ),
          LegalSectionCard(
            title: 'Termination',
            body:
                'You may stop using GoalSprint at any time by deleting the app from your device. We may discontinue the app or restrict access to future updates if necessary for security, legal, or operational reasons.',
          ),
          LegalSectionCard(
            title: 'Contact',
            body:
                'If you have questions about these Terms & Conditions, contact us at: contact@goalsprint.com',
          ),
        ],
      ),
    );
  }
}

class LegalHeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const LegalHeaderCard({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class LegalSectionCard extends StatelessWidget {
  final String title;
  final String body;

  const LegalSectionCard({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.45,
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
