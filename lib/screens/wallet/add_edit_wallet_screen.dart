import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widget/image_helper.dart';
import '../../models/wallet_model.dart';
import '../../providers/wallet_providers.dart';
import '../../utils/snackbar_util.dart';

/// Single screen that handles both adding a new wallet and editing an existing
/// one.  Pass [wallet] to open in edit mode; omit it (or pass null) for add.
class AddEditWalletScreen extends ConsumerStatefulWidget {
  final WalletModel? wallet;

  const AddEditWalletScreen({super.key, this.wallet});

  @override
  ConsumerState<AddEditWalletScreen> createState() =>
      _AddEditWalletScreenState();
}

class _AddEditWalletScreenState extends ConsumerState<AddEditWalletScreen> {
  late final TextEditingController _nameController;
  String? _selectedImagePath;

  bool get _isEditMode => widget.wallet != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.wallet?.name ?? '');
    _selectedImagePath = widget.wallet?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
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
    );
  }

  Future<void> _pickImage() async {
    final path = await ImageHelper.pickAndSaveImage();
    if (path == null) return;
    setState(() => _selectedImagePath = path);
  }

  Widget _buildImagePicker() {
    final hasImage =
        _selectedImagePath != null && File(_selectedImagePath!).existsSync();

    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).shadowColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: hasImage
                  ? Image.file(File(_selectedImagePath!), fit: BoxFit.cover)
                  : const Icon(
                      Icons.add_a_photo_outlined,
                      color: Colors.grey,
                      size: 40,
                    ),
            ),
          ),
          if (hasImage)
            Positioned(
              top: 5,
              right: 5,
              child: GestureDetector(
                onTap: () => setState(() => _selectedImagePath = null),
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: const Icon(Icons.close, size: 12, color: Colors.black),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _save() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      SnackBarUtils.showSnackBar(
        context,
        "Please enter a wallet name",
        isError: true,
      );
      return;
    }

    final duplicate = ref
        .read(walletsProvider)
        .any(
          (w) =>
              w.id != (widget.wallet?.id ?? '') &&
              w.name.trim().toLowerCase() == name.toLowerCase(),
        );

    if (duplicate) {
      SnackBarUtils.showSnackBar(
        context,
        "A wallet with that name already exists",
        isError: true,
      );
      return;
    }

    if (_isEditMode) {
      final updated = WalletModel(
        id: widget.wallet!.id,
        name: name,
        balance: widget.wallet!.balance,
        imagePath: _selectedImagePath,
        createdAt: widget.wallet!.createdAt,
      );
      await ref.read(walletsProvider.notifier).updateWallet(updated);
      if (mounted) {
        Navigator.pop(context);
        SnackBarUtils.showSnackBar(context, "Wallet updated!");
      }
    } else {
      final wallet = WalletModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        balance: 0.0,
        imagePath: _selectedImagePath,
        createdAt: DateTime.now(),
      );
      final added = await ref.read(walletsProvider.notifier).addWallet(wallet);
      if (!added) {
        if (mounted) {
          SnackBarUtils.showSnackBar(
            context,
            "A wallet with that name already exists",
            isError: true,
          );
        }
        return;
      }
      if (mounted) {
        Navigator.pop(context);
        SnackBarUtils.showSnackBar(context, "Wallet added!");
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Wallet"),
        content: Text(
          "Delete \"${widget.wallet!.name}\"? "
          "All transactions linked to this wallet will remain but the wallet will be removed.",
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

    await ref.read(walletsProvider.notifier).deleteWallet(widget.wallet!.id);

    if (mounted) {
      Navigator.pop(context);
      SnackBarUtils.showSnackBar(context, "Wallet deleted.");
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

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
              _isEditMode ? "Edit Wallet" : "New Wallet",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            bottom: true,
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Column(
                children: [
                  // ── Fields ─────────────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          const Text(
                            "Wallet Name",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            maxLength: 20,
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: _buildInputDecoration(
                              "e.g. Secret Vault",
                            ),
                          ),

                          const SizedBox(height: 30),

                          const Text(
                            "Wallet Image",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          _buildImagePicker(),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),

                  // ── Bottom buttons ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: _isEditMode
                        ? _buildEditButtons()
                        : _buildAddButton(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00885d),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          "Add Wallet",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
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
              onPressed: _save,
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
}
