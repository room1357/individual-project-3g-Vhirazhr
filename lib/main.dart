import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'services/category_manager.dart';
import 'services/expense_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await CategoryManager.load();
  await ExpenseService.load();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Pengeluaran',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
