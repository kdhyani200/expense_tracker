import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/transaction_model.dart';
import '../../providers/transactions_providers.dart';
import '../../providers/category_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/wallet_providers.dart';
import '../../utils/amount_formatter.dart';
import '../../utils/snackbar_util.dart';

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
  late final TextEditingController _timeController;
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;

  bool get _isEditMode => widget.existing != null;

  final List<String> _types = ['Expense', 'Income'];

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
        text: DateFormat('dd/MM/yyyy').format(tx.date),
      );

      _timeController = TextEditingController(
        text: DateFormat('hh:mm a').format(tx.date),
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

      final now = DateTime.now();

      _dateController = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(now),
      );

      _timeController = TextEditingController(
        text: DateFormat('hh:mm a').format(now),
      );

      _amountController = TextEditingController();
      _descriptionController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
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

                          // Date
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
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _dateController.text.isEmpty
                                    ? DateTime.now()
                                    : DateFormat(
                                        'dd/MM/yyyy',
                                      ).parse(_dateController.text),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );

                              if (picked != null) {
                                setState(() {
                                  _dateController.text = DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(picked);
                                });
                              }
                            },
                            validator: (val) => val == null || val.isEmpty
                                ? "Please select a date"
                                : null,
                          ),

                          const SizedBox(height: 20),

                          // Time
                          _buildFieldLabel("Time", false, labelStyle),

                          TextFormField(
                            controller: _timeController,
                            readOnly: true,
                            decoration: _buildInputDecoration("Select Time")
                                .copyWith(
                                  suffixIcon: const Icon(
                                    Icons.access_time,
                                    size: 20,
                                  ),
                                ),
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );

                              if (picked != null) {
                                final now = DateTime.now();

                                final dt = DateTime(
                                  now.year,
                                  now.month,
                                  now.day,
                                  picked.hour,
                                  picked.minute,
                                );

                                _timeController.text = DateFormat(
                                  'hh:mm a',
                                ).format(dt);
                              }
                            },
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

  Future<void> _submitTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final wallets = ref.read(walletsProvider);
    final selectedWallet = wallets.firstWhere((w) => w.id == _selectedWalletId);

    final amount = double.parse(_amountController.text.trim());

    final transactionType = _selectedType == 'Income'
        ? TransactionType.income
        : TransactionType.expense;

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

    const double maxTotalBalance = 9999999999;

    if (transactionType == TransactionType.income) {
      final double currentTotal = ref
          .read(walletsProvider)
          .fold(0.0, (sum, w) => sum + w.balance);

      if (currentTotal + amount > maxTotalBalance) {
        if (mounted) {
          SnackBarUtils.showSnackBar(
            context,
            "You're too wealthy for us to handle! 🤑 Max balance is ${formatAmount(9999999999, ref.read(preferencesProvider).currencySymbol, ref.read(preferencesProvider).decimalPlaces)}.",
            isError: true,
          );
        }
        return;
      }
    }

    DateTime parsedDate = DateTime.now();

    if (_dateController.text.isNotEmpty) {
      final date = DateFormat('dd/MM/yyyy').parse(_dateController.text);

      final time = DateFormat('hh:mm a').parse(_timeController.text);

      parsedDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    }

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

  Future<void> _updateTransaction() async {}
  Future<void> _confirmDelete() async {}
}
