import 'package:flutter/material.dart';

import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String selectedLanguage = "English";
    bool darkModeEnabled = false;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile info
          const ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text("Fakhira Zahrany Nardin"),
            subtitle: Text("Fakhirazahra88@gmail.com"),
          ),
          const Divider(),

          // About
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.info, color: Colors.blue),
              title: const Text("About"),
              subtitle: const Text("Expense Tracker v1.0.0"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Language (pakai StatefulBuilder)
          StatefulBuilder(
            builder: (context, setState) {
              return ListTile(
                leading: const Icon(Icons.language, color: Colors.blue),
                title: const Text("Language"),
                subtitle: Text(selectedLanguage),
                trailing: DropdownButton<String>(
                  value: selectedLanguage,
                  items:
                      <String>["English", "Indonesia", "Spanish"]
                          .map(
                            (lang) => DropdownMenuItem(
                              value: lang,
                              child: Text(lang),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedLanguage = value!;
                    });
                  },
                ),
              );
            },
          ),
          const Divider(),

          // Dark Theme (pakai StatefulBuilder)
          StatefulBuilder(
            builder: (context, setState) {
              return SwitchListTile(
                secondary: const Icon(Icons.brightness_6, color: Colors.blue),
                title: const Text("Dark Theme"),
                subtitle: const Text("Enable dark mode"),
                value: darkModeEnabled,
                onChanged: (bool value) {
                  setState(() {
                    darkModeEnabled = value;
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
