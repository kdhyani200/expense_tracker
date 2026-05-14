import 'package:expense_tracker/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../providers/user_profile.dart';

class SetupProfileScreen extends ConsumerStatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  ConsumerState<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends ConsumerState<SetupProfileScreen> {
  final TextEditingController _firstController = TextEditingController();

  final TextEditingController _lastController = TextEditingController();

  Future<void> _completeSetup() async {
    final firstName = _firstController.text.trim();

    final lastName = _lastController.text.trim();

    if (firstName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter first name")));

      return;
    }

    final user = UserModel(
      firstName: firstName,

      lastName: lastName,

      imagePath: null,
    );

    await ref.read(userProfileProvider.notifier).saveUser(user);

    if (mounted) {
      Navigator.pushReplacement(
        context,

        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,

      filled: true,

      fillColor: Colors.grey[100],

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),

        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              const Text(
                "Welcome to Track Kar",

                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Text(
                "Setup your offline profile",

                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
              ),

              const SizedBox(height: 40),

              TextField(
                controller: _firstController,

                textCapitalization: TextCapitalization.words,

                decoration: _inputDecoration("First Name"),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: _lastController,

                textCapitalization: TextCapitalization.words,

                decoration: _inputDecoration("Last Name"),
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  onPressed: _completeSetup,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00885d),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  child: const Text(
                    "Get Started",

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
