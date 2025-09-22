import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Masuk'),
        backgroundColor: const Color.fromARGB(255, 221, 160, 205),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo aplikasi
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 221, 160, 205),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            SizedBox(height: 32),

            // Field username
            TextField(
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 16),

            // Field password
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            SizedBox(height: 24),

            // Tombol login
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigasi ke HomeScreen dengan pushReplacement
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 221, 160, 205),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'LOGIN',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Link ke halaman register
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Dont Have Account? "),
                TextButton(
                  onPressed: () {
                    // Navigasi ke RegisterScreen dengan push
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: Text('Register'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
