import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/wallet.dart';

class UpdateWalletScreen extends StatefulWidget {
  final Wallet wallet;
  final VoidCallback onDelete;
  final Function(String name, File? image) onUpdate;

  const UpdateWalletScreen({
    super.key,
    required this.wallet,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  State<UpdateWalletScreen> createState() => _UpdateWalletScreenState();
}

class _UpdateWalletScreenState extends State<UpdateWalletScreen> {
  late TextEditingController _nameController;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.wallet.name);
    _selectedImage = widget.wallet.image;
  }

  void _takePicture() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );
    if (pickedImage == null) return;
    setState(() {
      _selectedImage = File(pickedImage.path);
    });
  }

  Widget _getDisplayImage() {
    if (_selectedImage != null) {
      return Image.file(_selectedImage!, fit: BoxFit.cover);
    }
    return const Icon(Icons.add_a_photo_outlined, color: Colors.grey, size: 40);
  }

  Widget _buildImagePreview() {
    return GestureDetector(
      onTap: _takePicture,
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: _getDisplayImage(),
            ),
          ),
          if (_selectedImage != null)
            Positioned(
              top: 5,
              right: 5,
              child: _buildCloseBtn(() {
                setState(() {
                  _selectedImage = null;
                });
              }),
            ),
        ],
      ),
    );
  }

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
    );
  }

  Widget _buildCloseBtn(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 10,
        backgroundColor: Colors.white.withValues(alpha: .9),
        child: const Icon(Icons.close, size: 12, color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

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
              "Update Wallet",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Column(
            children: [
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
                        controller: _nameController,
                        decoration: _buildInputDecoration("Wallet Name"),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        "Wallet Icon",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      _buildImagePreview(),
                    ],
                  ),
                ),
              ),
              _buildActionRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: const Color(0xFFFF5252),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: () {
                widget.onDelete();
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  widget.onUpdate(_nameController.text, _selectedImage);
                  Navigator.pop(context);
                },
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
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
