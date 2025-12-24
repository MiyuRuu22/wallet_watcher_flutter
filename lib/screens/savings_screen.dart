import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/savings_provider.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final savings = Provider.of<SavingsProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Savings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _savingsOverviewCard(savings),
            const SizedBox(height: 24),

            if (savings.goal == 0)
              _setGoalButton(context, savings)
            else
              _addSavingsButton(context, savings),
          ],
        ),
      ),
    );
  }

  // Savings Overview Card
  Widget _savingsOverviewCard(SavingsProvider savings) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Savings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'LKR ${savings.savedAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Goal: LKR ${savings.goal.toStringAsFixed(2)}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: savings.progress,
            backgroundColor: Colors.green[100],
            color: Colors.green,
            minHeight: 10,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(savings.progress * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Button when goal not set
  Widget _setGoalButton(BuildContext context, SavingsProvider savings) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
      child: const Text(
        'Set Savings Goal',
        style: TextStyle(fontSize: 16),
      ),
      onPressed: () => _showSetGoalDialog(context, savings),
    );
  }

  // Button when goal exists
  Widget _addSavingsButton(BuildContext context, SavingsProvider savings) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
      child: const Text(
        'Add Savings',
        style: TextStyle(fontSize: 16),
      ),
      onPressed: () => _showAddSavingsDialog(context, savings),
    );
  }

  // Add Savings Dialog
  void _showAddSavingsDialog(BuildContext context, SavingsProvider savings) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Savings'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Enter amount',
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('Add'),
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                savings.addSavings(amount);
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  // Set Goal Dialog
  void _showSetGoalDialog(BuildContext context, SavingsProvider savings) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Set Savings Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 12,
              children: [
                _goalButton(context, savings, 5000),
                _goalButton(context, savings, 10000),
                _goalButton(context, savings, 15000),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Custom Goal (max 1,000,000 LKR)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('Set Goal'),
            onPressed: () {
              final customGoal = double.tryParse(controller.text);
              if (customGoal != null &&
                  customGoal > 0 &&
                  customGoal <= 1000000) {
                savings.setGoal(customGoal);
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Enter a valid amount up to 1,000,000 LKR'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Predefined goal button
  Widget _goalButton(
      BuildContext context, SavingsProvider savings, double amount) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[300],
        elevation: 0,
      ),
      child: Text('LKR ${amount.toStringAsFixed(0)}'),
      onPressed: () {
        savings.setGoal(amount);
        Navigator.of(context).pop();
      },
    );
  }
}
