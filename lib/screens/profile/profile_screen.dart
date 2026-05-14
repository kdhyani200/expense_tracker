import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/user_profile.dart';
import '../../widget/profile_item_card.dart';
import 'edit_profile_picture.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _openEditProfilePicture(
    BuildContext context,
    WidgetRef ref,
    File? selectedImage,
    String firstName,
    String lastName,
  ) async {
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => AddProfilePictureScreen(
        firstName: firstName,
        lastName: lastName,
        initialImage: selectedImage,
        onPickImage: (_) {},
      ),
    );

    ref.read(userProfileProvider.notifier).loadUser();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final profileImageSize = screenWidth * 0.35;

    final File? selectedImage = user?.imagePath != null
        ? File(user!.imagePath!)
        : null;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),

        child: Column(
          children: [
            const SizedBox(height: 20),

            Column(
              children: [
                GestureDetector(
                  onTap: () => _openEditProfilePicture(
                    context,
                    ref,
                    selectedImage,
                    user?.firstName ?? '',
                    user?.lastName ?? '',
                  ),

                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    width: profileImageSize,
                    height: profileImageSize,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade200,
                    ),

                    child: selectedImage != null && selectedImage.existsSync()
                        ? Image.file(selectedImage, fit: BoxFit.cover)
                        : Icon(
                            Icons.person,
                            size: profileImageSize * 0.4,
                            color: Colors.grey.shade400,
                          ),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  (user == null ||
                          (user.firstName.trim().isEmpty &&
                              user.lastName.trim().isEmpty))
                      ? "User"
                      : "${user.firstName} ${user.lastName}".trim(),

                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const ProfileItemCard(
              icon: Icons.person_outline,
              color: Colors.purple,
              label: 'Account Info',
            ),

            const SizedBox(height: 10),

            const ProfileItemCard(
              icon: Icons.settings_outlined,
              color: Colors.green,
              label: 'Settings',
            ),

            const SizedBox(height: 10),

            const ProfileItemCard(
              icon: Icons.logout_rounded,
              color: Colors.redAccent,
              label: 'Logout',
            ),
          ],
        ),
      ),
    );
  }
}
