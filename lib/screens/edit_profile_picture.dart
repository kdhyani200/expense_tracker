import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddProfilePictureScreen extends StatefulWidget {
  const AddProfilePictureScreen({
    super.key,
    required this.onPickImage,
    this.initialImage,
    required this.firstName,
    required this.lastName,
  });

  final void Function(File? image) onPickImage;
  final File? initialImage; //
  final String firstName;
  final String lastName;

  @override
  State<AddProfilePictureScreen> createState() =>
      _AddProfilePictureScreenState();
}

class _AddProfilePictureScreenState extends State<AddProfilePictureScreen> {
  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400, width: .8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade800, width: 1.3),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.3),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.8),
      ),
    );
  }

  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    // Initialize the local state with the existing image
    _selectedImage = widget.initialImage;
  }

  void _takePictureViaCamera() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );
    if (pickedImage == null) return;

    setState(() {
      _selectedImage = File(pickedImage.path);
    });

    // We close the bottom sheet after selection
    if (mounted) Navigator.pop(context);
  }

  void _takePictureViaGallery() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );
    if (pickedImage == null) return;

    setState(() {
      _selectedImage = File(pickedImage.path);
    });

    if (mounted) Navigator.pop(context);
  }

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 180,
          child: Column(
            children: [
              const Text(
                "Profile Photo",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _imagePickerOption(
                    icon: Icons.camera_alt_rounded,
                    label: "Camera",
                    onTap: () {
                      _takePictureViaCamera();
                    },
                  ),
                  _imagePickerOption(
                    icon: Icons.image_rounded,
                    label: "Gallery",
                    onTap: () {
                      _takePictureViaGallery();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper widget for picker options
  Widget _imagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFF00885d).withValues(alpha: 0.2),
            child: Icon(icon, color: Color(0xFF00885d)),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    final profileImageSize = screenWidth * 0.35;
    final horizontalPadding = screenWidth * 0.05;
    final verticalSpacing = screenHeight * 0.02;

    // 1. Scaffold should be at the ROOT
    return Padding(
      padding: EdgeInsets.only(top: verticalSpacing * 2),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
          title: const Text(
            "Update Profile",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        // 2. Wrap the body in GestureDetector and SafeArea
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior:
              HitTestBehavior.opaque, // Ensures the whole area catches the tap
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                children: [
                  SizedBox(height: verticalSpacing * 2),
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: profileImageSize,
                          height: profileImageSize,
                          clipBehavior:
                              Clip.antiAlias, // Ensures image stays circular
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade200,
                          ),
                          child: _selectedImage != null
                              ? Image.file(_selectedImage!, fit: BoxFit.cover)
                              : Icon(
                                  Icons.person,
                                  size: profileImageSize * 0.4,
                                  color: Colors.white,
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _showImagePicker(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10b981),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.edit,
                                size: profileImageSize * 0.15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_selectedImage != null)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedImage =
                              null; // Reverts to the default person icon
                        });
                      },
                      child: const Text(
                        "Remove Picture",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    SizedBox(height: verticalSpacing * 2),

                  TextField(
                    controller: TextEditingController(text: widget.firstName),
                    decoration: _buildInputDecoration(
                      'First Name',
                    ).copyWith(hintStyle: const TextStyle(color: Colors.grey)),
                    onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                  SizedBox(height: verticalSpacing),
                  TextField(
                    controller: TextEditingController(text: widget.lastName),
                    decoration: _buildInputDecoration('Last Name').copyWith(
                      // CHANGE THIS COLOR
                      hintStyle: const TextStyle(color: Colors.grey),
                    ),
                    onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onPickImage(_selectedImage);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00885d),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Update",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: verticalSpacing),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
