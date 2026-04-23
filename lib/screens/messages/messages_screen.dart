import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text('Mesajlar', style: Theme.of(context).textTheme.headlineMedium),
            Text(
              'Yakında eklenecek',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
