import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/savings_provider.dart';
import '../models/transaction.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final txProvider = Provider.of<TransactionProvider>(context);
    final savings = Provider.of<SavingsProvider>(context);

    DateTime now = DateTime.now();

    // Total Expenses
    double totalExpenses = txProvider.transactions.fold(
      0,
      (sum, tx) => sum + tx.amount,
    );

    // Last Week Expenses
    DateTime startOfThisWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime startOfLastWeek = startOfThisWeek.subtract(const Duration(days: 7));
    DateTime endOfLastWeek = startOfThisWeek.subtract(const Duration(days: 1));

    double lastWeekExpenses = txProvider.transactions
        .where((tx) =>
            tx.date.isAfter(startOfLastWeek.subtract(const Duration(seconds: 1))) &&
            tx.date.isBefore(endOfLastWeek.add(const Duration(days: 1))))
        .fold(0, (sum, tx) => sum + tx.amount);

    // Last Month Expenses
    DateTime startOfThisMonth = DateTime(now.year, now.month, 1);
    DateTime startOfLastMonth =
        DateTime(startOfThisMonth.year, startOfThisMonth.month - 1, 1);
    DateTime endOfLastMonth = startOfThisMonth.subtract(const Duration(days: 1));

    double lastMonthExpenses = txProvider.transactions
        .where((tx) =>
            tx.date.isAfter(startOfLastMonth.subtract(const Duration(seconds: 1))) &&
            tx.date.isBefore(endOfLastMonth.add(const Duration(days: 1))))
        .fold(0, (sum, tx) => sum + tx.amount);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          'Wallet Watcher',
          style: TextStyle(
            color: Colors.teal[800],
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.teal[800]),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => AddTransactionScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top Summary stacked vertically
            Column(
              children: [
                _summaryCard(
                  'You spent this much so far:',
                  totalExpenses,
                  Colors.redAccent,
                  weekly: lastWeekExpenses,
                  monthly: lastMonthExpenses,
                ),
                const SizedBox(height: 16),
                _savingsCard(savings, context),
              ],
            ),
            const SizedBox(height: 20),

            // Transaction List
            Expanded(
              child: txProvider.transactions.isEmpty
                  ? Center(
                      child: Text(
                        'No transactions yet',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: txProvider.transactions.length,
                      itemBuilder: (ctx, index) {
                        Transaction tx = txProvider.transactions[index];
                        return _transactionCard(tx);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => AddTransactionScreen()),
          );
        },
        backgroundColor: Colors.teal[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Summary Card with last week/month
  Widget _summaryCard(String title, double totalAmount, Color color,
      {double? weekly, double? monthly}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
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
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'LKR ${totalAmount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 20,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (weekly != null || monthly != null) ...[
            const SizedBox(height: 8),
            if (weekly != null)
              Text('Last week you spent: LKR ${weekly.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            if (monthly != null)
              Text('Last month you spent: LKR ${monthly.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ],
        ],
      ),
    );
  }

  // Transaction Card
  Widget _transactionCard(Transaction tx) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          tx.title,
          style:
              TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          tx.date.toLocal().toString().split(' ')[0],
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Text(
          'LKR ${tx.amount.toStringAsFixed(2)}',
          style:
              const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Savings Card
  Widget _savingsCard(SavingsProvider savings, BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        children: [
          Text(
            'Savings Goal',
            style: TextStyle(
                fontSize: 16, color: Colors.grey[700], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Text(
            'LKR ${savings.savedAmount.toStringAsFixed(2)} / ${savings.goal.toStringAsFixed(2)}',
            style: const TextStyle(
                fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: savings.progress,
            backgroundColor: Colors.green[100],
            color: Colors.green,
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[400], elevation: 0),
            child: Text(savings.goal == 0 ? 'Set Goal' : 'Add Savings'),
            onPressed: () {
              if (savings.goal == 0) {
                _showSetGoalDialog(context, savings);
              } else {
                _showAddSavingsDialog(context, savings);
              }
            },
          ),
        ],
      ),
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
          decoration: const InputDecoration(hintText: 'Enter amount'),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('Add'),
            onPressed: () {
              double? amount = double.tryParse(controller.text);
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
    double? customGoal;
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
            child: const Text('Set Custom Goal'),
            onPressed: () {
              customGoal = double.tryParse(controller.text);
              if (customGoal != null && customGoal! > 0 && customGoal! <= 1000000) {
                savings.setGoal(customGoal!);
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Enter a valid amount up to 1,000,000 LKR'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Predefined Goal Buttons
  Widget _goalButton(BuildContext context, SavingsProvider savings, double amount) {
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
