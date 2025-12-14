import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  void _submitData() {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) return;

    final enteredTitle = _titleController.text;
    final enteredAmount = double.tryParse(_amountController.text);
    if (enteredAmount == null || enteredAmount <= 0) return;

    final newTx = Transaction(
      id: Uuid().v4(),
      title: enteredTitle,
      amount: enteredAmount,
      date: _selectedDate,
    );

    Provider.of<TransactionProvider>(context, listen: false).addTransaction(newTx);
    Navigator.of(context).pop();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() => _selectedDate = pickedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Transaction')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Title'),
              controller: _titleController,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Amount'),
              controller: _amountController,
              keyboardType: TextInputType.number,
            ),
            Row(
              children: [
                Text('Date: ${_selectedDate.toLocal().toString().split(' ')[0]}'),
                TextButton(onPressed: _presentDatePicker, child: Text('Choose Date'))
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _submitData, child: Text('Add Transaction')),
          ],
        ),
      ),
    );
  }
}
