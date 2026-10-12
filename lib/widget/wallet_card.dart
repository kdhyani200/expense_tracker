import 'dart:io';
import 'package:flutter/material.dart';
import '../models/wallet_model.dart';

class WalletCard extends StatelessWidget {
  final WalletModel wallet;

  final VoidCallback onTap;

  const WalletCard({super.key, required this.wallet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(16),

        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,

              decoration: BoxDecoration(
                color: Theme.of(context).shadowColor,

                borderRadius: BorderRadius.circular(12),
              ),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),

                child: wallet.imagePath != null
                    ? Image.file(File(wallet.imagePath!), fit: BoxFit.cover)
                    : Icon(Icons.wallet, color: Colors.grey.shade400),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    wallet.name,

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "₹${wallet.balance.toStringAsFixed(2)}",

                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,

              size: 16,

              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
