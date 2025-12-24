import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../providers/savings_provider.dart';
import 'transactions_screen.dart';
import 'savings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final txProvider = Provider.of<TransactionProvider>(context);
    final savings = Provider.of<SavingsProvider>(context);

    DateTime now = DateTime.now();

    // Total Expenses
    double totalExpenses =
        txProvider.transactions.fold(0, (sum, tx) => sum + tx.amount);

    // Weekly Expenses
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    double weeklyExpenses = txProvider.transactions
        .where((tx) => tx.date.isAfter(startOfWeek))
        .fold(0, (sum, tx) => sum + tx.amount);

    // Monthly Expenses
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    double monthlyExpenses = txProvider.transactions
        .where((tx) => tx.date.isAfter(startOfMonth))
        .fold(0, (sum, tx) => sum + tx.amount);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          'WalletBuddy',
          style: TextStyle(
            color: Colors.teal[800],
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _summaryCard(
              title: 'Total Expenses',
              total: totalExpenses,
              weekly: weeklyExpenses,
              monthly: monthlyExpenses,
            ),
            const SizedBox(height: 16),
            _savingsOverviewCard(savings),
            const SizedBox(height: 30),

            // Navigation buttons
            Row(
              children: [
                Expanded(
                  child: _navButton(
                    context,
                    icon: Icons.receipt_long,
                    label: 'Transactions',
                    color: Colors.teal,
                    screen: const TransactionsScreen(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _navButton(
                    context,
                    icon: Icons.savings,
                    label: 'Savings',
                    color: Colors.green,
                    screen: const SavingsScreen(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Expenses Summary Card
  Widget _summaryCard({
    required String title,
    required double total,
    required double weekly,
    required double monthly,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withOpacity(0.3), width: 1.5),
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
          const SizedBox(height: 8),
          Text(
            'LKR ${total.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 22,
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'This week: LKR ${weekly.toStringAsFixed(2)}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(
            'This month: LKR ${monthly.toStringAsFixed(2)}',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // Savings Overview Card
  Widget _savingsOverviewCard(SavingsProvider savings) {
    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Savings Progress',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'LKR ${savings.savedAmount.toStringAsFixed(2)} / ${savings.goal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: savings.progress,
            backgroundColor: Colors.green[100],
            color: Colors.green,
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  // Navigation Button
  Widget _navButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required Widget screen,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 18),
        elevation: 2,
      ),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => screen),
        );
      },
      child: Column(
        children: [
          Icon(icon, size: 28, color: Colors.white),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
