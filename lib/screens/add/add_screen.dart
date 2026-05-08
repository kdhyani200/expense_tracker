import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/transaction_item.dart';
import '../../providers/transactions_providers.dart';
import '../../providers/wallet_providers.dart';
import '../../snackbar_util.dart';

class AddScreen extends ConsumerStatefulWidget {
  const AddScreen({super.key});

  @override
  ConsumerState<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends ConsumerState<AddScreen> {
  final _formKey = GlobalKey<FormState>();

  String _selectedType = 'Expense';
  String? _selectedWallet;
  String? _selectedCategory;

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> _types = ['Expense', 'Income'];

  // Categories with first letter capitalized for UI
  List<String> get _categories => ExpenseCategory.values.map((c) {
    final name = c.toString().split('.').last;
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1).toLowerCase();
  }).toList();

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400, width: .8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00885d), width: 1.3),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: .8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletsProvider);
    final List<String> walletNames = wallets.map((w) => w.name).toList();

    final screenHeight = MediaQuery.of(context).size.height;
    final labelStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    );

    return Padding(
      padding: EdgeInsets.only(top: screenHeight * 0.12),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const BackButton(color: Colors.black),
            title: const Text(
              "Add Transaction",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // TYPE DROPDOWN
                          _buildFieldLabel("Type", false, labelStyle),
                          DropdownButtonFormField<String>(
                            value: _selectedType,
                            isExpanded: true,
                            decoration: _buildInputDecoration("Select Type"),
                            items: _types
                                .map(
                                  (t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedType = val!;
                                if (_selectedType == 'Income') {
                                  _selectedCategory = null;
                                }
                              });
                            },
                          ),

                          const SizedBox(height: 20),

                          // WALLET DROPDOWN
                          _buildFieldLabel("Wallet", false, labelStyle),
                          DropdownButtonFormField<String>(
                            value: _selectedWallet,
                            isExpanded: true,
                            decoration: _buildInputDecoration("Select Wallet"),
                            items: walletNames
                                .map(
                                  (w) => DropdownMenuItem(
                                    value: w,
                                    child: Text(w),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedWallet = val),
                            validator: (val) =>
                                val == null ? "Please select a wallet" : null,
                          ),

                          // CATEGORY DROPDOWN
                          if (_selectedType == 'Expense') ...[
                            const SizedBox(height: 20),
                            _buildFieldLabel("Category", false, labelStyle),
                            DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              isExpanded: true,
                              decoration: _buildInputDecoration(
                                "Select Category",
                              ),
                              items: _categories
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedCategory = val),
                              validator: (val) =>
                                  _selectedType == 'Expense' && val == null
                                  ? "Select a category"
                                  : null,
                            ),
                          ],

                          const SizedBox(height: 20),

                          // DATE PICKER
                          _buildFieldLabel("Date", false, labelStyle),
                          TextFormField(
                            controller: _dateController,
                            readOnly: true,
                            decoration: _buildInputDecoration("Select Date")
                                .copyWith(
                                  suffixIcon: const Icon(
                                    Icons.calendar_month,
                                    size: 20,
                                  ),
                                ),
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (pickedDate != null) {
                                setState(
                                  () => _dateController.text =
                                      "${pickedDate.toLocal()}".split(' ')[0],
                                );
                              }
                            },
                            validator: (val) => val == null || val.isEmpty
                                ? "Please select a date"
                                : null,
                          ),

                          const SizedBox(height: 20),

                          // AMOUNT
                          _buildFieldLabel("Amount", false, labelStyle),
                          TextFormField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            decoration: _buildInputDecoration("0.00"),
                            validator: (val) {
                              if (val == null || val.isEmpty)
                                return "Enter an amount";
                              final amount = double.tryParse(val);
                              if (amount == null) return "Enter a valid number";
                              if (amount <= 0)
                                return "Amount must be greater than zero";
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // DESCRIPTION
                          _buildFieldLabel("Description ", true, labelStyle),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: _buildInputDecoration("Add a note..."),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),

                  // SUBMIT BUTTON
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final type = _selectedType == 'Expense'
                                ? Type.Expense
                                : Type.Income;
                            final enteredAmount = double.parse(
                              _amountController.text,
                            );

                            final selectedWalletData = wallets
                                .cast<dynamic>()
                                .firstWhere(
                                  (w) => w.name == _selectedWallet,
                                  orElse: () => null,
                                );

                            if (selectedWalletData == null) {
                              SnackBarUtils.showSnackBar(
                                context,
                                "Wallet not found!",
                                isError: true,
                              );
                              return;
                            }

                            final currentBalance = double.parse(
                              selectedWalletData.amount,
                            );

                            if (type == Type.Expense &&
                                currentBalance < enteredAmount) {
                              SnackBarUtils.showSnackBar(
                                context,
                                "Insufficient funds in $_selectedWallet!",
                                isError: true,
                              );
                              return;
                            }

                            final category = _selectedType == 'Income'
                                ? ExpenseCategory.other
                                : ExpenseCategory.values.firstWhere(
                                    (c) =>
                                        c
                                            .toString()
                                            .split('.')
                                            .last
                                            .toLowerCase() ==
                                        _selectedCategory?.toLowerCase(),
                                    orElse: () => ExpenseCategory.other,
                                  );

                            final newTransaction = Transaction(
                              type: type,
                              wallet: _selectedWallet!,
                              category: category,
                              date:
                                  DateTime.tryParse(_dateController.text) ??
                                  DateTime.now(),
                              amount: _amountController.text,
                              description: _descriptionController.text.isEmpty
                                  ? null
                                  : _descriptionController.text,
                            );

                            ref
                                .read(transactionsProvider.notifier)
                                .addTransaction(newTransaction);
                            ref
                                .read(walletsProvider.notifier)
                                .updateWalletBalance(
                                  _selectedWallet!,
                                  _amountController.text,
                                  type,
                                );

                            Navigator.pop(context);
                            SnackBarUtils.showSnackBar(
                              context,
                              "Transaction Saved!",
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00885d),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Submit",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, bool isOptional, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(text: label, style: style),
            if (isOptional)
              TextSpan(
                text: " (Optional)",
                style: style.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                  fontSize: style.fontSize! * 0.9,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
