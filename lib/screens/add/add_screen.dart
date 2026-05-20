import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/transaction_model.dart';
import '../../providers/transactions_providers.dart';
import '../../providers/category_provider.dart';
import '../../providers/wallet_providers.dart';
import '../../snackbar_util.dart';

class AddScreen extends ConsumerStatefulWidget {
  /// Pass an existing transaction to open in edit / update mode.
  /// Leave null to open in add mode.
  final TransactionModel? existing;

  const AddScreen({super.key, this.existing});

  @override
  ConsumerState<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends ConsumerState<AddScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _selectedType;
  late String? _selectedWalletId;
  late String? _selectedCategory;

  late final TextEditingController _dateController;
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;

  bool get _isEditMode => widget.existing != null;

  final List<String> _types = ['Expense', 'Income'];

  // ── Date Format Pattern ────────────────────────────────────────────────────
  final _dateTimeFormat = DateFormat('dd/MM/yyyy h:mm a');

  @override
  void initState() {
    super.initState();
    final tx = widget.existing;

    if (tx != null) {
      // ── Edit mode: pre-fill from existing transaction ─────────────────────
      _selectedType = tx.type == TransactionType.income ? 'Income' : 'Expense';
      _selectedWalletId = tx.walletId;
      _selectedCategory = tx.category;
      _dateController = TextEditingController(
        text: _dateTimeFormat.format(tx.date),
      );
      _amountController = TextEditingController(
        text: tx.amount.toStringAsFixed(2),
      );
      _descriptionController = TextEditingController(text: tx.note);
    } else {
      // ── Add mode: start blank ─────────────────────────────────────────────
      _selectedType = 'Expense';
      _selectedWalletId = null;
      _selectedCategory = null;
      _dateController = TextEditingController();
      _amountController = TextEditingController();
      _descriptionController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: Theme.of(context).canvasColor,
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

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      alignment: AlignmentDirectional.bottomStart,
      menuMaxHeight: 260,
      dropdownColor: Theme.of(context).canvasColor,
      borderRadius: BorderRadius.circular(12),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
      decoration: _buildInputDecoration(hint),
      items: items,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletsProvider);
    final screenHeight = MediaQuery.of(context).size.height;

    final labelStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).primaryColor,
    );

    return Padding(
      padding: EdgeInsets.only(top: screenHeight * 0.12),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: BackButton(color: Theme.of(context).primaryColor),
            title: Text(
              _isEditMode ? "Edit Transaction" : "Add Transaction",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
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
                  // ── Scrollable fields ──────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // Type
                          _buildFieldLabel("Type", false, labelStyle),
                          _buildDropdown<String>(
                            value: _selectedType,
                            hint: "Select Type",
                            items: _types
                                .map(
                                  (t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(
                                      t,
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val == null) return;
                              setState(() {
                                _selectedType = val;
                                _selectedCategory = null;
                              });
                            },
                          ),

                          const SizedBox(height: 20),

                          // Wallet
                          _buildFieldLabel("Wallet", false, labelStyle),
                          _buildDropdown<String>(
                            value: _selectedWalletId,
                            hint: "Select Wallet",
                            items: wallets
                                .map(
                                  (w) => DropdownMenuItem(
                                    value: w.id,
                                    child: Text(
                                      w.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedWalletId = val),
                            validator: (val) =>
                                val == null ? "Please select a wallet" : null,
                          ),

                          // Category (income + expense)
                          const SizedBox(height: 20),
                          _buildFieldLabel("Category", false, labelStyle),
                          Consumer(
                            builder: (context, ref, _) {
                              final cats = ref
                                  .watch(categoryProvider.notifier)
                                  .namesFor(_selectedType.toLowerCase());
                              return _buildDropdown<String>(
                                value: cats.contains(_selectedCategory)
                                    ? _selectedCategory
                                    : null,
                                hint: "Select Category",
                                items: cats
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(
                                          c,
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) =>
                                    setState(() => _selectedCategory = val),
                                validator: (val) =>
                                    val == null ? "Select a category" : null,
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          // Date & Time
                          _buildFieldLabel("Date & Time", false, labelStyle),
                          TextFormField(
                            controller: _dateController,
                            readOnly: true,
                            decoration:
                                _buildInputDecoration(
                                  "Select Date & Time",
                                ).copyWith(
                                  suffixIcon: const Icon(
                                    Icons.calendar_month,
                                    size: 20,
                                  ),
                                ),
                            onTap: () async {
                              final initialDateTime =
                                  _dateController.text.isEmpty
                                  ? DateTime.now()
                                  : _dateTimeFormat.parse(_dateController.text);

                              // 1. Pick Date
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: initialDateTime,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );

                              if (pickedDate == null) return;

                              // 2. Pick Time
                              if (mounted) {
                                final TimeOfDay? pickedTime =
                                    await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.fromDateTime(
                                        initialDateTime,
                                      ),
                                    );

                                if (pickedTime != null) {
                                  final finalDateTime = DateTime(
                                    pickedDate.year,
                                    pickedDate.month,
                                    pickedDate.day,
                                    pickedTime.hour,
                                    pickedTime.minute,
                                  );

                                  // Only allow past/current times
                                  if (finalDateTime.isAfter(DateTime.now())) {
                                    if (mounted) {
                                      SnackBarUtils.showSnackBar(
                                        context,
                                        "Cannot select a future time!",
                                        isError: true,
                                      );
                                    }
                                    return;
                                  }

                                  setState(() {
                                    _dateController.text = _dateTimeFormat
                                        .format(finalDateTime);
                                  });
                                }
                              }
                            },
                            validator: (val) => val == null || val.isEmpty
                                ? "Please select a date and time"
                                : null,
                          ),

                          const SizedBox(height: 20),

                          // Amount
                          _buildFieldLabel("Amount", false, labelStyle),
                          TextFormField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: _buildInputDecoration("0.00"),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return "Enter an amount";
                              }
                              final amount = double.tryParse(val);
                              if (amount == null) {
                                return "Enter a valid number";
                              }
                              if (amount <= 0) {
                                return "Amount must be greater than zero";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Description
                          _buildFieldLabel("Description", true, labelStyle),
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

                  // ── Bottom action buttons ──────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: _isEditMode
                        ? _buildEditButtons()
                        : _buildSubmitButton(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Button layouts ────────────────────────────────────────────────────────

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _submitTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00885d),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          "Add",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEditButtons() {
    return Row(
      children: [
        // Delete
        SizedBox(
          height: 55,
          width: 55,
          child: ElevatedButton(
            onPressed: _confirmDelete,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              padding: EdgeInsets.zero,
            ),
            child: const Icon(
              Icons.delete_outline,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Update
        Expanded(
          child: SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: _updateTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00885d),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Update Wallet",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _submitTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final wallets = ref.read(walletsProvider);
    final selectedWallet = wallets.firstWhere((w) => w.id == _selectedWalletId);
    final amount = double.parse(_amountController.text.trim());
    final transactionType = _selectedType == 'Income'
        ? TransactionType.income
        : TransactionType.expense;

    // Insufficient balance guard
    if (transactionType == TransactionType.expense &&
        selectedWallet.balance < amount) {
      if (mounted) {
        SnackBarUtils.showSnackBar(
          context,
          "Insufficient balance in ${selectedWallet.name}!",
          isError: true,
        );
      }
      return;
    }

    // 10-digit balance cap
    const double maxTotalBalance = 9999999999;
    if (transactionType == TransactionType.income) {
      final double currentTotal = ref
          .read(walletsProvider)
          .fold(0.0, (sum, w) => sum + w.balance);
      if (currentTotal + amount > maxTotalBalance) {
        if (mounted) {
          SnackBarUtils.showSnackBar(
            context,
            "You're too wealthy for us to handle! 🤑 Max balance is ₹9,999,999,999.",
            isError: true,
          );
        }
        return;
      }
    }

    final DateTime parsedDate = _dateController.text.isNotEmpty
        ? _dateTimeFormat.parse(_dateController.text)
        : DateTime.now();

    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      walletId: selectedWallet.id,
      amount: amount,
      title: _selectedCategory ?? 'Other',
      category: _selectedCategory ?? 'Other',
      type: transactionType,
      date: parsedDate,
      note: _descriptionController.text.trim(),
    );

    await ref.read(transactionsProvider.notifier).addTransaction(transaction);
    await ref
        .read(walletsProvider.notifier)
        .updateWalletBalance(
          walletId: selectedWallet.id,
          amount: amount,
          type: transactionType,
        );

    if (mounted) {
      Navigator.pop(context);
      SnackBarUtils.showSnackBar(context, "Transaction Saved!");
    }
  }

  Future<void> _updateTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final old = widget.existing!;
    final wallets = ref.read(walletsProvider);
    final selectedWallet = wallets.firstWhere((w) => w.id == _selectedWalletId);
    final newAmount = double.parse(_amountController.text.trim());
    final newType = _selectedType == 'Income'
        ? TransactionType.income
        : TransactionType.expense;

    // ── Step 1: reverse the OLD transaction's effect on the wallet ──────────
    final oldReverseType = old.type == TransactionType.income
        ? TransactionType.expense
        : TransactionType.income;

    await ref
        .read(walletsProvider.notifier)
        .updateWalletBalance(
          walletId: old.walletId,
          amount: old.amount,
          type: oldReverseType,
        );

    // ── Step 2: guard new values ────────────────────────────────────────────
    final walletsAfterReversal = ref.read(walletsProvider);
    final walletAfterReversal = walletsAfterReversal.firstWhere(
      (w) => w.id == selectedWallet.id,
    );

    if (newType == TransactionType.expense &&
        walletAfterReversal.balance < newAmount) {
      await ref
          .read(walletsProvider.notifier)
          .updateWalletBalance(
            walletId: old.walletId,
            amount: old.amount,
            type: old.type,
          );
      if (mounted) {
        SnackBarUtils.showSnackBar(
          context,
          "Insufficient balance in ${selectedWallet.name}!",
          isError: true,
        );
      }
      return;
    }

    const double maxTotalBalance = 9999999999;
    if (newType == TransactionType.income) {
      final double currentTotal = walletsAfterReversal.fold(
        0.0,
        (sum, w) => sum + w.balance,
      );
      if (currentTotal + newAmount > maxTotalBalance) {
        await ref
            .read(walletsProvider.notifier)
            .updateWalletBalance(
              walletId: old.walletId,
              amount: old.amount,
              type: old.type,
            );
        if (mounted) {
          SnackBarUtils.showSnackBar(
            context,
            "You're too wealthy for us to handle! 🤑 Max balance is ₹9,999,999,999.",
            isError: true,
          );
        }
        return;
      }
    }

    // ── Step 3: apply new transaction effect ─────────────────────────────────
    await ref
        .read(walletsProvider.notifier)
        .updateWalletBalance(
          walletId: selectedWallet.id,
          amount: newAmount,
          type: newType,
        );

    // ── Step 4: overwrite the record in Hive ─────────────────────────────────
    final DateTime parsedDate = _dateController.text.isNotEmpty
        ? _dateTimeFormat.parse(_dateController.text)
        : DateTime.now();

    final updated = TransactionModel(
      id: old.id,
      walletId: selectedWallet.id,
      amount: newAmount,
      title: _selectedCategory ?? 'Other',
      category: _selectedCategory ?? 'Other',
      type: newType,
      date: parsedDate,
      note: _descriptionController.text.trim(),
    );

    await ref.read(transactionsProvider.notifier).updateTransaction(updated);

    if (mounted) {
      Navigator.pop(context);
      SnackBarUtils.showSnackBar(context, "Transaction Updated!");
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Transaction"),
        content: const Text(
          "Are you sure? This will reverse the balance on the associated wallet.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final old = widget.existing!;
    final reverseType = old.type == TransactionType.income
        ? TransactionType.expense
        : TransactionType.income;

    try {
      await ref
          .read(walletsProvider.notifier)
          .updateWalletBalance(
            walletId: old.walletId,
            amount: old.amount,
            type: reverseType,
          );
      await ref.read(transactionsProvider.notifier).deleteTransaction(old.id);

      if (mounted) {
        Navigator.pop(context);
        SnackBarUtils.showSnackBar(context, "Transaction deleted.");
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showSnackBar(
          context,
          "Something went wrong. Please try again.",
          isError: true,
        );
      }
    }
  }
}
