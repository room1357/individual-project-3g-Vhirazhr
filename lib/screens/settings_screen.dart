import 'package:flutter/material.dart';

import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ===== THEME SAMA HOME =====
  static const Color pinkBg = Color(0xFFF8D7DA);
  static const Color pinkSoft = Color(0xFFF3B8C2);
  static const Color roseDark = Color(0xFFD87A87);
  static const Color maroon = Color(0xFF451A2B);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF2D1B2E);
  static const Color patternBg = Color(0xFFFEF7F8);

  String selectedLanguage = "English";
  bool darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pinkBg,
      extendBody: true,
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            fontSize: 20,
          ),
        ),
        backgroundColor: maroon,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),

      // ✅ BODY TANPA PATTERN / STACK
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 14),

          _buildSectionTitle("General"),
          const SizedBox(height: 8),
          _buildCard(
            child: ListTile(
              leading: _leadingIcon(Icons.info_rounded),
              title: const Text(
                "About",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: darkText,
                ),
              ),
              subtitle: Text(
                "Expense Tracker v1.0.0",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: darkText.withOpacity(0.6),
                ),
              ),
              trailing: _trailingArrow(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              },
            ),
          ),

          const SizedBox(height: 14),
          _buildCard(
            child: ListTile(
              leading: _leadingIcon(Icons.language_rounded),
              title: const Text(
                "Language",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: darkText,
                ),
              ),
              subtitle: Text(
                selectedLanguage,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: darkText.withOpacity(0.6),
                ),
              ),
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedLanguage,
                  borderRadius: BorderRadius.circular(14),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: darkText,
                    fontWeight: FontWeight.w600,
                  ),
                  items:
                      const ["English", "Indonesia", "Spanish"]
                          .map(
                            (lang) => DropdownMenuItem(
                              value: lang,
                              child: Text(lang),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => selectedLanguage = value);
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),
          _buildSectionTitle("Appearance"),
          const SizedBox(height: 8),
          _buildCard(
            child: SwitchListTile(
              secondary: _leadingIcon(Icons.brightness_6_rounded),
              title: const Text(
                "Dark Theme",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: darkText,
                ),
              ),
              subtitle: Text(
                "Enable dark mode",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: darkText.withOpacity(0.6),
                ),
              ),
              value: darkModeEnabled,
              activeThumbColor: maroon,
              onChanged: (val) {
                setState(() => darkModeEnabled = val);
                // kalau kamu sudah punya theme provider,
                // tinggal panggil logic theme switch di sini
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===== WIDGETS UI =====
  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [maroon, roseDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: maroon.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 62,
            width: 62,
            decoration: BoxDecoration(
              color: white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: white.withOpacity(0.35), width: 2),
            ),
            child: const Icon(Icons.person_rounded, color: white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Fakhira Zahrany Nardin",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Fakhirazahra88@gmail.com",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: darkText,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: maroon.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _leadingIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: maroon.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: maroon, size: 22),
    );
  }

  Widget _trailingArrow() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: maroon.withOpacity(0.08),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: maroon,
      ),
    );
  }
}
