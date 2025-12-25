import 'package:flutter/material.dart';

// Model for a savings goal
class SavingsGoal {
  String title;
  double goalAmount;
  double savedAmount;
  bool completed;

  SavingsGoal({
    required this.title,
    required this.goalAmount,
    this.savedAmount = 0,
    this.completed = false,
  });

  double get progress => (savedAmount / goalAmount).clamp(0.0, 1.0);
}

class SavingsProvider with ChangeNotifier {
  // Active goals
  List<SavingsGoal> _activeGoals = [];

  // Completed goals (for achievements, history, etc.)
  List<SavingsGoal> _completedGoals = [];

  List<SavingsGoal> get activeGoals => _activeGoals;
  List<SavingsGoal> get completedGoals => _completedGoals;

  // Add a new savings goal
  void addGoal(String title, double amount) {
    _activeGoals.add(SavingsGoal(title: title, goalAmount: amount));
    notifyListeners();
  }

  // Add money to a goal
  void addToGoal(SavingsGoal goal, double amount) {
    final index = _activeGoals.indexOf(goal);
    if (index == -1) return;

    _activeGoals[index].savedAmount += amount;

    // Check if goal completed
    if (_activeGoals[index].savedAmount >= _activeGoals[index].goalAmount) {
      _activeGoals[index].completed = true;
      _completedGoals.add(_activeGoals[index]);
      _activeGoals.removeAt(index);
      // TODO: Trigger achievement/animation here
    }

    notifyListeners();
  }

  // Reduce money from a goal
  void reduceFromGoal(SavingsGoal goal, double amount) {
    final index = _activeGoals.indexOf(goal);
    if (index == -1) return;

    _activeGoals[index].savedAmount -= amount;
    if (_activeGoals[index].savedAmount < 0) {
      _activeGoals[index].savedAmount = 0;
    }

    notifyListeners();
  }

  // Remove a goal completely
  void removeGoal(SavingsGoal goal) {
    _activeGoals.remove(goal);
    notifyListeners();
  }
}
