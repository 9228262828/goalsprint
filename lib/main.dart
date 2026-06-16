import 'package:flutter/material.dart';

void main() {
  runApp(const GoalSprintApp());
}

class GoalSprintApp extends StatelessWidget {
  const GoalSprintApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoalSprint',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2563EB),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

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
                    colors: [
                      Color(0xFF2563EB),
                      Color(0xFF22C55E),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.25),
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
                  color: Colors.white.withOpacity(0.72),
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
                        builder: (_) => const HomeScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<Map<String, dynamic>> tasks = const [
    {
      'title': 'Plan today’s sprint',
      'subtitle': 'High priority',
      'done': true,
    },
    {
      'title': 'Complete Flutter UI',
      'subtitle': 'Medium priority',
      'done': false,
    },
    {
      'title': 'Review daily habits',
      'subtitle': 'Low priority',
      'done': false,
    },
  ];

  final List<Map<String, dynamic>> habits = const [
    {
      'title': 'Drink water',
      'streak': '5 days',
      'icon': Icons.water_drop_rounded,
    },
    {
      'title': 'Read 10 minutes',
      'streak': '3 days',
      'icon': Icons.menu_book_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final completedTasks = tasks.where((task) => task['done'] == true).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Today’s Sprint',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
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
                colors: [
                  Color(0xFF2563EB),
                  Color(0xFF22C55E),
                ],
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
                  '$completedTasks of ${tasks.length} tasks completed',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: completedTasks / tasks.length,
                    minHeight: 10,
                    backgroundColor: Colors.white.withOpacity(0.25),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const SectionTitle(title: 'Tasks'),
          const SizedBox(height: 12),
          ...tasks.map(
                (task) => TaskTile(
              title: task['title'],
              subtitle: task['subtitle'],
              done: task['done'],
            ),
          ),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Habits'),
          const SizedBox(height: 12),
          ...habits.map(
                (habit) => HabitTile(
              title: habit['title'],
              streak: habit['streak'],
              icon: habit['icon'],
            ),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({
    super.key,
    required this.title,
  });

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

  const TaskTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                    color: Colors.grey.shade600,
                    fontSize: 13,
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

class HabitTile extends StatelessWidget {
  final String title;
  final String streak;
  final IconData icon;

  const HabitTile({
    super.key,
    required this.title,
    required this.streak,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
            child: Icon(
              icon,
              color: const Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            streak,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}