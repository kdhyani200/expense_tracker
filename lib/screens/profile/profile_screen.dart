import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added this import
import 'package:flutter/material.dart';
import '../../widget/profile_item_card.dart';
import 'edit_profile_picture.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _selectedImage;
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  String first_name = '';
  String last_name = '';

  void _openEditProfilePicture() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => AddProfilePictureScreen(
        firstName: first_name,
        lastName: last_name,
        initialImage: _selectedImage,
        onPickImage: (image) {
          setState(() {
            _selectedImage = image;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    final profileImageSize = screenWidth * 0.35;
    final horizontalPadding = screenWidth * 0.03;
    final verticalSpacing = screenHeight * 0.02;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Profile",
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data?.data() as Map<String, dynamic>?;
          final firstName = userData?['firstname'] ?? 'User';
          first_name = firstName;
          final lastName = userData?['lastname'] ?? '';
          last_name = lastName;
          final email = userData?['email'] ?? 'user@example.com';

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              children: [
                SizedBox(height: verticalSpacing),
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _openEditProfilePicture,
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          width: profileImageSize,
                          height: profileImageSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade200,
                            border: Border.all(
                              color: const Color(0xFF10b981),
                              width: 2,
                            ),
                          ),
                          child: _selectedImage == null
                              ? Icon(
                                  Icons.person,
                                  size: profileImageSize * 0.4,
                                  color: Colors.white,
                                )
                              : Image.file(_selectedImage!, fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "$firstName $lastName",
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: verticalSpacing),
                Column(
                  children: const [
                    ProfileItemCard(
                      icon: Icons.person_outline_rounded,
                      color: Colors.deepPurpleAccent,
                      label: 'Account Info',
                    ),
                    SizedBox(height: 10),
                    ProfileItemCard(
                      icon: Icons.settings_outlined,
                      color: Colors.green,
                      label: 'Settings',
                    ),
                    SizedBox(height: 10),
                    ProfileItemCard(
                      icon: Icons.security_rounded,
                      color: Colors.blueGrey,
                      label: 'Privacy & Security',
                    ),
                    SizedBox(height: 10),
                    ProfileItemCard(
                      icon: Icons.logout_rounded,
                      color: Colors.redAccent,
                      label: 'Logout',
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
