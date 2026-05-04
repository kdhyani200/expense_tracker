import 'package:flutter/material.dart';
import '../widget/profile_item_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          children: [
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade900,
                      border: Border.all(
                        color: const Color(0xFFC0FF5F),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    "Karan Dhyani",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "karan@example.com",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: const [
                ProfileItemCard(
                  icon: Icons.person_outline_rounded,
                  color: Colors.deepPurpleAccent,
                  label: 'Account Info',
                ),
                SizedBox(height: 2),
                ProfileItemCard(
                  icon: Icons.settings_outlined,
                  color: Colors.green,
                  label: 'Settings',
                ),
                SizedBox(height: 2),
                ProfileItemCard(
                  icon: Icons.security_rounded,
                  color: Colors.blueGrey,
                  label: 'Privacy & Security',
                ),
                SizedBox(height: 2),
                ProfileItemCard(
                  icon: Icons.logout_rounded,
                  color: Colors.redAccent,
                  label: 'Logout',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
