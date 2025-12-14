import 'package:flutter/foundation.dart';

class SavingsProvider with ChangeNotifier {
  double _goal = 0;
  double _savedAmount = 0;

  // Getters
  double get goal => _goal;
  double get savedAmount => _savedAmount;

  // Progress as 0.0 - 1.0
  double get progress => _goal == 0 ? 0 : _savedAmount / _goal;

  // Set a new goal (resets saved amount)
  void setGoal(double newGoal) {
    if (newGoal < 0) return;
    _goal = newGoal;
    _savedAmount = 0;
    notifyListeners();
  }

  // Add amount to saved
  void addSavings(double amount) {
    if (amount <= 0) return;
    _savedAmount += amount;
    if (_savedAmount > _goal) _savedAmount = _goal; // cap at goal
    notifyListeners();
  }

  // Reset savings
  void resetSavings() {
    _savedAmount = 0;
    notifyListeners();
  }
}
