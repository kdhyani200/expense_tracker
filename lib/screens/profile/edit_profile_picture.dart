import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_model.dart';
import '../../providers/user_profile.dart';
import '../../utils/snackbar_util.dart';

class AddProfilePictureScreen extends ConsumerStatefulWidget {
  const AddProfilePictureScreen({
    super.key,
    required this.onPickImage,
    this.initialImage,
    required this.firstName,
    required this.lastName,
  });

  final void Function(File? image) onPickImage;
  final File? initialImage;
  final String firstName;
  final String lastName;

  @override
  ConsumerState<AddProfilePictureScreen> createState() =>
      _AddProfilePictureScreenState();
}

class _AddProfilePictureScreenState
    extends ConsumerState<AddProfilePictureScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  File? _selectedImage;
  bool get isDarkMode => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.initialImage;
    _firstNameController = TextEditingController(text: widget.firstName);
    _lastNameController = TextEditingController(text: widget.lastName);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _saveAndExit() async {
    final updatedFirstName = _firstNameController.text.trim();
    final updatedLastName = _lastNameController.text.trim();

    final currentUser = ref.read(userProfileProvider);

    if (currentUser != null) {
      final updatedUser = UserModel(
        firstName: updatedFirstName,
        lastName: updatedLastName,
        imagePath: _selectedImage?.path,
      );

      await ref.read(userProfileProvider.notifier).updateUser(updatedUser);
    }

    widget.onPickImage(_selectedImage);

    if (mounted) {
      Navigator.pop(context);

      SnackBarUtils.showSnackBar(context, "Profile Updated Successfully!");
    }
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: isDarkMode ? Color(0xFF1a222e) : Colors.white,
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

  void _takePictureViaCamera() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );
    if (pickedImage == null) return;
    setState(() => _selectedImage = File(pickedImage.path));
  }

  void _takePictureViaGallery() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );
    if (pickedImage == null) return;
    setState(() => _selectedImage = File(pickedImage.path));
  }

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
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
                      Navigator.pop(sheetContext); // Pop sheet only
                      _takePictureViaCamera();
                    },
                  ),
                  _imagePickerOption(
                    icon: Icons.image_rounded,
                    label: "Gallery",
                    onTap: () {
                      Navigator.pop(sheetContext); // Pop sheet only
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
            child: Icon(icon, color: const Color(0xFF00885d)),
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

    return Padding(
      padding: EdgeInsets.only(top: screenHeight * 0.12),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: BackButton(color: Theme.of(context).primaryColor),
            title: Text(
              "Update Profile",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.opaque,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: verticalSpacing),
                            Center(
                              child: GestureDetector(
                                onTap: () => _showImagePicker(context),
                                child: Container(
                                  width: profileImageSize,
                                  height: profileImageSize,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).shadowColor,
                                  ),
                                  child: _selectedImage != null
                                      ? Image.file(
                                          _selectedImage!,
                                          fit: BoxFit.cover,
                                        )
                                      : Icon(
                                          Icons.person,
                                          size: profileImageSize * 0.4,
                                          color: Colors.grey.shade400,
                                        ),
                                ),
                              ),
                            ),
                            if (_selectedImage != null)
                              TextButton(
                                onPressed: () =>
                                    setState(() => _selectedImage = null),
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
                              controller: _firstNameController,
                              decoration: _buildInputDecoration('First Name'),
                              onSubmitted: (_) =>
                                  FocusScope.of(context).nextFocus(),
                            ),
                            SizedBox(height: verticalSpacing),
                            TextField(
                              controller: _lastNameController,
                              decoration: _buildInputDecoration('Last Name'),
                              onSubmitted: (_) =>
                                  FocusScope.of(context).unfocus(),
                            ),
                            SizedBox(height: verticalSpacing * 2),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: verticalSpacing),
                      child: SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _saveAndExit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00885d),
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
