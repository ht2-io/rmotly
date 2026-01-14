import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/providers/api_client_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: RemotlyApp(),
    ),
  );
}

class RemotlyApp extends ConsumerWidget {
  const RemotlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize the API client
    ref.watch(apiClientProvider);

    return MaterialApp.router(
      title: 'Remotly',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

/// Application router configuration
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);

/// Temporary home screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remotly'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.dashboard,
              size: 100,
              color: Colors.deepPurple,
            ),
            SizedBox(height: 20),
            Text(
              'Welcome to Remotly',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Phase 1: Project Setup Complete',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
