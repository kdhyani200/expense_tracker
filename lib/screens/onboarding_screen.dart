import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'setup_profile.dart';

class OnBoarding extends StatelessWidget {
  const OnBoarding({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 1),
              Container(
                width: media.size.width * 0.7,
                height: media.size.width * 0.7,
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(25),
                child: Image.asset(
                  "assets/onboard_image.webp",
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 30),

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'Spend with ',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                  children: <TextSpan>[
                    const TextSpan(
                      text: '\nintention',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00885d),
                      ),
                    ),
                    TextSpan(
                      text: ', growth \nwith',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const TextSpan(
                      text: ' clarity',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00885d),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Text(
                "Experience financial tranquility with a minimalistic approach to tracking and budgeting and growing your wealth",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey[500]),
              ),

              const Spacer(),

              Center(
                child: Text(
                  'Your data stays on your device only.',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: const Color(0xFF00885d),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SetupProfileScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Setup",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
