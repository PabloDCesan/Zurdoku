import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import '../providers/bottom_nav_provider.dart';
import '../widgets/app_bottom_nav_bar.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return AppBottomNavBar(
      child: Scaffold(
      backgroundColor: Color.fromARGB(255, 235, 140, 33),

      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/mainMenu_clean.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.question_mark_rounded,
                      size: 64,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Acerca de Zurdoku',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                      'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
                      'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris '
                      'nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in '
                      'reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla '
                      'pariatur. Excepteur sint occaecat cupidatat non proident, sunt in '
                      'culpa qui officia deserunt mollit anim id est laborum.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
