import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:confetti/confetti.dart';

import '../providers/savings_provider.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _playConfetti() {
    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    final savingsProvider = Provider.of<SavingsProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text(
          'Savings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: savingsProvider.activeGoals.isEmpty
                      ? const Center(
                          child: Text(
                            'No savings goals yet. Start one!',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: savingsProvider.activeGoals.length,
                          itemBuilder: (context, index) {
                            final goal = savingsProvider.activeGoals[index];
                            return _goalCard(
                                context, savingsProvider, goal, index);
                          },
                        ),
                ),
                const SizedBox(height: 16),
                _addNewGoalButton(context, savingsProvider),
              ],
            ),
          ),
          // Confetti falling from the top of the screen
          Positioned.fill(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [Colors.green, Colors.orange, Colors.purple, Colors.blue],
                numberOfParticles: 30,
                gravity: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _goalCard(BuildContext context, SavingsProvider provider,
      SavingsGoal goal, int index) {
    double progress = goal.progress;

    final gradientColors = [
      [Colors.green.shade400, Colors.green.shade700],
      [Colors.orange.shade400, Colors.orange.shade700],
      [Colors.purple.shade400, Colors.purple.shade700],
      [Colors.blue.shade400, Colors.blue.shade700],
    ];
    final colors = gradientColors[index % gradientColors.length];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: goal.completed
                ? [Colors.grey.shade400, Colors.grey.shade600]
                : colors),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.savings, color: Colors.white, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  goal.title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              if (!goal.completed)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _confirmDeleteGoal(context, provider, goal),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'LKR ${goal.savedAmount.toStringAsFixed(2)} / ${goal.goalAmount.toStringAsFixed(2)}',
            style:
                const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          LinearPercentIndicator(
            lineHeight: 14,
            percent: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.white.withOpacity(0.3),
            progressColor: Colors.white,
            animation: true,
            animationDuration: 700,
            barRadius: const Radius.circular(12),
          ),
          const SizedBox(height: 12),
          if (!goal.completed)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    child:
                        const Text('Add', style: TextStyle(color: Colors.black)),
                    onPressed: () {
                      _showAddOrReduceDialog(context, provider, goal, add: true);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    child:
                        const Text('Reduce', style: TextStyle(color: Colors.black)),
                    onPressed: () {
                      _showAddOrReduceDialog(context, provider, goal, add: false);
                    },
                  ),
                ),
              ],
            ),
          if (goal.completed)
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '🎉 Completed! Proud of you!',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _addNewGoalButton(BuildContext context, SavingsProvider provider) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[700],
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
      child: const Text('Start New Savings Goal', style: TextStyle(fontSize: 16)),
      onPressed: () => _showNewGoalDialog(context, provider),
    );
  }

  void _showAddOrReduceDialog(BuildContext context, SavingsProvider provider,
      SavingsGoal goal,
      {required bool add}) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(add ? 'Add to "${goal.title}"' : 'Reduce from "${goal.title}"'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter amount'),
        ),
        actions: [
          TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop()),
          ElevatedButton(
            child: Text(add ? 'Add' : 'Reduce'),
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                if (add) {
                  provider.addToGoal(goal, amount);
                  if (goal.completed) {
                    // Play confetti from top of screen
                    _playConfetti();
                    // Show SnackBar message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🎉 Goal "${goal.title}" Completed!'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                } else {
                  provider.reduceFromGoal(goal, amount);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Shame but go on...'),
                        duration: Duration(seconds: 2)),
                  );
                }
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showNewGoalDialog(BuildContext context, SavingsProvider provider) {
    final titleController = TextEditingController();
    final goalController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Start New Savings Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Goal Title')),
            const SizedBox(height: 12),
            TextField(
              controller: goalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Goal Amount', hintText: 'Enter target amount'),
            ),
          ],
        ),
        actions: [
          TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop()),
          ElevatedButton(
            child: const Text('Create'),
            onPressed: () {
              final title = titleController.text.trim();
              final amount = double.tryParse(goalController.text);
              if (title.isNotEmpty && amount != null && amount > 0) {
                provider.addGoal(title, amount);
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter valid title and amount')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _confirmDeleteGoal(
      BuildContext context, SavingsProvider provider, SavingsGoal goal) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Goal?'),
        content: Text(
            'Are you sure you want to delete "${goal.title}"? This cannot be undone.'),
        actions: [
          TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop()),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
            onPressed: () {
              provider.removeGoal(goal);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
