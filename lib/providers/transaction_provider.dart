import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  final Box<Transaction> _transactionBox =
      Hive.box<Transaction>('transactions');

  List<Transaction> get transactions =>
      _transactionBox.values.toList();

  void addTransaction(Transaction tx) {
    _transactionBox.add(tx);
    notifyListeners();
  }

  void deleteTransaction(int index) {
    _transactionBox.deleteAt(index);
    notifyListeners();
  }
}
