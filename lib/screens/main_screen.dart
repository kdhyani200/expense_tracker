import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/transactions.dart';
import '../widget/main_card.dart';
import '../widget/main_transaction_card.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 60, // Increased height for the double-line title
        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            final userData = snapshot.data?.data() as Map<String, dynamic>?;
            final firstName = userData?['firstname'] ?? 'User';
            final lastName = userData?['lastname'] ?? 'User';

            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align text to left
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Hello,",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  "$firstName $lastName",
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey[100],
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
      // SingleChildScrollView should not have a fixed-height Container inside
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            MainCard(),
            SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(bottom: 2),
              child: Text(
                "Recent Transactions",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            ListView.builder(
              shrinkWrap: true, // Use this if inside a Column
              physics:
                  const NeverScrollableScrollPhysics(), // Use this if the outer view scrolls
              itemCount: recentTransactions.length,
              itemBuilder: (context, index) {
                final item = recentTransactions[index];
                return TransactionItemCard(
                  icon: item.icon,
                  color: item.color,
                  label: item.label,
                  description: item.description,
                  amount: item.amount,
                  date: item.date,
                  isIncome: item.isIncome,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
