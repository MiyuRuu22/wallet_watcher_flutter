import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  late Box<Transaction> _transactionBox;

  List<Transaction> get transactions => _transactionBox.values.toList();

  Future<void> init() async {
    _transactionBox = await Hive.openBox<Transaction>('transactions');
    notifyListeners();
  }

  void addTransaction(Transaction tx) {
    _transactionBox.add(tx);
    notifyListeners();
  }

  void deleteTransaction(int index) {
    _transactionBox.deleteAt(index);
    notifyListeners();
  }
}
