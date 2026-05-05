import 'package:flutter/material.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Values
  String _selectedType = 'Expense';
  String? _selectedWallet;
  String? _selectedCategory;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> _types = ['Expense', 'Income'];
  final List<String> _wallets = ['Cash', 'Bank Account', 'Credit Card'];
  final List<String> _categories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
  ];

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
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    final horizontalPadding = screenWidth * 0.05;
    final verticalSpacing = screenHeight * 0.02;
    final labelStyle = TextStyle(
      fontSize: screenWidth * 0.042,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    );

    return Padding(
      padding: EdgeInsets.only(top: screenHeight * 0.10),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
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
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: verticalSpacing),

                          // TYPE DROPDOWN
                          _buildFieldLabel("Type", false, labelStyle),
                          DropdownButtonFormField<String>(
                            value: _selectedType,
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
                                // Reset category if switching to Income
                                if (_selectedType == 'Income')
                                  _selectedCategory = null;
                              });
                            },
                          ),

                          SizedBox(height: verticalSpacing),

                          // WALLET DROPDOWN
                          _buildFieldLabel("Wallet", false, labelStyle),
                          DropdownButtonFormField<String>(
                            value: _selectedWallet,
                            decoration: _buildInputDecoration("Select Wallet"),
                            items: _wallets
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

                          // CONDITIONAL CATEGORY DROPDOWN
                          if (_selectedType == 'Expense') ...[
                            SizedBox(height: verticalSpacing),
                            _buildFieldLabel("Category", false, labelStyle),
                            DropdownButtonFormField<String>(
                              value: _selectedCategory,
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

                          SizedBox(height: verticalSpacing),

                          // DATE PICKER
                          _buildFieldLabel("Date", false, labelStyle),
                          TextFormField(
                            controller: _dateController,
                            readOnly: true,
                            decoration: _buildInputDecoration("Select Date")
                                .copyWith(
                                  suffixIcon: const Icon(
                                    Icons.calendar_today,
                                    size: 20,
                                  ),
                                ),
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
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

                          SizedBox(height: verticalSpacing),

                          // AMOUNT
                          _buildFieldLabel("Amount", false, labelStyle),
                          TextFormField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            decoration: _buildInputDecoration("0.00"),
                            validator: (val) {
                              if (val == null || val.isEmpty)
                                return "Enter an amount";
                              if (double.tryParse(val) == null)
                                return "Enter a valid number";
                              return null;
                            },
                          ),

                          SizedBox(height: verticalSpacing),

                          // DESCRIPTION (Now Permanent)
                          _buildFieldLabel("Description ", true, labelStyle),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: _buildInputDecoration("Add a note..."),
                          ),
                          SizedBox(height: verticalSpacing * 2),
                        ],
                      ),
                    ),
                  ),

                  // SUBMIT BUTTON
                  Padding(
                    padding: EdgeInsets.all(horizontalPadding),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Process Data
                            Navigator.pop(context);
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
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: label,
              style: style, // Your existing black bold style
            ),
            if (isOptional)
              TextSpan(
                text: " (Optional)",
                style: style.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                  fontSize: style.fontSize! * 0.9, // Slightly smaller
                ),
              ),
          ],
        ),
      ),
    );
  }
}
