import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../snackbar_util.dart';
import 'main_screen.dart';

var _firebase = FirebaseAuth.instance;

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final _formKey = GlobalKey<FormState>();

  var _isLogin = true;
  var _isAuthenticating = false;

  var enteredEmail = '';
  var enteredPassword = '';
  var enteredFirstName = '';
  var enteredLastName = '';

  Future<void> _submit() async {
    if (_isAuthenticating) return;

    FocusScope.of(context).unfocus();

    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    _formKey.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });

      UserCredential userCredential;

      if (_isLogin) {
        userCredential = await _firebase.signInWithEmailAndPassword(
          email: enteredEmail.trim(),
          password: enteredPassword.trim(),
        );
      } else {
        userCredential = await _firebase.createUserWithEmailAndPassword(
          email: enteredEmail.trim(),
          password: enteredPassword.trim(),
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
              'firstname': enteredFirstName.trim(),
              'lastname': enteredLastName.trim(),
              'email': enteredEmail.trim(),
            });
      }

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      final message = _getAuthErrorMessage(e);
      SnackBarUtils.showSnackBar(context, message);
    } catch (_) {
      SnackBarUtils.showSnackBar(
        context,
        'Something went wrong. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address';

      case 'email-already-in-use':
        return 'This email is already registered';

      case 'weak-password':
        return 'Password should be at least 6 characters';

      case 'user-not-found':
      case 'wrong-password':
        return 'Invalid email or password';

      case 'too-many-requests':
        return 'Too many attempts. Try again later';

      case 'network-request-failed':
        return 'No internet connection';

      default:
        return 'Authentication failed. Please try again';
    }
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: mediaQuery.padding.top + 60),
                    // TITLE SECTION
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/expense_light_logo.png",
                          width: 60,
                          height: 60,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 60),
                        ),
                        Text(
                          "Track Kar",
                          style: GoogleFonts.poppins(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00885d),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // FORM CARD
                    Card(
                      color: isDarkMode ? Colors.black12 : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isLogin
                                    ? "Welcome Back"
                                    : 'Start a new journey',
                                style: GoogleFonts.poppins(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              Text(
                                _isLogin
                                    ? "Log In into your account"
                                    : 'Create a new account to get started',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(height: 20),

                              if (!_isLogin) ...[
                                TextFormField(
                                  decoration:
                                      _buildInputDecoration(
                                        'First Name',
                                        Icons.person_2_outlined,
                                      ).copyWith(
                                        hintStyle: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                  validator: (value) =>
                                      (value == null || value.length < 4)
                                      ? 'Min 4 characters'
                                      : null,
                                  onSaved: (value) => enteredFirstName = value!,
                                ),
                                const SizedBox(height: 15),
                                TextFormField(
                                  decoration:
                                      _buildInputDecoration(
                                        'Last Name',
                                        Icons.person_2_outlined,
                                      ).copyWith(
                                        hintStyle: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                  validator: (value) =>
                                      (value == null || value.length < 4)
                                      ? 'Min 4 characters'
                                      : null,
                                  onSaved: (value) => enteredLastName = value!,
                                ),
                                const SizedBox(height: 15),
                              ],

                              TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                decoration:
                                    _buildInputDecoration(
                                      'Email',
                                      Icons.email_outlined,
                                    ).copyWith(
                                      hintStyle: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                validator: (value) =>
                                    (value == null || !value.contains('@'))
                                    ? 'Invalid email'
                                    : null,
                                onSaved: (value) => enteredEmail = value!,
                              ),
                              const SizedBox(height: 15),

                              TextFormField(
                                obscureText: true,
                                decoration:
                                    _buildInputDecoration(
                                      'Password',
                                      Icons.lock_outline,
                                    ).copyWith(
                                      hintStyle: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                validator: (value) =>
                                    (value == null || value.length < 6)
                                    ? 'Min 6 characters'
                                    : null,
                                onSaved: (value) => enteredPassword = value!,
                              ),
                              const SizedBox(height: 5),

                              if (_isLogin)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: Text(
                                      "Forgot Password?",
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF00885d),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 20),

                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: const Color(0xFF00885d),
                                  ),
                                  onPressed: _submit,
                                  child: _isAuthenticating
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          _isLogin ? "Login" : "SignUp",
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.surface,
                                            fontSize: 16,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _formKey.currentState?.reset();
                                      _isLogin = !_isLogin;
                                    });
                                  },
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: _isLogin
                                              ? "Don't have an account? "
                                              : "Already have an account? ",
                                        ),
                                        TextSpan(
                                          text: _isLogin ? "Sign Up" : "Login",
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF00885d),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
