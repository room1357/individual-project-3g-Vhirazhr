import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue,
        //actions: [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Foto profil
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color.fromARGB(234, 245, 138, 255),
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),

            // Nama user
            const Text(
              'Fakhira Zahrany Nardin',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // Email user
            Text(
              'Fakhirazahra88@gmail.com',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),

            const SizedBox(height: 24),
            const Divider(),

            // Info tambahan pakai ListTile
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.blue),
              title: const Text('Telepon Number'),
              subtitle: const Text('087760409688'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.blue),
              title: const Text('Address'),
              subtitle: const Text('JL Letjen S Parman 2 No 18 Malang'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.blue),
              title: const Text('Tanggal Bergabung'),
              subtitle: const Text('8 Januari 2024'),
            ),
          ],
        ),
      ),
    );
  }
}
